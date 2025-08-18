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
import 'package:jetleaf_lang/src/meta/type_discovery.dart';
import 'package:test/test.dart';

import '../_dependencies.dart';

void main() {
  setUpAll(() async {
    TypeDiscovery.clearCaches();
    await setupRuntime();
    return Future<void>.value();
  });

  group('ClassExtension', () {
    test('should return Class for primitive types', () {
      // Numbers
      expect(42.getClass(), isA<Class>());
      expect(3.14.getClass(), isA<Class>());
      
      // Strings
      expect('hello'.getClass(), isA<Class>());
      expect(''.getClass(), isA<Class>());
      
      // Booleans
      expect(true.getClass(), isA<Class>());
      expect(false.getClass(), isA<Class>());
    });

    test('should return Class for collections', () {
      // Lists
      expect([].getClass(), isA<Class>());
      expect([1, 2, 3].getClass(), isA<Class>());
      expect(['a', 'b'].getClass(), isA<Class>());
      
      // Maps
      expect({}.getClass(), isA<Class>());
      expect({'key': 'value'}.getClass(), isA<Class>());
      expect({1: 'one', 2: 'two'}.getClass(), isA<Class>());
      
      // Sets
      expect(<dynamic>{}.getClass(), isA<Class>());
      expect({1, 2, 3}.getClass(), isA<Class>());
    });

    test('should return Class for records', () {
      // Simple records
      expect(().getClass(), isA<Class>());
      expect((1, 'a').getClass(), isA<Class>());
      expect((a: 1, b: 'two').getClass(), isA<Class>());
    });

    test('should return Class for custom objects', () {
      final instance = TestClass();
      
      expect(instance.getClass(), isA<Class>());
      expect(instance.clazz, isA<Class>());
    });

    test('should return Class for null (via Null extension)', () {
      Object? nullObj = "";
      expect(nullObj.getClass(), isA<Class>());
    });

    test('should return correct type names', () {
      expect(42.clazz.getType(), equals(int));
      expect('test'.clazz.getType(), equals(String));
      expect([].clazz.getType(), equals(List<dynamic>));
      expect(<int>[1, 2, 3].clazz.getType(), equals(List<dynamic>));
      expect(<int>[1, 2, 3].clazz.componentType(), equals(Class.of<int>()));
      expect({}.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect({'key': 'value'}.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect({'key': 'value'}.clazz.componentType(), equals(Class.of<String>()));
      expect({'key': 'value'}.clazz.keyType(), equals(Class.of<String>()));
    });

    test('should work with generic types', () {
      final list = <String>["Hello"];
      final map = <int, String>{1: "One", 2: "Two", 3: "Three"};
      
      expect(list.clazz.getType(), equals(List<dynamic>));
      expect(list.clazz.componentType(), equals(Class.of<String>()));
      expect(map.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect(map.clazz.componentType(), equals(Class.of<String>()));
      expect(map.clazz.keyType(), equals(Class.of<int>()));
    });

    test('should return same Class for same runtime type', () {
      final list1 = [];
      final list2 = [];
      
      expect(list1.clazz, equals(list2.clazz));
    });

    test('should differentiate between different generic types', () {
      final listInt = <int>[1, 2, 3];
      final listString = <String>["Yu", "Come", "Back"];
      expect(listInt.clazz.getType(), equals(List<dynamic>));
      expect(listString.clazz.getType(), equals(List<dynamic>));
      expect(listInt.clazz.componentType()?.getType(), equals(int));
      expect(listString.clazz.componentType()?.getType(), equals(String));
    });

    test('should handle nested generic types', () {
      final complexMap = <String, List<int>>{"Hello": [1, 2, 3], "World": [4, 5, 6]};
      expect(complexMap.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect(complexMap.clazz.componentType()?.getType(), equals(List<dynamic>));
      expect(complexMap.clazz.keyType()?.getType(), equals(String));
      expect(complexMap.clazz.componentType()?.componentType()?.getType(), equals(int));
      
      final nestedList = <List<Map<int, String>>>[
        <Map<int, String>>[
          {1: "One", 2: "Two", 3: "Three"},
          {4: "Four", 5: "Five", 6: "Six"}
        ]
      ];
      expect(nestedList.clazz.getType(), equals(List<dynamic>));
      expect(nestedList.clazz.componentType()?.getType(), equals(List<dynamic>));
      expect(nestedList.clazz.componentType()?.componentType()?.getType(), equals(Map<dynamic, dynamic>));
      expect(nestedList.clazz.componentType()?.componentType()?.keyType()?.getType(), equals(int));
      expect(nestedList.clazz.componentType()?.componentType()?.componentType()?.getType(), equals(String));
    });

    test('clazz getter should be equivalent to getClass()', () {
      final obj = {'key': 'value'};
      expect(obj.clazz, equals(obj.getClass()));
    });

    test('should handle custom generic types', () {
      final intBox = Box(42);
      final stringBox = Box('hello');
      
      expect(intBox.clazz.getType(), equals(Box<dynamic>));
      expect(intBox.clazz.componentType()?.getType(), equals(int));
      expect(stringBox.clazz.getType(), equals(Box<dynamic>));
      expect(stringBox.clazz.componentType()?.getType(), equals(String));
    });
  });

  group('ClassExtension Edge Cases', () {
    test('should handle empty collections', () {
      expect(["Hello"].clazz.getType(), equals(List<dynamic>));
      expect(["Hello"].clazz.componentType()?.getType(), equals(String));
      expect(<int>[1,2,3].clazz.getType(), equals(List<dynamic>));
      expect(<int>[1,2,3].clazz.componentType()?.getType(), equals(int));
      expect(<dynamic,dynamic>{}.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect(<dynamic,dynamic>{}.clazz.componentType()?.getType(), equals(Object));
      expect(<String, int>{"key": 1}.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect(<String, int>{"key": 1}.clazz.componentType()?.getType(), equals(int));
      expect(<String, int>{"key": 1}.clazz.keyType()?.getType(), equals(String));
    });

    test('should handle very large objects', () {
      final largeList = List.filled(1000000, 'item');
      expect(largeList.clazz.getType(), equals(List<dynamic>));
      expect(largeList.clazz.componentType()?.getType(), equals(String));
      
      final largeMap = {for (var i = 0; i < 1000; i++) i: 'value$i'};
      expect(largeMap.clazz.getType(), equals(Map<dynamic, dynamic>));
      expect(largeMap.clazz.componentType()?.getType(), equals(String));
      expect(largeMap.clazz.keyType()?.getType(), equals(int));
    });

    test('should handle objects with circular references', () {
      final node1 = Node();
      final node2 = Node();
      node1.next = node2;
      node2.next = node1;
      
      expect(node1.clazz.getType(), equals(Node));
      expect(node2.clazz.getType(), equals(Node));
    });

    test('should handle mixins', () {
      expect(TestClass().clazz.getType(), equals(TestClass));
    });

    test('should handle enums', () {
      expect(TestEnum.a.clazz.getType(), equals(TestEnum));
    });
  });
}

class Node {
  Node? next;
}
mixin TestMixin {}
class TestClass with TestMixin {}
enum TestEnum { a, b, c }
typedef StringCallback = void Function(String);

@Generic(Box)
class Box<T> {
  final T value;
  Box(this.value);
}