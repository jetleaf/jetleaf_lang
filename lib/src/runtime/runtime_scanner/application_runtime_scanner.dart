// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'dart:io';
import 'dart:mirrors' as mirrors;

import 'package:path/path.dart' as p;

import '../../declaration/declaration.dart';
import '../file_utility.dart';
import '../generators/application_library_generator.dart';
import '../generators/library_generator.dart';
import '../runtime_provider/standard_runtime_provider.dart';
import '../runtime_provider/configurable_runtime_provider.dart';
import '../runtime_resolver/runtime_resolving.dart';
import '../utils.dart';
import 'default_runtime_scanner_summary.dart';
import 'configurable_runtime_scanner_summary.dart';
import 'runtime_scanner.dart';
import 'runtime_scanner_configuration.dart';
import 'runtime_scanner_summary.dart';

/// {@template on_logged}
/// Signature for logging callbacks used to report runtime scanning messages.
///
/// This is typically passed to [ApplicationRuntimeScanner] for custom logging:
///
/// ```dart
/// void logInfo(String msg) => print('[INFO] $msg');
/// final scanner = DefaultRuntimeScan(onInfo: logInfo);
/// ```
///
/// {@endtemplate}
typedef OnLogged = void Function(String message);

/// {@template default_runtime_scan}
/// A default implementation of [RuntimeScanner] that supports scanning,
/// logging, and context tracking.
///
/// This scanner allows optional logging hooks to handle messages during
/// the scanning process. If no callbacks are provided, messages are
/// buffered internally and can be retrieved later.
///
/// ## Example
/// ```dart
/// final scan = DefaultRuntimeScan(
///   onInfo: (msg) => print('[INFO] $msg'),
///   onWarning: (msg) => print('[WARN] $msg'),
///   onError: (msg) => print('[ERR] $msg'),
/// );
/// ```
///
/// The logs are tagged with the current `_package` name when set, helping
/// identify the origin of messages during multi-package scans.
///
/// {@endtemplate}
class ApplicationRuntimeScanner implements RuntimeScanner {
  /// Optional info log callback.
  final OnLogged? _onInfo;

  /// Optional warning log callback.
  final OnLogged? _onWarning;

  /// Optional error log callback.
  final OnLogged? _onError;

  /// {@macro default_runtime_scan}
  ApplicationRuntimeScanner({
    OnLogged? onInfo, 
    OnLogged? onWarning, 
    OnLogged? onError,
  }) : _onInfo = onInfo, _onWarning = onWarning, _onError = onError;

  /// Holds the runtime factory or context being scanned, if any.
  ConfigurableRuntimeProvider? _context;

  /// Optional name of the package currently being scanned.
  String? _package;

  /// Buffer for info-level logs when no info callback is provided.
  final List<String> _infoLogs = [];

  /// Buffer for warning-level logs when no warning callback is provided.
  final List<String> _warningLogs = [];

  /// Buffer for error-level logs when no error callback is provided.
  final List<String> _errorLogs = [];

  /// Logs an info-level message to the [onInfo] callback or buffers it.
  ///
  /// Automatically prepends the current package name if set.
  void _logInfo(String message) {
    String msg = _package != null ? "[$_package] $message" : message;
    if (_onInfo != null) {
      _onInfo(msg);
    } else {
      _infoLogs.add(msg);
    }
  }

  /// Logs a warning-level message to the [onWarning] callback or buffers it.
  ///
  /// Automatically prepends the current package name if set.
  void _logWarning(String message) {
    String msg = _package != null ? "[$_package] $message" : message;
    if (_onWarning != null) {
      _onWarning(msg);
    } else {
      _warningLogs.add(msg);
    }
  }

  /// Logs an error-level message to the [onError] callback or buffers it.
  ///
  /// Automatically prepends the current package name if set.
  void _logError(String message) {
    String msg = _package != null ? "[$_package] $message" : message;
    if (_onError != null) {
      _onError(msg);
    } else {
      _errorLogs.add(msg);
    }
  }

