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

import 'package:test/test.dart';
import 'package:jetleaf_lang/jetleaf_lang.dart';

void main() {
  group('StreamBuilder', () {
    test('adds single elements and builds a stream', () {
      final builder = StreamBuilder<String>();
      builder.add('Hello');
      builder.add('World');

      final stream = builder.build();
      expect(stream.toList(), ['Hello', 'World']);
    });

    test('adds multiple elements with addAll and builds', () {
      final builder = StreamBuilder<int>();
      builder.addAll([1, 2, 3]);

      final stream = builder.build();
      expect(stream.toList(), [1, 2, 3]);
    });

    test('throws when adding after build', () {
      final builder = StreamBuilder<double>();
      builder.addAll([1.0, 2.0]);
      builder.build();

      expect(() => builder.add(3.0), throwsA(isA<NoGuaranteeException>()));
    });

    test('throws when addAll after build', () {
      final builder = StreamBuilder<int>();
      builder.add(1);
      builder.build();

      expect(() => builder.addAll([2, 3]), throwsA(isA<NoGuaranteeException>()));
    });

    test('throws when calling build more than once', () {
      final builder = StreamBuilder<String>();
      builder.add('Hi');
      builder.build();

      expect(() => builder.build(), throwsA(isA<NoGuaranteeException>()));
    });

    test('empty build returns empty stream', () {
      final builder = StreamBuilder<String>();
      final stream = builder.build();

      expect(stream.toList(), isEmpty);
    });

    test('order of elements is preserved', () {
      final builder = StreamBuilder<int>();
      builder.add(10).add(5).add(7);
      final stream = builder.build();

      expect(stream.toList(), [10, 5, 7]);
    });
  });
}