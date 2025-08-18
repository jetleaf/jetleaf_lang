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

import '../constant.dart';
import '../extensions/primitives/iterable.dart';
import '../exceptions.dart';
import '../primitives/integer.dart';
import 'runtime_provider/runtime_provider.dart';
import 'runtime_resolver/runtime_resolver.dart';
import '../declaration/declaration.dart';
import 'meta_table.dart';

/// {@template central_runtime}
/// A central, globally accessible proxy for runtime metadata in JetLeaf.
///
/// This class delegates all reflection and metadata queries to a single
/// [RuntimeRegistry] instance, which must be set at startup using [setRegistry()].
///
/// It acts as the globally shared runtime entry point, making it possible
/// for any part of the system to query metadata without managing the registry directly.
///
/// ---
/// ⚠️ The [register] method must be called before accessing any members,
/// usually from generated bootstrap code:
///
/// ```dart
/// void main() {
///   final provider = MyGeneratedRuntimeProvider();
///   Runtime.setRegistry(StandardRuntimeRegistry.create(provider));
///   runApp();
/// }
///
/// final clazz = Runtime.getReflectedClass<MyService>();
/// ```
///
/// {@endtemplate}
class _MetaRuntimeProvider extends RuntimeProvider {
  Map<Package, PackageContent>? _contents = {};
  RuntimeResolver? _resolver;
  List<Package> _packages = [];
  List<Asset> _assets = [];
  List<TypeDeclaration> _specialTypes = [];
  List<File> _nonDartFiles = [];
  List<LibraryDeclaration> _libraries = [];

  _MetaRuntimeProvider._();

  /// Sets the underlying [RuntimeProvider] that this central runtime will delegate to.
  ///
  /// This should be called exactly once during application bootstrap.
  ///
  /// ```dart
  /// _MetaRuntimeProvider runtime = Runtime as _MetaRuntimeProvider;
  /// runtime.setRegistry(StandardRuntimeRegistry.create(provider));
  /// ```
  void register(RuntimeProvider registry) {
    Map<Package, PackageContentImpl> sections = {};

    for(var reg in registry.getAllLibraries()) {
      if(sections.containsKey(reg.getPackage())) {
        sections[reg.getPackage()]!.setLibraries([...sections[reg.getPackage()]!.getAllLibraries(), reg]);
      } else {
        sections[reg.getPackage()] = PackageContentImpl(reg.getPackage(), [], [reg], Integer.valueOf(-1));
      }
    }

    for(var asset in registry.getAllAssets()) {
      final pkg = sections.keys.firstWhereOrNull((k) => k.getName() == asset.getPackageName());
      if(pkg != null) {
        sections[pkg]!.setAssets([...sections[pkg]!.getAllAssets(), asset]);
      }
    }

    int hierarchyCounter = 3; // start counting non-dart packages from 3
    int? dartHierarchy;

    for (var section in sections.entries) {
      var pkg = section.key;
      int hierarchy;

      if (pkg.getIsRootPackage()) {
        hierarchy = 0;
      } else if (pkg.getName() == Constant.PACKAGE_NAME) {
        hierarchy = 1;
      } else if (pkg.getName().startsWith(Constant.PACKAGE_NAME)) {
        hierarchy = 2;
      } else if (pkg.getName() == Constant.DART_PACKAGE_NAME) {
        // mark dart for later assignment
        dartHierarchy = null; 
        continue;
      } else {
        hierarchy = hierarchyCounter++;
      }

      section.value.setHierarchy(Integer.valueOf(hierarchy));
    }

    // finally assign dart package as last number
    if (dartHierarchy == null) {
      int last = hierarchyCounter; 
      for (var section in sections.entries) {
        if (section.key.getName() == Constant.DART_PACKAGE_NAME) {
          section.value.setHierarchy(Integer.valueOf(last));
        }
      }
    }

    _contents = sections;
    _assets = registry.getAllAssets();
    _packages = registry.getAllPackages();
    _resolver = registry.getRuntimeResolver();
    _nonDartFiles = registry.getNonDartFiles();
    _specialTypes = registry.getSpecialTypes();
    _libraries = registry.getAllLibraries();
  }

  Iterable<PackageContent> _sortedSections() {
    final sections = _contents!.entries.toList();
    sections.sort((a, b) => a.value.getHierarchy().value.compareTo(b.value.getHierarchy().value));
    return sections.map((e) => e.value);
  }

  void _assertInitialized() {
    if (_contents == null || _resolver == null) {
      throw UnsupportedOperationException('Runtime loader has not been initialized. Call Runtime.register() before accessing any members.');
    }
  }

  @override
  List<Asset> getAllAssets() => List.unmodifiable(_assets);

  @override
  List<Package> getAllPackages() => List.unmodifiable(_packages);

