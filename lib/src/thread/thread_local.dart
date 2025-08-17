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
import 'dart:isolate';

import 'package:meta/meta.dart';

import '../meta/annotations.dart';

part 'thread_local_key.dart';
part 'thread_local_registry.dart';
part 'thread_local_storage_bucket.dart';

/// {@template thread_local}
/// A Dart equivalent of Java's `ThreadLocal`, scoped to the current [Isolate].
///
/// `ThreadLocal<T>` provides isolate-local storage for values that are only
/// visible within the currently running [Isolate]. This is useful when you
/// want to maintain separate values across isolates, such as request-scoped
/// data in a concurrent server.
///
/// Internally, each isolate maintains its own value store via a
/// [ThreadLocalStorageBucket], so values set in one isolate will not affect
/// others.
///
/// ### Example
/// ```dart
/// final threadLocal = ThreadLocal<int>();
///
/// // In isolate A
/// threadLocal.set(42);
/// print(threadLocal.get()); // prints: 42
///
/// // In isolate B (separate execution context)
/// print(threadLocal.get()); // prints: null
/// ```
///
/// This API abstracts away the complexity of isolate-specific data
/// management by allowing you to interact with values as if they were
/// thread-local, even though Dart uses isolates instead of OS threads.
/// {@endtemplate}
@Generic(ThreadLocal)
final class ThreadLocal<T> {
  final ThreadLocalKey _key;

  /// {@macro thread_local}
  ThreadLocal() : _key = ThreadLocalKey.generate();

  /// {@template thread_local_initial_value}
  /// Returns the initial value for this [ThreadLocal].
  ///
  /// This method is called when a new [ThreadLocal] is created and no value
  /// has been set yet. The default implementation returns `null`, but you can
  /// override it to provide a custom initial value.
  /// {@endtemplate}
  @protected
  T? initialValue() {
    return null;
  }

  /// Returns the value associated with this [ThreadLocal] in the current [Isolate].
  ///
  /// Returns `null` if no value has been set yet.
  ///
  /// ### Example
  /// ```dart
  /// final local = ThreadLocal<String>();
  /// print(local.get()); // null
  ///
  /// local.set('hello');
  /// print(local.get()); // hello
  /// ```
  T? get() {
    final bucket = isolateLocalValueStore.getBucket<T>(Isolate.current, _key);
    return bucket.get();
  }

  /// Sets a value for this [ThreadLocal] in the current [Isolate].
  ///
  /// Overwrites any existing value for this isolate.
  ///
  /// ### Example
  /// ```dart
  /// final local = ThreadLocal<int>();
  /// local.set(100);
  /// print(local.get()); // 100
  /// ```
  void set(T value) {
    final bucket = isolateLocalValueStore.getBucket<T>(Isolate.current, _key);
    bucket.set(value);
  }

  /// Removes the value associated with this [ThreadLocal] in the current [Isolate].
  ///
  /// After removal, `get()` will return `null` until a new value is set.
  ///
  /// ### Example
  /// ```dart
  /// final local = ThreadLocal<String>();
  /// local.set('temp');
  /// print(local.get()); // temp
  ///
  /// local.remove();
  /// print(local.get()); // null
  /// ```
  void remove() {
    final bucket = isolateLocalValueStore.getBucket<T>(Isolate.current, _key);
    bucket.remove();
  }
}