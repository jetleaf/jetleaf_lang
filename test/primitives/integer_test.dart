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
  group('Integer Tests', () {
    test('constructor and value access', () {
      Integer a = Integer(42);
      expect(a.value, equals(42));
    });

    test('parseInt with different radix', () {
      expect(Integer.parseInt("42").value, equals(42));
      expect(Integer.parseInt("1010", 2).value, equals(10));
      expect(Integer.parseInt("FF", 16).value, equals(255));
    });

    test('valueOf', () {
      Integer a = Integer.valueOf(100);
      expect(a.value, equals(100));
    });

    test('constants', () {
      expect(Integer.MAX_VALUE, equals(2147483647));
      expect(Integer.MIN_VALUE, equals(-2147483648));
    });

    test('arithmetic operations', () {
      Integer a = Integer(10);
      Integer b = Integer(5);
      
      expect((a + b).value, equals(15));
      expect((a - b).value, equals(5));
      expect((a * b).value, equals(50));
      expect((a ~/ b).value, equals(2));
      expect((a % b).value, equals(0));
      expect((-a).value, equals(-10));
    });

    test('comparison operations', () {
      Integer a = Integer(10);
      Integer b = Integer(5);
      Integer c = Integer(10);
      
      expect(a > b, isTrue);
      expect(a < b, isFalse);
      expect(a >= c, isTrue);
      expect(a <= c, isTrue);
      expect(a.compareTo(b), equals(1));
      expect(a.compareTo(c), equals(0));
      expect(b.compareTo(a), equals(-1));
    });

    test('bitwise operations', () {
      Integer a = Integer(12); // 1100
      Integer b = Integer(10); // 1010
      
      expect((a & b).value, equals(8)); // 1000
      expect((a | b).value, equals(14)); // 1110
      expect((a ^ b).value, equals(6)); // 0110
      expect((~a).value, equals(~12));
    });

    test('utility methods', () {
      Integer a = Integer(-42);
      Integer b = Integer(42);
      
      expect(a.abs().value, equals(42));
      expect(b.isEven, isTrue);
      expect(Integer(43).isOdd, isTrue);
      expect(a.isNegative, isTrue);
      expect(b.isNegative, isFalse);
    });

    test('toString with radix', () {
      Integer a = Integer(255);
      expect(a.toString(), equals('255'));
      expect(a.toRadixString(16), equals('ff'));
      expect(a.toRadixString(2), equals('11111111'));
    });

    test('equality and hashCode', () {
      Integer a = Integer(42);
      Integer b = Integer(42);
      Integer c = Integer(43);
      
      expect(a == b, isTrue);
      expect(a == c, isFalse);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('static utility methods', () {
      expect(Integer.max(10, 5), equals(10));
      expect(Integer.min(10, 5), equals(5));
    });

    test('conversion methods', () {
      Integer a = Integer(42);
      expect(a.toDouble(), equals(42.0));
    });
  });
}