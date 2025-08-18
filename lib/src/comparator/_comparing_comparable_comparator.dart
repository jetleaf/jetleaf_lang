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

/// {@template comparing_comparable_comparator}
/// A comparator that compares objects of type [T] based on a key of type [U]
/// that implements [Comparable]. The key is extracted from each object using
/// the provided [_keyExtractor] function.
///
/// This is a shortcut for comparing fields or derived values that naturally
/// support comparison without needing a custom [Comparator].
///
/// ---
///
/// ### 📌 Example
///
/// ```dart
/// class User {
///   final String username;
///   final int age;
///
///   User(this.username, this.age);
/// }
///
/// final byAge = Comparator.comparing<User, int>((user) => user.age);
///
/// final users = [
///   User('alice', 30),
///   User('bob', 25),
///   User('charlie', 40),
/// ];
///
/// users.sort(byAge.compare);
/// print(users.map((u) => u.username)); // [bob, alice, charlie]
/// ```
/// {@endtemplate}
@Generic(_ComparingComparableComparator)
class _ComparingComparableComparator<T, U extends Comparable<U>> extends Comparator<T> {
  /// Function used to extract the [Comparable] key from the object.
  final U Function(T) _keyExtractor;

  /// {@macro comparing_comparable_comparator}
  _ComparingComparableComparator(this._keyExtractor);

  @override
  int compare(T a, T b) {
    return _keyExtractor(a).compareTo(_keyExtractor(b));
  }
}