  @override
  Future<RuntimeScannerSummary> scan(String outputFolder, RuntimeScannerConfiguration configuration, {Directory? source}) async {
    bool refreshContext = _context == null || !configuration.reload;
    final stopwatch = Stopwatch()..start();
    FileUtility FileUtils = FileUtility(_logInfo, _logWarning, _logError, configuration);

    // 1. Setup directory and verify its existence
    if(refreshContext) {
      _logInfo('Creating target directory structure...');
    }

    Directory directory = source ?? Directory.current;

    // 2. Read package name from pubspec.yaml
    _package ??= await FileUtils.readPackageName();

    directory = Directory(p.join(directory.path, outputFolder));
    if(!await directory.exists()) {
      await directory.create(recursive: true);
    } else {
      await directory.delete(recursive: true);
      await directory.create(recursive: true);
    }

    // 3. Add default packages to scan if none specified
    configuration = _addDefaultPackagesToScan(configuration, _package!);

    _logInfo("${refreshContext ? "Reloading" : "Scanning"} $_package application...");
    Set<File> dartFiles = {};
    Set<File> nonDartFiles = {};
    List<Asset> resources = [];
    List<Package> packages = [];

    if(refreshContext) {
      dartFiles = await FileUtils.findDartFiles(directory);
      nonDartFiles = await FileUtils.findNonDartFiles(directory);
      resources = await FileUtils.discoverAllResources(_package!);
      packages = await FileUtils.readPackageGraphDependencies(directory);
    } else {
      // For non-rebuilds, only process additions/removals if specified
      if(configuration.additions.isNotEmpty || configuration.removals.isNotEmpty || configuration.filesToScan.isNotEmpty) {
        dartFiles = (configuration.filesToScan + configuration.additions).where((file) => file.path.endsWith('.dart')).toSet();
        nonDartFiles = (configuration.filesToScan + configuration.additions).where((file) => !file.path.endsWith('.dart')).toSet();
      }

      if(configuration.updateAssets) {
        resources = await FileUtils.discoverAllResources(_package!);
      }

      if(configuration.updatePackages) {
        packages = await FileUtils.readPackageGraphDependencies(directory);
      }
    }

    _logInfo("Found ${dartFiles.length} dart files.");
    _logInfo("Found ${nonDartFiles.length} non-dart files.");
    _logInfo("Found ${resources.length} resources.");
    _logInfo("Found ${packages.length} packages.");

    List<LibraryDeclaration> libraries = [];
    List<TypeDeclaration> specialTypes = [];

    // 3. Setup mirror system and access domain
    _logInfo('Setting up mirror system and access domain...');
    mirrors.MirrorSystem access = mirrors.currentMirrorSystem();
    _logInfo('Mirror system and access domain set up.');

    // 4. Load dart files that are not present in the [currentMirrorSystem]
    _logInfo('Loading dart files that are not present in the [currentMirrorSystem]...');
    Map<File, Uri> urisToLoad = FileUtils.getUrisToLoad(dartFiles, _package!);
    List<mirrors.LibraryMirror> forceLoadedMirrors = [];
    for (final uriEntry in urisToLoad.entries) {
      if(ReflectUtils.isNonLoadableJetLeafFile(uriEntry.value) || ReflectUtils.isNonLoadableFile(uriEntry.value, configuration)) {
        continue;
      }

      mirrors.LibraryMirror? mirror = await FileUtils.forceLoadLibrary(uriEntry.value, uriEntry.key, access);
      if(mirror != null) {
        forceLoadedMirrors.add(mirror);
      }
    }

    // 5. Generate reflection metadata
    _logInfo('Resolving code metadata libraries...');
    LibraryGenerator libraryGenerator = ApplicationLibraryGenerator(
      mirrorSystem: access,
      forceLoadedMirrors: forceLoadedMirrors,
      onInfo: _logInfo,
      onWarning: _logWarning,
      onError: _logError,
      configuration: configuration,
      packages: packages,
    );
    final result = await libraryGenerator.generate(dartFiles.toList());
    _logInfo('Resolved ${result.length} libraries.');

    libraries.addAll(result);

    // 6. Generate AOT Runtime Resolvers
    RuntimeResolving resolving = RuntimeResolving(
      access: access,
      libraries: libraries,
      forceLoadedMirrors: forceLoadedMirrors,
      outputFolder: outputFolder,
      fileUtils: FileUtils,
      package: _package!,
      logInfo: _logInfo,
      logWarning: _logWarning,
      logError: _logError,
    );

    if(refreshContext) {
      _context = StandardRuntimeProvider();
    }
    _context?.setRuntimeResolver(await resolving.resolve());

    if(resources.isNotEmpty) {
      _context?.addAssets(resources, replace: refreshContext);
    }

    if(packages.isNotEmpty) {
      _context?.addPackages(packages, replace: refreshContext);
    }

    if(libraries.isNotEmpty) {
      _context?.addLibraries(libraries, replace: refreshContext);
    }

    // Handle removals (now configuration.removals) by removing them from the context
    if(configuration.removals.isNotEmpty) {
      final libs = _context?.getAllLibraries() ?? [];
      final urisToRemove = configuration.removals.map((f) => FileUtils.resolveToPackageUri(f.absolute.path, _package!, FileUtils.packageConfig)).whereType<String>().toSet();
      final updatedLibs = libs.where((lib) => !urisToRemove.contains(lib.getUri())).toList();
      _context?.addLibraries(updatedLibs, replace: true);
    }

    if(specialTypes.isNotEmpty) {
      _context?.addSpecialTypes(specialTypes, replace: refreshContext);
    }

    if(nonDartFiles.isNotEmpty) {
      (_context as StandardRuntimeProvider?)?.addNonDartFiles(nonDartFiles.toList(), replace: refreshContext);
    }

    stopwatch.stop();
    _logInfo("Application ${refreshContext ? "reloading" : "scanning"} completed in ${stopwatch.elapsedMilliseconds}ms.");

    ConfigurableRuntimeScannerSummary summary = DefaultRuntimeScannerSummary();
    summary.setContext(_context!);
    summary.setBuildTime(DateTime.fromMillisecondsSinceEpoch(stopwatch.elapsedMilliseconds));
    summary.addInfos(_infoLogs);
    summary.addWarnings(_warningLogs);
    summary.addErrors(_errorLogs);

    return summary;
  }

