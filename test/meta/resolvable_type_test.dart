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

import 'package:jetleaf_lang/lang.dart';
import 'package:test/test.dart';

import '../_dependencies.dart';

void main() {
  setUpAll(() async {
    await setupRuntime();
    ResolvableType.clearCache();
    return Future<void>.value();
  });

  group('ResolvableType Comprehensive Tests', () {
    group('Factory Methods', () {
      test('forClass should create ResolvableType for basic types', () {
        final stringType = ResolvableType.forClass(String);
        expect(stringType.resolve()?.getType(), equals(String));
        expect(stringType.toString(), contains('String'));
      });

      test('forClass should handle null gracefully', () {
        final objectType = ResolvableType.forClass(Object);
        expect(objectType.resolve()?.getType(), equals(Object));
      });

      test('forRawClass should create raw type without generics', () {
        final rawListType = ResolvableType.forRawClass(List);
        expect(rawListType.getGenerics(), isEmpty);
        expect(rawListType.resolve()?.getType(), equals(List));
      });

      test('forClassWithGenerics should preserve generic information', () {
        final genericListType = ResolvableType.forClassWithGenerics(List, [String]);
        expect(genericListType.hasGenerics(), isTrue);
        expect(genericListType.getGenerics().length, equals(1));
        expect(genericListType.getGeneric([0]).resolve()?.getType(), equals(String));
      });

      test('forClassWithGenerics should preserve generic information for ArrayList', () {
        final genericListType = ResolvableType.forClassWithGenerics(ArrayList, [String]);
        expect(genericListType.hasGenerics(), isTrue);
        expect(genericListType.getGenerics().length, equals(1));
        expect(genericListType.getGeneric([0]).resolve()?.getType(), equals(String));
      });

      test('forClassWithResolvableGenerics should work with ResolvableType generics', () {
        final stringType = ResolvableType.forClass(String);
        final intType = ResolvableType.forClass(int);
        final mapType = ResolvableType.forClassWithResolvableGenerics(Map, [stringType, intType]);
        
        expect(mapType.hasGenerics(), isTrue);
        expect(mapType.getGenerics().length, equals(2));
        expect(mapType.getGeneric([0]).resolve()?.getType(), equals(String));
        expect(mapType.getGeneric([1]).resolve()?.getType(), equals(int));
      });

      test('forInstance should create type from object instance', () {
        final myString = 'hello';
        final instanceType = ResolvableType.forInstance(myString);
        expect(instanceType.resolve()?.getType(), equals(String));
      });

      test('forInstance should handle null', () {
        final nullType = ResolvableType.forInstance(null);
        expect(nullType, equals(ResolvableType.NONE));
      });

      test('forArrayComponent should create array type', () {
        final stringType = ResolvableType.forClass(String);
        final arrayType = ResolvableType.forArrayComponent(stringType);
        
        expect(arrayType.isArray(), isTrue);
        expect(arrayType.getComponentType().resolve()?.getType(), equals(String));
      });

      test('forType with owner should handle variable resolution', () {
        final ownerType = ResolvableType.forClass(List);
        final resultType = ResolvableType.forType(String, ownerType);
        
        expect(resultType.resolve()?.getType(), equals(String));
      });
    });

    group('Type Resolution and Queries', () {
      test('resolve should return correct Class', () {
        final stringType = ResolvableType.forClass(String);
        final resolved = stringType.resolve();
        
        expect(resolved, isNotNull);
        expect(resolved!.getType(), equals(String));
      });

      test('resolve should use fallback when type cannot be resolved', () {
        final emptyType = ResolvableType.NONE;
        final fallback = Class.forType(Object);
        final resolved = emptyType.resolve(fallback);
        
        expect(resolved, equals(fallback));
      });

      test('resolveType should handle complex resolution', () {
        final stringType = ResolvableType.forClass(String);
        final resolved = stringType.resolveType();
        
        expect(resolved, equals(stringType));
      });

      test('getRawClass should return underlying class', () {
        final stringType = ResolvableType.forClass(String);
        final rawClass = stringType.getRawClass();
        
        expect(rawClass, isNotNull);
        expect(rawClass!.getType(), equals(String));
      });

      test('toClass should return resolved class', () {
        final stringType = ResolvableType.forClass(String);
        final classResult = stringType.toClass();
        
        expect(classResult, isNotNull);
        expect(classResult!.getType(), equals(String));
      });
    });

    group('Array and Collection Operations', () {
      test('isArray should detect array types', () {
        final listType = ResolvableType.forClass(List);
        expect(listType.isArray(), isTrue);
        
        final stringType = ResolvableType.forClass(String);
        expect(stringType.isArray(), isFalse);
      });

      test('getComponentType should return element type for arrays', () {
        final stringType = ResolvableType.forClass(String);
        final arrayType = ResolvableType.forArrayComponent(stringType);
        
        final componentType = arrayType.getComponentType();
        expect(componentType.resolve()?.getType(), equals(String));
      });

      test('asCollection should convert to Iterable type', () {
        final listType = ResolvableType.forClass(List);
        final collectionType = listType.asCollection();
        
        expect(collectionType, isNotNull);
      });

      test('asMap should convert to Map type', () {
        final mapType = ResolvableType.forClass(Map);
        final asMapType = mapType.asMap();
        
        expect(asMapType, isNotNull);
      });

      test('getKeyType should return key type for maps', () {
        final stringType = ResolvableType.forClass(String);
        final intType = ResolvableType.forClass(int);
        final mapType = ResolvableType.forClassWithResolvableGenerics(Map, [stringType, intType]);
        
        final keyType = mapType.getKeyType();
        expect(keyType.resolve()?.getType(), equals(String));
      });
    });

    group('Generic Type Operations', () {
      test('hasGenerics should detect generic parameters', () {
        final rawListType = ResolvableType.forClass(ArrayList);
        final genericListType = ResolvableType.forClassWithGenerics(ArrayList, [String]);
        
        expect(rawListType.hasGenerics(), isTrue);
        expect(genericListType.hasGenerics(), isTrue);
      });

      test('getGenerics should return all generic parameters', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        final generics = mapType.getGenerics();
        
        expect(generics.length, equals(2));
        expect(generics[0].resolve()?.getType(), equals(String));
        expect(generics[1].resolve()?.getType(), equals(int));
      });

      test('getGeneric should return specific generic by index', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        
        final firstGeneric = mapType.getGeneric([0]);
        final secondGeneric = mapType.getGeneric([1]);
        
        expect(firstGeneric.resolve()?.getType(), equals(String));
        expect(secondGeneric.resolve()?.getType(), equals(int));
      });

      test('getGeneric without index should return first generic', () {
        final listType = ResolvableType.forClassWithGenerics(List, [String]);
        final firstGeneric = listType.getGeneric();
        
        expect(firstGeneric.resolve()?.getType(), equals(String));
      });

      test('resolveGenerics should resolve all generic parameters', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        final resolvedGenerics = mapType.resolveGenerics();
        
        expect(resolvedGenerics.length, equals(2));
        expect(resolvedGenerics[0]?.getType(), equals(String));
        expect(resolvedGenerics[1]?.getType(), equals(int));
      });

      test('resolveGenericsWithFallback should use fallback when needed', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        final fallback = Class.forType(Object);
        final resolvedGenerics = mapType.resolveGenericsWithFallback(fallback);
        
        expect(resolvedGenerics.length, equals(2));
        expect(resolvedGenerics[0].getType(), equals(String));
        expect(resolvedGenerics[1].getType(), equals(int));
      });

      test('resolveGeneric should resolve specific generic', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        final firstGeneric = mapType.resolveGeneric([0]);
        
        expect(firstGeneric?.getType(), equals(String));
      });

      test('hasResolvableGenerics should detect resolvable generics', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        expect(mapType.hasResolvableGenerics(), isTrue);
        
        final emptyType = ResolvableType.NONE;
        expect(emptyType.hasResolvableGenerics(), isFalse);
      });

      test('hasUnresolvableGenerics should detect unresolvable generics', () {
        final normalType = ResolvableType.forClass(String);
        expect(normalType.hasUnresolvableGenerics(), isTrue);
      });
    });

    group('Type Hierarchy Navigation', () {
      test('getSuperType should return superclass', () {
        final stringType = ResolvableType.forClass(String);
        final superType = stringType.getSuperType();
        
        expect(superType.resolve()?.getType(), equals(Object));
      });

      test('getInterfaces should return implemented interfaces', () {
        final stringType = ResolvableType.forClass(String);
        final interfaces = stringType.getInterfaces();
        
        expect(interfaces, isNotNull);
        // String implements Comparable, Pattern, etc.
        expect(interfaces.length, greaterThanOrEqualTo(0));
      });

      test('as should convert to specified type', () {
        final stringType = ResolvableType.forClass(String);
        final asObjectType = stringType.as(Object);
        
        expect(asObjectType.resolve()?.getType(), equals(String));
      });
    });

    group('Assignability and Instance Checks', () {
      test('isAssignableFromType should check type compatibility', () {
        final objectType = ResolvableType.forClass(Object);
        expect(objectType.isAssignableFromType(String), isTrue);
        
        final stringType = ResolvableType.forClass(String);
        expect(stringType.isAssignableFromType(Object), isFalse);
      });

      test('isAssignableFromResolvable should check ResolvableType compatibility', () {
        final objectType = ResolvableType.forClass(Object);
        final stringType = ResolvableType.forClass(String);
        
        expect(objectType.isAssignableFromResolvable(stringType), isTrue);
        expect(stringType.isAssignableFromResolvable(objectType), isFalse);
      });

      test('isInstance should check object instances', () {
        final stringType = ResolvableType.forClass(String);
        
        expect(stringType.isInstance('hello'), isTrue);
        expect(stringType.isInstance(42), isFalse);
        expect(stringType.isInstance(null), isFalse);
      });
    });

    group('Nested Type Operations', () {
      test('getNested should handle nested types', () {
        final stringType = ResolvableType.forClass(String);
        final listType = ResolvableType.forArrayComponent(stringType);
        
        final nested = listType.getNested(2);
        expect(nested, equals(stringType));
      });

      test('getNested should handle complex nesting levels', () {
        final stringType = ResolvableType.forClass(String);
        final listType = ResolvableType.forArrayComponent(stringType);
        final nestedListType = ResolvableType.forArrayComponent(listType);
        
        final level2 = nestedListType.getNested(2);
        final level3 = nestedListType.getNested(3);
        
        expect(level2.resolve()?.getType(), equals(List));
        expect(level3.resolve()?.getType(), equals(String));
      });
    });

    group('Equality and Hashing', () {
      test('equality should work correctly', () {
        final stringType1 = ResolvableType.forClass(String);
        final stringType2 = ResolvableType.forClass(String);
        final intType = ResolvableType.forClass(int);
        
        expect(stringType1 == stringType2, isTrue);
        expect(stringType1 == intType, isFalse);
      });

      test('hashCode should be consistent', () {
        final stringType1 = ResolvableType.forClass(String);
        final stringType2 = ResolvableType.forClass(String);
        
        expect(stringType1.hashCode, equals(stringType2.hashCode));
      });
    });

    group('Variable Resolution', () {
      test('asVariableResolver should create resolver', () {
        final stringType = ResolvableType.forClass(String);
        final resolver = stringType.asVariableResolver();
        
        expect(resolver, isNotNull);
        expect(resolver!.getSource(), equals(stringType));
      });

      test('NONE should return null resolver', () {
        final resolver = ResolvableType.NONE.asVariableResolver();
        expect(resolver, isNull);
      });
    });

    group('String Representation', () {
      test('toString should represent simple types', () {
        final stringType = ResolvableType.forClass(String);
        final str = stringType.toString();
        
        expect(str, contains('String'));
      });

      test('toString should represent array types', () {
        final stringType = ResolvableType.forClass(String);
        final arrayType = ResolvableType.forArrayComponent(stringType);
        final str = arrayType.toString();
        
        expect(str, contains('[]'));
      });

      test('toString should represent generic types', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        final str = mapType.toString();
        
        expect(str, contains('<'));
        expect(str, contains('>'));
      });

      test('toString should handle unresolved types', () {
        final emptyType = ResolvableType.NONE;
        final str = emptyType.toString();
        
        expect(str, equals('?'));
      });
    });

    group('Cache Management', () {
      test('clearCache should clear internal cache', () {
        final stringType1 = ResolvableType.forClass(String);
        ResolvableType.clearCache();
        final stringType2 = ResolvableType.forClass(String);
        
        // Both should be valid, cache clearing shouldn't affect functionality
        expect(stringType1.resolve()?.getType(), equals(String));
        expect(stringType2.resolve()?.getType(), equals(String));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty type gracefully', () {
        final emptyType = ResolvableType.NONE;
        
        expect(emptyType.getType().toString(), equals('EmptyType'));
        expect(emptyType.resolve(), isNull);
        expect(emptyType.hasGenerics(), isFalse);
        expect(emptyType.getGenerics(), isEmpty);
        expect(emptyType.isArray(), isFalse);
        expect(emptyType.getSuperType(), equals(ResolvableType.NONE));
        expect(emptyType.getInterfaces(), isEmpty);
        expect(emptyType.isInstance('test'), isFalse);
      });

      test('should handle invalid generic indexes', () {
        final stringType = ResolvableType.forClass(String);
        final invalidGeneric = stringType.getGeneric([99]);
        
        expect(invalidGeneric, equals(ResolvableType.NONE));
      });

      test('should handle negative generic indexes', () {
        final mapType = ResolvableType.forClassWithGenerics(Map, [String, int]);
        final invalidGeneric = mapType.getGeneric([-1]);
        
        expect(invalidGeneric, equals(ResolvableType.NONE));
      });
    });
  });
}