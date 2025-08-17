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

import 'dart:async' show FutureOr;

import '../io/auto_closeable.dart';

/// {@template try_with_action}
/// A function that performs an operation using a given [resource].
///
/// It can be synchronous or asynchronous, and is used in conjunction
/// with the `tryWith` utility to ensure proper resource cleanup.
///
/// Example:
/// ```dart
/// Future<void> logToFile(MyFile file) async {
///   await file.write('Hello, world');
/// }
/// ```
/// {@endtemplate}
typedef TryWithAction<T> = FutureOr<void> Function(T resource);

/// {@template try_with}
/// Utility for automatically closing a resource after use.
///
/// Ensures that the [resource] is closed using `resource.close()`
/// regardless of whether the [action] throws or completes normally.
///
/// This is similar in spirit to Java's `try-with-resources` construct.
///
/// Example usage:
/// ```dart
/// class MyFile extends AutoCloseable {
///   Future<void> write(String content) async {
///     print('Writing: $content');
///   }
///
///   @override
///   Future<void> close() async {
///     print('File closed');
///   }
/// }
///
/// void main() async {
///   final file = MyFile();
///   await tryWith(file, (f) async {
///     await f.write('Hello, world');
///   });
///   // Output:
///   // Writing: Hello, world
///   // File closed
/// }
/// ```
/// {@endtemplate}
Future<void> tryWith<T extends AutoCloseable>(T resource, TryWithAction<T> action) async {
  try {
    await action(resource);
  } finally {
    await resource.close();
  }
}