  /// Adds default packages to scan if none are specified.
  /// By default, the user's current package and 'jetleaf' are included.
  RuntimeScannerConfiguration _addDefaultPackagesToScan(RuntimeScannerConfiguration configuration, String currentPackage) {
    final defaultPackages = {
      currentPackage,
      'jetleaf',
      ...configuration.packagesToScan
    }.toList();
    final filteredDefaults = defaultPackages.where((pkg) => !configuration.packagesToExclude.contains(pkg)).toList();
    
    return RuntimeScannerConfiguration(
      reload: configuration.reload,
      updatePackages: configuration.updatePackages,
      updateAssets: configuration.updateAssets,
      packagesToScan: filteredDefaults,
      packagesToExclude: configuration.packagesToExclude,
      filesToScan: configuration.filesToScan,
      filesToExclude: configuration.filesToExclude,
      additions: configuration.additions,
      removals: configuration.removals,
    );
  }
}

// =============================================== FILE UTILS ===============================================

/// Utility class for file system operations related to Dart projects.
// class FileUtility {
//   List<PackageConfigEntry>? _packageConfig;
//   String? _currentPackageName;

//   final OnLogged _onWarning;
//   final OnLogged _onError;
//   final OnLogged _onInfo;
//   final RuntimeScannerConfiguration _loader;

//   FileUtility(this._onWarning, this._onError, this._onInfo, this._loader) {
//     _loadPackageConfig();
//   }

//   List<PackageConfigEntry> get packageConfig => _packageConfig ?? [];

//   /// Loads the package configuration from .dart_tool/package_config.json.
//   Future<void> _loadPackageConfig() async {
//     if (_packageConfig != null) return;

//     final packageConfigFile = File(p.join(Directory.current.path, '.dart_tool', 'package_config.json'));
//     final packageConfigDir = packageConfigFile.parent.path; // Directory containing package_config.json

//     if (!await packageConfigFile.exists()) {
//       _onWarning('Warning: .dart_tool/package_config.json not found. Cannot resolve package URIs for dependencies.');
//       _packageConfig = [];
//       return;
//     }

//     try {
//       final content = await packageConfigFile.readAsString();
//       final json = jsonDecode(content);
//       final packagesJson = json['packages'] as List<dynamic>;
//       _packageConfig = packagesJson.map((e) => PackageConfigEntry.fromJson(e as Map<String, dynamic>, packageConfigDir)).toList();
//     } catch (e) {
//       _onError('Error reading or parsing package_config.json: $e');
//       _packageConfig = [];
//     }
//   }

