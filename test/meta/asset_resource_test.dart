// test/asset_resource_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:jetleaf_lang/src/declaration/declaration.dart';
import 'package:jetleaf_lang/src/meta/asset_resource.dart';
import 'package:test/test.dart';

class MockAsset extends Asset {
  final String? filePath;
  final String? fileName;
  final String content;
  
  MockAsset({this.filePath, this.fileName, required this.content}) : super(
    filePath: '', fileName: '', packageName: '', contentBytes: Uint8List.fromList(utf8.encode(content)));

  @override
  String getFileName() => fileName ?? 'mock_file.txt';
  
  @override
  String getFilePath() => filePath ?? '/path/to/mock_file.txt';
}

void main() {
  group('AssetResource', () {
    test('factory constructor with string source', () {
      final resource = AssetResource('test content');
      expect(resource.source, equals('test content'));
    });

    test('factory constructor with Asset source', () {
      final asset = MockAsset(content: 'asset content');
      final resource = AssetResource(asset);
      expect(resource.source, equals(asset));
    });

    test('getIsContent with string content', () {
      final result = AssetResource.getIsContent('{"key": "value"}');
      expect(result, isTrue);
    });

    test('getIsContent with string path', () {
      final result = AssetResource.getIsContent('/path/to/file.txt');
      expect(result, isFalse);
    });

    test('getIsContent with Asset', () {
      final asset = MockAsset(content: 'content');
      final result = AssetResource.getIsContent(asset);
      expect(result, isFalse);
    });

    test('determineExtension from string path', () {
      final result = AssetResource.determineExtension('/path/to/file.yaml');
      expect(result, equals('yaml'));
    });

    test('determineExtension from string content', () {
      final result = AssetResource.determineExtension('key: value');
      expect(result, equals('yaml'));
    });

    test('determineExtension from Asset with path', () {
      final asset = MockAsset(filePath: '/path/to/file.json', content: '{}');
      final result = AssetResource.determineExtension(asset);
      expect(result, equals('json'));
    });

    test('determineExtension from Asset with fileName', () {
      final asset = MockAsset(fileName: 'config.xml', content: '<root/>', filePath: '/path/to/file.xml');
      final result = AssetResource.determineExtension(asset);
      expect(result, equals('xml'));
    });

    test('determineExtension returns null for unknown extension', () {
      final result = AssetResource.determineExtension('unknown content format');
      expect(result, isNull);
    });

    test('registerExtensionStrategy adds custom strategy', () {
      String? customStrategy(Object source) {
        if (source is String && source.contains('custom')) return 'custom';
        return null;
      }
      
      AssetResource.registerExtensionStrategy(customStrategy);
      
      final result = AssetResource.determineExtension('some custom content');
      expect(result, equals('custom'));
    });

    test('registerContentDetector adds custom detector', () {
      bool customDetector(Object source) {
        if (source is String && source.contains('CUSTOM')) return true;
        return false;
      }
      
      AssetResource.registerContentDetector(customDetector);
      
      final result = AssetResource.getIsContent('This is CUSTOM content');
      expect(result, isTrue);
    });

    test('extension strategies continue after exception', () {
      String? throwingStrategy(Object source) {
        throw Exception('Strategy failed');
      }
      
      String? workingStrategy(Object source) {
        if (source is String && source.contains('working')) return 'ok';
        return null;
      }
      
      AssetResource.registerExtensionStrategy(throwingStrategy);
      AssetResource.registerExtensionStrategy(workingStrategy);
      
      final result = AssetResource.determineExtension('this is working content');
      expect(result, equals('ok'));
    });

    test('content detectors continue after exception', () {
      bool throwingDetector(Object source) {
        throw Exception('Detector failed');
      }
      
      bool workingDetector(Object source) {
        if (source is String && source.contains('detect')) return true;
        return false;
      }
      
      AssetResource.registerContentDetector(throwingDetector);
      AssetResource.registerContentDetector(workingDetector);
      
      final result = AssetResource.getIsContent('please detect this');
      expect(result, isTrue);
    });
  });
}