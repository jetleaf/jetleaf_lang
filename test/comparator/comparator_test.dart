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

class IntComparator extends Comparator<int> {
  @override
  int compare(int a, int b) => a.compareTo(b);
}

void main() {
  group('Comparator', () {
    test('naturalOrder sorts ascending', () {
      final comp = Comparator.naturalOrder<num>();
      final list = [5, 3, 8, 1];
      list.sort(comp.compare);
      expect(list, [1, 3, 5, 8]);
    });

    test('reverseOrder sorts descending', () {
      final comp = Comparator.reverseOrder<num>();
      final list = [5, 3, 8, 1];
      list.sort(comp.compare);
      expect(list, [8, 5, 3, 1]);
    });

    test('reversed() inverts order', () {
      final base = IntComparator();
      final reversed = base.reversed();
      expect(reversed.compare(1, 2), 1);
      expect(reversed.compare(2, 1), -1);
      expect(reversed.compare(2, 2), 0);
    });

    test('thenComparing uses second when first is equal', () {
      final primary = Comparator.comparing<String, num>((s) => s.length);
      final secondary = Comparator.naturalOrder<String>();
      final combined = primary.thenComparing(secondary);

      final list = ['bb', 'aa', 'a', 'c'];
      list.sort(combined.compare);
      expect(list, ['a', 'c', 'aa', 'bb']);
    });

    test('thenComparingComparable works with key extractor', () {
      final primary = Comparator.comparing<String, num>((s) => s.length);
      final combined = primary.thenComparingComparable((s) => s);

      final list = ['bb', 'aa', 'a', 'c'];
      list.sort(combined.compare);
      expect(list, ['a', 'c', 'aa', 'bb']);
    });

    test('comparingWith with custom comparator', () {
      final reverseLength = Comparator.reverseOrder<num>();
      final comp = Comparator.comparingWith<String, num>((s) => s.length, reverseLength);

      final list = ['a', 'bb', 'ccc', 'dddd'];
      list.sort(comp.compare);
      expect(list, ['dddd', 'ccc', 'bb', 'a']);
    });
  });
}