//   /// Resolves a list of files to their package URIs, filtering out excluded files.
//   Map<File, Uri> getUrisToLoad(Set<File> files, String package) {
//     Map<File, Uri> uris = {};

//     final excludedFilePaths = (_loader.removals + _loader.filesToExclude)
//         .map((f) => p.normalize(f.absolute.path))
//         .toSet();

//     for (final file in files) {
//       final normalizedFilePath = p.normalize(file.absolute.path);
//       if (excludedFilePaths.contains(normalizedFilePath)) {
//         _onWarning('Skipping explicitly excluded file: $normalizedFilePath');
//         continue;
//       }

//       final packageUriString = resolveToPackageUri(normalizedFilePath, package, packageConfig);
//       if (packageUriString != null) {
//         uris[file] = Uri.parse(packageUriString);
//       } else {
//         _onWarning('Could not resolve $normalizedFilePath to a package URI. Using file URI instead.');
//         uris[file] = file.uri;
//       }
//     }

//     return uris;
//   }

//   /// Forces a Dart library at [uri] to be loaded into the [mirrorSystem].
//   ///
//   /// Required to trigger static initialization and make classes available
//   /// to runtime analysis.
//   Future<mirrors.LibraryMirror?> forceLoadLibrary(Uri uri, File file, mirrors.MirrorSystem mirrorSystem) async {
//     // // Check if the library is already loaded to avoid errors
//     // if (mirrorSystem.libraries.values.any((lib) => lib.uri == uri)) {
//     //   return null;
//     // }

//     // if(ReflectUtils.isPartOf(await file.readAsString())) {
//     //   _onWarning("Skipping library with `part of` directive: $uri");
//     //   return null;
//     // }

//     try {
//       return await mirrorSystem.isolate.loadUri(uri);
//     } catch (e) {
//       _onError('Error loading library $uri: $e');
//       return null;
//     }
//   }

//   /// Reads the package name from the pubspec.yaml file in the current directory.
//   Future<String> readPackageName() async {
//     if (_currentPackageName != null) return _currentPackageName!;

//     final pubspecFile = File(p.join(Directory.current.path, 'pubspec.yaml'));
//     if (!await pubspecFile.exists()) {
//       throw Exception('pubspec.yaml not found in current directory.');
//     }
//     final content = await pubspecFile.readAsString();
//     final nameMatch = RegExp(r'name:\s*(\S+)').firstMatch(content);
//     if (nameMatch != null && nameMatch.group(1) != null) {
//       _currentPackageName = nameMatch.group(1)!;
//       return _currentPackageName!;
//     }
//     throw Exception('Could not find package name in pubspec.yaml');
//   }

//   /// Finds all Dart files within the current project and its dependencies, respecting inclusion/exclusion lists.
//   Future<Set<File>> findDartFiles(Directory projectDir) async {
//     final Set<File> dartFiles = {};

//     final allFilesToScan = (_loader.filesToScan).map((f) => p.normalize(f.absolute.path)).toSet();
//     final allFilesToExclude = (_loader.filesToExclude).map((f) => p.normalize(f.absolute.path)).toSet();
//     final RegExp testFileOrFolderRegex = RegExp(
//       r'(^|/|\\)(test|tests)(/|\\|$)|_test\.dart$',
//       caseSensitive: false
//     );

//     // Helper to check if a file should be included based on explicit file lists
//     bool shouldIncludeFile(String filePath) {
//       final normalizedPath = p.normalize(filePath);
//       if (allFilesToExclude.contains(normalizedPath)) {
//         return false;
//       }

//       final isInLibFolder = p.split(normalizedPath).contains('lib');
//       final isInTestFolder = testFileOrFolderRegex.hasMatch(normalizedPath);

//       if (!isInLibFolder && (isInTestFolder && _loader.skipTests)) {
//         return false;
//       }

//       if (allFilesToScan.isEmpty) {
//         return true; // If no specific files are listed, include all non-excluded
//       }
//       return allFilesToScan.contains(normalizedPath);
//     }

