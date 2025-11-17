part of 'asset_path_resource.dart';

/// {@template file_asset_path_resource}
/// A file-based implementation of [AssetPathResource] that loads assets directly
/// from the local file system using [File] from `dart:io`.
///
/// This class attempts to locate and load a file from disk using the provided
/// [path]. If the file does not exist locally, it can optionally fall back to
/// the JetLeaf [AssetLoader] for bundled resources.
///
/// ### Example
/// ```dart
/// final resource = FileAssetPathResource('/app/assets/templates/home.html');
///
/// if (resource.exists()) {
///   print('File: ${resource.getFileName()}');
///   print('Size: ${resource.getContentBytes().length} bytes');
/// } else {
///   print('Resource not found');
/// }
/// ```
///
/// ### Features
/// - Supports file system assets and JetLeaf-bundled assets.
/// - Automatically normalizes paths.
/// - Provides consistent API with [DefaultAssetPathResource].
/// - Lazy loads content for efficiency.
/// {@endtemplate}
final class FileAssetPathResource extends AssetPathResource {
  /// The absolute or relative file path to resolve.
  final String path;

  /// Cached file instance.
  late final File _file = File(_normalizePath(path));

  /// Cached file content (lazy-loaded).
  Uint8List? _cachedBytes;

  /// Optional fallback loader (for bundled assets).
  final AssetLoaderInterface _assetLoader;

  /// {@macro file_asset_path_resource}
  FileAssetPathResource(this.path, [AssetLoaderInterface? assetLoader]) 
    : _assetLoader = assetLoader ?? jetLeafAssetLoader, super(path);

  /// Normalizes the file path for consistent cross-platform access.
  String _normalizePath(String input) {
    var p = input.trim();
    if (p.startsWith('file://')) {
      p = p.substring(7);
    }
    return p.replaceAll('\\', '/');
  }

  Exception _throwIfNotFound([String? name]) => IllegalStateException("${name ?? 'File'} not found at path: $path");

  /// Checks if the file exists on the local file system or via the loader.
  @override
  bool exists() {
    try {
      return _file.existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Attempts to retrieve the file as an [Asset].
  ///
  /// Converts the file into an [Asset]-like structure compatible with
  /// the JetLeaf ecosystem.
  @override
  Asset get([Supplier<Exception>? throwIfNotFound]) {
    if (exists()) {
      return _FileSystemAsset(_file);
    }

    // Try fallback loader
    try {
      final content = File(_normalizePath(path));
      if (content.existsSync()) {
        return _FileSystemAsset(content);
      }
    } catch (_) {}

    throw throwIfNotFound?.call() ?? _throwIfNotFound();
  }

  /// Returns the file contents as raw bytes.
  @override
  Uint8List getContentBytes() {
    if (_cachedBytes != null) return _cachedBytes!;

    if (exists()) {
      _cachedBytes = _file.readAsBytesSync();
      return _cachedBytes!;
    }

    // Fallback to JetLeaf bundler
    try {
      final data = Closeable.DEFAULT_ENCODING.encode(_assetLoader.load(path).toString());
      _cachedBytes = Uint8List.fromList(data);
      return _cachedBytes!;
    } catch (_) {
      throw _throwIfNotFound();
    }
  }

  @override
  String getFileName() => path.split('/').last;

  @override
  String getFilePath() => _file.path;

  @override
  String? getPackageName() => _assetLoader.packageName;

  @override
  String getUniqueName() => "file://${getPackageName() ?? 'local'}:${_normalizePath(path)}";

  @override
  bool hasExtension(List<String> exts) {
    final lowerPath = path.toLowerCase();
    return exts.any((e) => lowerPath.endsWith(e.toLowerCase()));
  }

  @override
  InputStream getInputStream() {
    if (exists()) {
      return ByteArrayInputStream(getContentBytes());
    }

    throw _throwIfNotFound();
  }

  @override
  Map<String, Object> toJson() {
    if (!exists()) throw _throwIfNotFound();

    return {
      "type": "file",
      "path": getFilePath(),
      "name": getFileName(),
      "package": getPackageName() ?? "local",
      "uniqueName": getUniqueName(),
      "size": _file.existsSync() ? _file.lengthSync() : 0,
    };
  }

  @override
  Asset? tryGet([Supplier<Exception>? orElseThrow]) {
    if (exists()) {
      return _FileSystemAsset(_file);
    }
    return null;
  }
}

/// Internal adapter for treating a local [File] as an [Asset].
class _FileSystemAsset implements Asset {
  final File file;

  _FileSystemAsset(this.file);

  @override
  String getFilePath() => file.path;

  @override
  String getFileName() => file.uri.pathSegments.isNotEmpty
      ? file.uri.pathSegments.last
      : file.path.split('/').last;

  @override
  String getUniqueName() => 'file://${file.absolute.path}';

  @override
  String? getPackageName() => 'local';

  @override
  Uint8List getContentBytes() => file.readAsBytesSync();

  @override
  Map<String, Object> toJson() => {
        'type': 'file',
        'path': file.path,
        'name': getFileName(),
        'size': file.existsSync() ? file.lengthSync() : 0,
      };
}