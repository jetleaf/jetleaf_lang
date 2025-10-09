import 'dart:typed_data';
import 'package:jetleaf_lang/lang.dart';
import 'package:test/test.dart';

import '../_dependencies.dart';

/// Fake implementation for testing the abstract AssetPathResource contract.
class _FakeAssetPathResource extends AssetPathResource {
  final Asset _asset;

  _FakeAssetPathResource(this._asset) : super(_asset.getFilePath());

  @override
  bool exists() => true;

  @override
  Asset get([Supplier<Exception>? throwIfNotFound]) => _asset;

  @override
  Uint8List getContentBytes() => _asset.getContentBytes();

  @override
  String getFileName() => _asset.getFileName();

  @override
  String getFilePath() => _asset.getFilePath();

  @override
  String? getPackageName() => _asset.getPackageName();

  @override
  String getUniqueName() => _asset.getUniqueName();

  @override
  bool hasExtension(List<String> exts) =>
      exts.any((e) => _asset.getFilePath().toLowerCase().endsWith(e.toLowerCase()));

  @override
  Map<String, Object> toJson() => _asset.toJson();

  @override
  Asset? tryGet([Supplier<Exception>? orElseThrow]) => _asset;
  
  @override
  InputStream getInputStream() => ByteArrayInputStream(_asset.getContentBytes());
}

void main() {
  group('AssetPathResource (abstract contract)', () {
    late Asset asset;
    late AssetPathResource resource;

    setUpAll(() async {
      await setupRuntime();
      final allAssets = Runtime.getAllAssets();
      expect(allAssets, isNotEmpty);
      asset = allAssets.first;
      resource = _FakeAssetPathResource(asset);
    });

    test('exists returns true', () {
      expect(resource.exists(), isTrue);
    });

    test('get returns the asset', () {
      expect(resource.get(), same(asset));
    });

    test('tryGet returns the asset', () {
      expect(resource.tryGet(), same(asset));
    });

    test('file info methods delegate to asset', () {
      expect(resource.getFileName(), asset.getFileName());
      expect(resource.getFilePath(), asset.getFilePath());
      expect(resource.getPackageName(), asset.getPackageName());
      expect(resource.getUniqueName(), asset.getUniqueName());
    });

    test('getContentBytes delegates correctly', () {
      expect(resource.getContentBytes(), asset.getContentBytes());
    });

    test('hasExtension works', () {
      final ext = asset.getFileName().split('.').last;
      expect(resource.hasExtension([ext]), isTrue);
      expect(resource.hasExtension(['nope']), isFalse);
    });

    test('toJson delegates to asset', () {
      expect(resource.toJson(), asset.toJson());
    });
  });

  group('DefaultAssetPathResource', () {
    late List<Asset> allAssets;

    setUp(() {
      allAssets = Runtime.getAllAssets();
      expect(allAssets, isNotEmpty, reason: 'Runtime must provide assets for testing');
    });

    test('resolves by exact path', () {
      final asset = allAssets.first;
      final res = DefaultAssetPathResource(asset.getFilePath());

      expect(res.exists(), isTrue);
      expect(res.getFilePath(), asset.getFilePath());
      expect(res.getFileName(), asset.getFileName());
      expect(res.getUniqueName(), asset.getUniqueName());
    });

    test('resolves by file name only', () {
      final asset = allAssets.first;
      final res = DefaultAssetPathResource(asset.getFileName());

      expect(res.exists(), isTrue);
      expect(res.getFileName(), asset.getFileName());
    });

    test('resolves by normalized path with file:// and backslashes', () {
      final asset = allAssets.first;
      final normalizedPath = "file://${asset.getFilePath().replaceAll('/', '\\')}";

      final res = DefaultAssetPathResource(normalizedPath);

      expect(res.exists(), isTrue);
      expect(res.getFilePath(), asset.getFilePath());
    });

    test('resolves by suffix match', () {
      final asset = allAssets.first;
      final suffix = asset.getFilePath().split('/').skip(1).join('/');

      final res = DefaultAssetPathResource(suffix);

      expect(res.exists(), isTrue);
      expect(res.getFileName(), asset.getFileName());
    });

    test('delegates to asset for content and metadata', () {
      final asset = allAssets.first;
      final res = DefaultAssetPathResource(asset.getFilePath());

      expect(res.getPackageName(), asset.getPackageName());
      expect(res.getUniqueName(), asset.getUniqueName());
      expect(res.toJson(), asset.toJson());
      expect(res.getContentBytes(), isA<Uint8List>());
    });

    test('hasExtension works case-insensitively', () {
      final asset = allAssets.first;
      final res = DefaultAssetPathResource(asset.getFilePath());

      final ext = asset.getFileName().split('.').last;
      expect(res.hasExtension([ext.toUpperCase()]), isTrue);
      expect(res.hasExtension(['.bogus']), isFalse);
    });

    test('tryGet returns null if not found', () {
      final res = DefaultAssetPathResource('nonexistent_file_123456.txt');
      expect(res.tryGet(), isNull);
    });

    test('get throws if not found', () {
      final res = DefaultAssetPathResource('nonexistent_file_123456.txt');
      expect(() => res.get(), throwsA(isA<IllegalStateException>()));
    });

    test('get throws custom exception if provided', () {
      final res = DefaultAssetPathResource('nonexistent_file_123456.txt');
      expect(
        () => res.get(() => Exception('Custom fail')),
        throwsA(isA<Exception>().having((e) => e.toString(), 'msg', contains('Custom fail'))),
      );
    });
  });
}