//     // 1. Find Dart files in the current project directory
//     await for (final entity in projectDir.list(recursive: true, followLinks: false)) {
//       if (entity is File && entity.path.endsWith('.dart')) {
//         if (shouldIncludeFile(entity.absolute.path)) {
//           dartFiles.add(entity);
//         }
//       }
//     }

//     // 2. Find Dart files in dependencies
//     if (_packageConfig != null) {
//       for (final pkg in _packageConfig!) {
//         final packageName = pkg.name;
//         final packageRoot = Directory(pkg.absoluteRootPath);

//         // Check package inclusion/exclusion
//         final bool includePackage = (_loader.packagesToScan.isEmpty) || _loader.packagesToScan.contains(packageName);
//         final bool excludePackage = _loader.packagesToExclude.contains(packageName);

//         if (includePackage && !excludePackage) {
//           if (await packageRoot.exists()) {
//             await for (final entity in packageRoot.list(recursive: true, followLinks: false)) {
//               if (entity is File && entity.path.endsWith('.dart')) {
//                 if (shouldIncludeFile(entity.absolute.path)) {
//                   dartFiles.add(entity);
//                 }
//               }
//             }
//           } else {
//             _onWarning('Warning: Package root directory not found for ${pkg.name}: ${pkg.absoluteRootPath}');
//           }
//         }
//       }
//     }
//     return dartFiles;
//   }

//   /// Finds all non-Dart files within the current project directory, respecting inclusion/exclusion lists.
//   Future<Set<File>> findNonDartFiles(Directory projectDir) async {
//     final Set<File> nonDartFiles = {};
    
//     final allFilesToScan = (_loader.filesToScan).map((f) => p.normalize(f.absolute.path)).toSet();
//     final allFilesToExclude = (_loader.filesToExclude).map((f) => p.normalize(f.absolute.path)).toSet();

//     // Helper to check if a file should be included based on explicit file lists
//     bool shouldIncludeFile(String filePath) {
//       final normalizedPath = p.normalize(filePath);
//       if (allFilesToExclude.contains(normalizedPath)) {
//         return false;
//       }
//       if (allFilesToScan.isEmpty) {
//         return true; // If no specific files are listed, include all non-excluded
//       }
//       return allFilesToScan.contains(normalizedPath);
//     }

//     // 1. Find non-Dart files in the current project directory
//     await for (final entity in projectDir.list(recursive: true, followLinks: false)) {
//       if (entity is File && !entity.path.endsWith('.dart')) {
//         if (shouldIncludeFile(entity.absolute.path)) {
//           nonDartFiles.add(entity);
//         }
//       }
//     }

//     // 2. Find non-Dart files in dependencies
//     if (_packageConfig != null) {
//       for (final pkg in _packageConfig!) {
//         final packageName = pkg.name;
//         final packageRoot = Directory(pkg.absoluteRootPath);

//         // Check package inclusion/exclusion
//         final bool includePackage = (_loader.packagesToScan.isEmpty) || _loader.packagesToScan.contains(packageName);
//         final bool excludePackage = _loader.packagesToExclude.contains(packageName);

//         if (includePackage && !excludePackage) {
//           if (await packageRoot.exists()) {
//             await for (final entity in packageRoot.list(recursive: true, followLinks: false)) {
//               if (entity is File && !entity.path.endsWith('.dart')) {
//                 if (shouldIncludeFile(entity.absolute.path)) {
//                   nonDartFiles.add(entity);
//                 }
//               }
//             }
//           } else {
//             _onWarning('Warning: Package root directory not found for ${pkg.name}: ${pkg.absoluteRootPath}');
//           }
//         }
//       }
//     }

//     return nonDartFiles;
//   }

//   /// Resolves a file system path to a package URI (e.g., 'package:my_package/src/file.dart').
//   /// Returns null if the path cannot be resolved to a package URI.
//   String? resolveToPackageUri(String absoluteFilePath, String currentPackageName, List<PackageConfigEntry> packageConfig) {
//     if (packageConfig.isEmpty) {
//       _onError('Package config not loaded. Cannot resolve package URI for $absoluteFilePath');
//       return null;
//     }

//     // Normalize the absolute file path for consistent comparison
//     final normalizedAbsoluteFilePath = p.normalize(absoluteFilePath);