  @override
  RuntimeResolver getRuntimeResolver() {
    _assertInitialized();
    return _resolver!;
  }
  
  @override
  List<LibraryDeclaration> getAllLibraries() => List.unmodifiable(_libraries);
  
  @override
  List<File> getNonDartFiles() => List.unmodifiable(_nonDartFiles);
  
  @override
  List<TypeDeclaration> getSpecialTypes() => List.unmodifiable(_specialTypes);

  List<EntityDeclaration> getAllEntities() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getAnnotations(),
          ...lib.getDeclarations(),
          ...lib.getTopLevelMethods(),
          ...lib.getTopLevelFields(),
        ],
    ];
  }

  List<ClassDeclaration> getAllClasses() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getClasses().sortedByPublicFirstThenSyntheticLast(),
        ]
    ];
  }

  List<MixinDeclaration> getAllMixins() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getDeclarations().whereType<MixinDeclaration>().sortedByPublicFirstThenSyntheticLast(),
        ]
    ];
  }

  List<EnumDeclaration> getAllEnums() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getEnums().sortedByPublicFirstThenSyntheticLast(),
        ]
    ];
  }

  List<TypedefDeclaration> getAllTypedefs() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getTypedefs().sortedByPublicFirstThenSyntheticLast(),
        ]
    ];
  }

  List<TypeDeclaration> getAllTypes() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getDeclarations().whereType<TypeDeclaration>().sortedByPublicFirstThenSyntheticLast(),
        ]
    ];
  }

  List<ExtensionDeclaration> getAllExtensions() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getExtensions().sortedByPublicFirstThenSyntheticLast(),
        ]
    ];
  }

  List<ConstructorDeclaration> getAllConstructors() {
    _assertInitialized();
    return [
      for (final cls in getAllClasses())
        ...cls.getConstructors().sortedByPublicFirstThenSyntheticLast(),
    ];
  }

  List<MethodDeclaration> getAllMethods() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getTopLevelMethods().sortedByPublicFirstThenSyntheticLast(),
        ],
      for (final cls in getAllClasses())
        ...cls.getMethods().sortedByPublicFirstThenSyntheticLast(),
      for (final enm in getAllEnums())
        ...enm.getMembers().whereType<MethodDeclaration>().sortedByPublicFirstThenSyntheticLast(),
      for (final ext in getAllExtensions())
        ...ext.getMembers().whereType<MethodDeclaration>().sortedByPublicFirstThenSyntheticLast(),
    ];
  }

  List<FieldDeclaration> getAllFields() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        for (final lib in section.getAllLibraries()) ...[
          ...lib.getTopLevelFields().sortedByPublicFirstThenSyntheticLast(),
        ],
      for (final cls in getAllClasses())
        ...cls.getFields().sortedByPublicFirstThenSyntheticLast(),
      for (final enm in getAllEnums())
        ...enm.getMembers().whereType<FieldDeclaration>().sortedByPublicFirstThenSyntheticLast(),
      for (final ext in getAllExtensions())
        ...ext.getMembers().whereType<FieldDeclaration>().sortedByPublicFirstThenSyntheticLast(),
    ];
  }

  List<RecordDeclaration> getAllRecords() {
    _assertInitialized();
    return [
      for (final section in _sortedSections())
        ...section.getAllLibraries().flatMap((l) => l.getTopLevelRecords().sortedByPublicFirstThenSyntheticLast()),
      for (final cls in getAllClasses())
        ...cls.getRecords().sortedByPublicFirstThenSyntheticLast(),
      for (final enm in getAllEnums())
        ...enm.getMembers().whereType<RecordDeclaration>().sortedByPublicFirstThenSyntheticLast(),
      for (final ext in getAllExtensions())
        ...ext.getMembers().whereType<RecordDeclaration>().sortedByPublicFirstThenSyntheticLast(),
    ];
  }

  List<AnnotationDeclaration> getAllAnnotations() {
    _assertInitialized();
    final Set<AnnotationDeclaration> allAnnotations = {};

    final flat = _sortedSections().flatMap((s) => s.getAllLibraries()).flatMap((l) => l.getDeclarations());

    for (final decl in flat) {
      allAnnotations.addAll(decl.getAnnotations());

      if (decl is ClassDeclaration) {
        final res = decl.getMembers().flatMap((m) => m.getAnnotations());
        allAnnotations.addAll(res);
      }
    }

    return allAnnotations.toList().sortedByPublicFirstThenSyntheticLast();
  }
}

/// {@macro central_runtime}
///
/// This is the globally accessible runtime registry.
/// It must be initialized before usage.
///
/// ```dart
/// final clazz = Runtime.getReflectedClass<MyBean>();
/// ```
final _MetaRuntimeProvider Runtime = _MetaRuntimeProvider._();