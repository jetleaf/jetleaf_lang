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

import 'dart:async';

/// {@template runnable}
/// A simple contract for objects that can be executed.
///
/// The `Runnable` interface is inspired by Java's `Runnable`
/// and is commonly used to define a task or unit of work
/// that can be run, typically on a thread, executor, or lifecycle callback.
///
/// This interface is useful for generic task execution, background
/// processing, or deferred logic.
///
/// ### Example:
/// ```dart
/// class Task implements Runnable {
///   @override
///   FutureOr<void> run() {
///     print('Running a task...');
///   }
/// }
///
/// void execute(Runnable runnable) {
///   runnable.run();
/// }
///
/// void main() {
///   final task = Task();
///   execute(task); // Output: Running a task...
/// }
/// ```
/// {@endtemplate}
abstract interface class Runnable {
  /// {@template runnable_run}
  /// Executes the task encapsulated by this instance.
  ///
  /// Override this method with the logic that should be performed
  /// when the runnable is triggered.
  ///
  /// ### Example:
  /// ```dart
  /// class MyJob implements Runnable {
  ///   @override
  ///   FutureOr<void> run() {
  ///     print("Job started");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  FutureOr<void> run();
}