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

import 'package:jetleaf_lang/jetleaf_lang.dart';
import 'package:test/test.dart';

import '../_dependencies.dart';

void main() {
  setUpAll(() async {
    await setupRuntime();
    return Future<void>.value();
  });

  group('ParameterizedTypeReference Comprehensive Tests', () {
    group('Basic Operations', () {
      test('should capture generic type information', () {
        final listRef = ParameterizedTypeReference<List<String>>();
        final type = listRef.getType();
        
        expect(type.toString(), contains('List'));
      });

      test('should return ResolvableType', () {
        final listRef = ParameterizedTypeReference<List<String>>();
        final resolvableType = listRef.getResolvableType();
        
        expect(resolvableType, isNotNull);
        expect(resolvableType.resolve()?.getType().toString(), contains('List'));
      });

      test('factory constructor should work', () {
        final ref = ParameterizedTypeReference<List<String>>();
        expect(ref, isNotNull);
        expect(ref.getType().toString(), contains('List'));
      });
    });

    group('Equality and Hashing', () {
      test('equality should work correctly', () {
        final ref1 = ParameterizedTypeReference<List<String>>();
        final ref2 = ParameterizedTypeReference<List<String>>();
        
        expect(ref1 == ref2, isTrue);
      });

      test('hashCode should be consistent', () {
        final ref1 = ParameterizedTypeReference<List<String>>();
        final ref2 = ParameterizedTypeReference<List<String>>();
        
        expect(ref1.hashCode, equals(ref2.hashCode));
      });
    });

    group('String Representation', () {
      test('toString should show type information', () {
        final ref = ParameterizedTypeReference<List<String>>();
        final str = ref.toString();
        
        expect(str, contains('ParameterizedTypeReference'));
        expect(str, contains('List'));
      });
    });

    group('Complex Generic Types', () {
      test('should handle nested generics', () {
        final ref = ParameterizedTypeReference<List<List<String>>>();
        final type = ref.getType();
        
        expect(type.toString(), contains('List'));
      });

      test('should handle multiple type parameters', () {
        final ref = ParameterizedTypeReference<Map<String, int>>();
        final type = ref.getType();
        
        expect(type.toString(), contains('Map'));
      });
    });

    group('Integration with ResolvableType', () {
      test('should integrate with ResolvableType system', () {
        final ref = ParameterizedTypeReference<List<String>>();
        final resolvableType = ref.getResolvableType();
        
        expect(resolvableType.hasGenerics(), isTrue);
      });

      test('should work with type resolution', () {
        final ref = ParameterizedTypeReference<List<String>>();
        final resolvableType = ref.getResolvableType();
        final resolved = resolvableType.resolve();
        
        expect(resolved, isNotNull);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('should handle dynamic type', () {
        final ref = ParameterizedTypeReference<dynamic>();
        final type = ref.getType();
        
        expect(type, equals(dynamic));
      });

      test('should handle Object type', () {
        final ref = ParameterizedTypeReference<Object>();
        final type = ref.getType();
        
        expect(type, equals(Object));
      });
    });
  });
}