//     // Try to resolve against known packages
//     for (final pkg in packageConfig) {
//       final absoluteLibPath = p.normalize(p.join(pkg.absoluteRootPath, p.fromUri(pkg.packageUri)));
//       if (p.isWithin(absoluteLibPath, normalizedAbsoluteFilePath)) {
//         final relativePath = p.relative(normalizedAbsoluteFilePath, from: absoluteLibPath);
//         // Ensure relativePath does not start with a slash if it's not empty
//         final cleanedRelativePath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
//         return 'package:${pkg.name}/$cleanedRelativePath';
//       }
//     }

//     // If not found in any package, check if it's in the current project's lib directory
//     final currentProjectLibPath = p.normalize(p.join(Directory.current.path, 'lib'));
//     if (p.isWithin(currentProjectLibPath, normalizedAbsoluteFilePath)) {
//       final relativePath = p.relative(normalizedAbsoluteFilePath, from: currentProjectLibPath);
//       final cleanedRelativePath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
//       return 'package:$currentPackageName/$cleanedRelativePath';
//     }

//     _onError('Could not resolve $absoluteFilePath to a package URI.');
//     return null;
//   }

//   /// Reads dependencies from .dart_tool/package_graph.json.
//   Future<List<Package>> readPackageGraphDependencies(Directory projectRoot) async {
//     final graphFile = File(p.join(projectRoot.path, '.dart_tool', 'package_graph.json'));
//     final configFile = File(p.join(projectRoot.path, '.dart_tool', 'package_config.json'));

//     if (!graphFile.existsSync()) return [];

//     Map<String, dynamic> graph = {};
//     Map<String, dynamic> config = {};

//     try {
//       graph = jsonDecode(await graphFile.readAsString());
//     } catch (e) {
//       _onError('Error reading package_graph.json: $e');
//       return [];
//     }

//     if (configFile.existsSync()) {
//       try {
//         config = jsonDecode(await configFile.readAsString());
//       } catch (e) {
//         _onError('Error reading package_config.json: $e');
//       }
//     }

//     final roots = Set<String>.from(graph['roots'] ?? []);
//     final graphPackages = Map.fromEntries(
//       (graph['packages'] as List)
//           .whereType<Map>()
//           .map((pkg) => MapEntry(pkg['name'], pkg['version'])),
//     );

//     final configPackages = config['packages'] as List<dynamic>? ?? [];

//     final result = <Package>[];

//     for (final entry in configPackages) {
//       if (entry is Map<String, dynamic>) {
//         final name = entry['name'] as String?;
//         final rootUri = entry['rootUri'] as String?;
//         final langVersion = entry['languageVersion'] as String?;
//         final version = graphPackages[name];

//         if (name != null && version != null) {
//           final isRoot = rootUri == '../' || roots.contains(name);
//           result.add(PackageImplementation(
//             name: name,
//             version: version,
//             languageVersion: langVersion,
//             isRootPackage: isRoot,
//             rootUri: rootUri,
//             filePath: rootUri != null ? Uri.parse(rootUri).isAbsolute
//                 ? Uri.parse(rootUri).toFilePath()
//                 : Directory.current.uri.resolveUri(Uri.parse(rootUri)).toFilePath() : null,
//           ));
//         }
//       }
//     }

//     // If config is missing or empty, fallback to graph only
//     if (result.isEmpty) {
//       for (final pkg in graphPackages.entries) {
//         result.add(PackageImplementation(
//           name: pkg.key,
//           version: pkg.value,
//           languageVersion: null,
//           isRootPackage: roots.contains(pkg.key),
//           rootUri: null,
//           filePath: null,
//         ));
//       }
//     }

//     return result;
//   }

//   /// Discovers all resource files in the current project, JetLeaf package, and third-party dependencies.
//   Future<List<Asset>> discoverAllResources(String currentPackageName) async {
//     final List<Asset> allResources = [];
//     final currentProjectRoot = Directory.current.path;

//     List<Directory> searchDirectories(String root) => [
//       Directory(p.join(root, Constant.RESOURCES_DIR_NAME)),
//       Directory(p.join(root, 'lib', Constant.RESOURCES_DIR_NAME)),
//       Directory(p.join(root, Constant.PACKAGE_ASSET_DIR)),
//       Directory(p.join(root, 'lib', Constant.PACKAGE_ASSET_DIR)),
//     ];

