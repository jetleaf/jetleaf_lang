part of 'asset_path_resource.dart';

/// {@template default_asset_path_resource}
/// Default implementation of [AssetPathResource] that resolves assets
/// from the runtime environment using a path or filename.
///
/// This class attempts to locate an asset in multiple ways:
/// 1. **Exact path match** – Compares against each asset’s full path.
/// 2. **Filename match** – Matches only the filename if the full path fails.
/// 3. **Normalized path match** – Handles platform-specific differences
///    like `file://` prefixes and `\` vs `/`.
/// 4. **Suffix match** – Matches by the tail end of the path if needed.
/// 5. **Single filename candidate** – If exactly one candidate matches the filename.
///
/// Once resolved, the asset is cached internally for efficient access.
///
/// ### Example
/// ```dart
/// final resource = DefaultAssetPathResource("assets/config/settings.yaml");
///
/// if (resource.exists()) {
///   print("Found: ${resource.getFileName()}");
///   final bytes = resource.getContentBytes();
///   print("Content length: ${bytes.length}");
/// } else {
///   print("Asset not found");
/// }
/// ```
/// {@endtemplate}
final class DefaultAssetPathResource extends AssetPathResource {
  Asset? _asset;

  /// The original path string used to resolve this resource.
  final String path;

  /// {@macro default_asset_path_resource}
  DefaultAssetPathResource(this.path) : super(path) {
    try {
      _asset = _resolveAsset(path);
    } catch (_) {}
  }

  /// Attempts to resolve an [Asset] given a path string.
  ///
  /// Resolution is performed in multiple steps:
  /// - Exact match by file path.
  /// - Match by file name.
  /// - Normalized path comparison.
  /// - Suffix match for partial paths.
  /// - Fallback to unique filename match.
  ///
  /// Returns `null` if no matching asset is found.
  Asset? _resolveAsset(String path) {
    final allAssets = Runtime.getAllAssets();

    String normalize(String p) {
      var normalized = p;
      if (normalized.startsWith('file://')) {
        normalized = normalized.substring(7);
      }
      return normalized.replaceAll('\\', '/');
    }

    final normalizedPath = normalize(path);

    // --- 1️⃣ Exact path match ---
    for (final ast in allAssets) {
      if (normalize(ast.getFilePath()) == normalizedPath) {
        return ast;
      }
    }

    // --- 2️⃣ Try implicit HTML extension ---
    // e.g. /forgot-password → /forgot-password.html
    if (!normalizedPath.contains('.') && !normalizedPath.endsWith('/')) {
      final htmlCandidate = "$normalizedPath.html";
      for (final ast in allAssets) {
        if (normalize(ast.getFilePath()).endsWith(htmlCandidate)) {
          return ast;
        }
      }
    }

    // --- 3️⃣ Try suffix match (e.g. "resources/.../forgot-password.html") ---
    for (final ast in allAssets) {
      if (normalize(ast.getFilePath()).endsWith(normalizedPath)) {
        return ast;
      }
    }

    // --- 4️⃣ Filename match fallback ---
    final fileName = normalizedPath.split('/').last;
    final candidates = allAssets.where((ast) => ast.getFileName() == fileName).toList();
    if (candidates.length == 1) {
      return candidates.first;
    }

    // --- 5️⃣ Implicit HTML by filename ---
    final htmlFileName = "$fileName.html";
    final htmlCandidates = allAssets.where((ast) => ast.getFileName() == htmlFileName).toList();
    if (htmlCandidates.length == 1) {
      return htmlCandidates.first;
    }

    // --- Not found ---
    return null;
  }

  Exception _throwIfNotFound([String? name]) => IllegalStateException("${name ?? 'Asset'} for $path not found");
  
  @override
  bool exists() => _asset != null;

  @override
  Asset get([Supplier<Exception>? throwIfNotFound]) {
    if(_asset != null) {
      return _asset!;
    } else if(throwIfNotFound != null) {
      throw throwIfNotFound();
    } else {
      throw _throwIfNotFound();
    }
  }

  @override
  Uint8List getContentBytes() {
    if(exists()) {
      return _asset!.getContentBytes();
    }

    throw _throwIfNotFound();
  }

  @override
  String getFileName() {
    if(exists()) {
      return _asset!.getFileName();
    }

    throw _throwIfNotFound();
  }

  @override
  String getFilePath() {
    if(exists()) {
      return _asset!.getFilePath();
    }

    throw _throwIfNotFound();
  }

  @override
  String? getPackageName() {
    if(exists()) {
      return _asset!.getPackageName();
    }

    throw _throwIfNotFound();
  }

  @override
  String getUniqueName() {
    if(exists()) {
      return _asset!.getUniqueName();
    }

    throw _throwIfNotFound();
  }

  @override
  bool hasExtension(List<String> exts) {
    if(exists()) {
      return exts.any((e) => _asset!.getFilePath().containsIgnoreCase(e));
    }

    throw _throwIfNotFound();
  }

  @override
  Map<String, Object> toJson() {
    if(exists()) {
      return _asset!.toJson();
    }

    throw _throwIfNotFound();
  }

  @override
  Asset? tryGet([Supplier<Exception>? orElseThrow]) {
    if(_asset != null) {
      return _asset!;
    } else if(orElseThrow != null) {
      throw orElseThrow();
    } else {
      return null;
    }
  }

  @override
  InputStream getInputStream() {
    if(_asset != null) {
      return ByteArrayInputStream(_asset!.getContentBytes());
    }

    throw _throwIfNotFound();
  }
}