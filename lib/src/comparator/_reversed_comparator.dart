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

part of 'comparator.dart';

/// {@template reversed_comparator}
/// A comparator that reverses the ordering defined by another [Comparator].
///
/// This class is used internally by `Comparator.reversed()` to produce a
/// comparator that inverts the sort order.
///
/// It works by flipping the argument order of the original comparator:
/// `original.compare(b, a)` instead of `original.compare(a, b)`.
///
/// ---
///
/// ### 📌 Example
///
/// ```dart
/// final ascending = Comparator.naturalOrder<int>();
/// final descending = ascending.reversed();
///
/// final numbers = [3, 1, 2];
/// numbers.sort(descending.compare);
/// print(numbers); // [3, 2, 1]
/// ```
/// {@endtemplate}
@Generic(_ReversedComparator)
class _ReversedComparator<T> extends Comparator<T> {
  /// The original comparator whose order is to be reversed.
  final Comparator<T> _original;

  /// {@macro reversed_comparator}
  _ReversedComparator(this._original);

  @override
  int compare(T a, T b) {
    return _original.compare(b, a); // Reverse the arguments to reverse order
  }
}