//     // 1. User's project resources
//     _onInfo('🔍 Scanning user project for resources...');
//     for (final dir in searchDirectories(currentProjectRoot)) {
//       if (dir.existsSync()) {
//         allResources.addAll(await _scanDirectoryForResources(dir, currentPackageName, currentProjectRoot));
//       }
//     }

//     // 3. Third-party package resources
//     _onInfo('🔍 Scanning third-party packages for resources...');
//     for (final dep in (_packageConfig ?? <PackageConfigEntry>[])) {
//       final depPackagePath = dep.absoluteRootPath;
//       final packageName = dep.name;

//       // Check package inclusion/exclusion
//       final bool includePackage = (_loader.packagesToScan.isEmpty) || _loader.packagesToScan.contains(packageName);
//       final bool excludePackage = _loader.packagesToExclude.contains(packageName);

//       if (Directory(depPackagePath).existsSync() && includePackage && !excludePackage) {
//         for (final dir in searchDirectories(depPackagePath)) {
//           if (dir.existsSync()) {
//             allResources.addAll(await _scanDirectoryForResources(dir, dep.name, depPackagePath));
//           }
//         }
//       }
//     }
//     return allResources;
//   }

//   /// Scans a given directory for files and returns them as Asset objects.
//   /// [dir]: The directory to scan.
//   /// [packageName]: The name of the package this directory belongs to.
//   /// [packageRootPath]: The absolute path to the root of the package.
//   Future<List<Asset>> _scanDirectoryForResources(Directory dir, String packageName, String packageRootPath) async {
//     final List<Asset> resources = [];
//     await for (final entity in dir.list(recursive: true, followLinks: false)) {
//       if (entity is File) {
//         final isDartFile = entity.path.endsWith('.dart');
//         if (!isDartFile) {
//           resources.add(AssetImplementation(
//             filePath: entity.path,
//             fileName: p.basename(entity.path),
//             packageName: packageName,
//             contentBytes: await entity.readAsBytes(),
//           ));
//         }
//       }
//     }
//     return resources;
//   }
// }

// /// {@template package_config_entry}
// /// Represents an entry from the `.dart_tool/package_config.json` file.
// ///
// /// Each entry maps a Dart package name to its corresponding root and
// /// lib directory location, typically used by tools to resolve `package:` imports.
// ///
// /// ## Example
// /// ```json
// /// {
// ///   "name": "jetleaf",
// ///   "rootUri": "../jetleaf/",
// ///   "packageUri": "lib/"
// /// }
// /// ```
// /// {@endtemplate}
// class PackageConfigEntry {
//   /// The name of the Dart package.
//   final String name;

//   /// The URI pointing to the package's root directory.
//   final Uri rootUri;

//   /// The URI pointing to the `lib/` subdirectory inside the root.
//   final Uri packageUri;

//   /// The resolved absolute file system path for the root directory.
//   final String absoluteRootPath;

//   /// {@macro package_config_entry}
//   PackageConfigEntry({
//     required this.name,
//     required this.rootUri,
//     required this.packageUri,
//     required this.absoluteRootPath,
//   });

//   /// Creates a [PackageConfigEntry] from a JSON object in a
//   /// `.dart_tool/package_config.json` file.
//   ///
//   /// - [json]: A map representing the package config entry.
//   /// - [packageConfigDir]: The directory containing the `package_config.json`.
//   ///
//   /// Relative URIs are resolved against [packageConfigDir].
//   factory PackageConfigEntry.fromJson(Map<String, dynamic> json, String packageConfigDir) {
//     final name = json['name'] as String;
//     final rootUri = Uri.parse(json['rootUri'] as String);
//     final packageUri = Uri.parse(json['packageUri'] as String);

//     String resolvedRootPath;
//     if (rootUri.scheme == 'file') {
//       resolvedRootPath = p.fromUri(rootUri);
//     } else {
//       resolvedRootPath = p.normalize(p.join(packageConfigDir, p.fromUri(rootUri)));
//     }

//     return PackageConfigEntry(
//       name: name,
//       rootUri: rootUri,
//       packageUri: packageUri,
//       absoluteRootPath: resolvedRootPath,
//     );
//   }
// }