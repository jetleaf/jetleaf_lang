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

part of 'thread_local.dart';

/// {@template isolate_local_value_store}
/// Internal store used by [ThreadLocal] to maintain isolate-local state.
///
/// Each isolate can have its own unique set of thread-local values. This class
/// maps a specific [Isolate] to its corresponding [ThreadLocalStorageBucket].
///
/// This store ensures that each [ThreadLocal] has a private, mutable
/// value scoped to the current isolate.
///
/// ### Example (Internal Usage)
/// ```dart
/// final isolate = Isolate.current;
/// final bucket = isolateLocalValueStore.getBucket<String>(isolate);
/// bucket.set('myLocalValue');
/// print(bucket.get()); // prints: myLocalValue
/// ```
///
/// This class is not intended for public use, but is essential in
/// supporting isolate-local thread-local variables.
/// {@endtemplate}
class _IsolateLocalValueStore {
  // Maps an Isolate to its ThreadLocalStorageBucket
  final Map<Isolate, Map<ThreadLocalKey, ThreadLocalStorageBucket<dynamic>>> _isolateValues = {};

  /// Returns the [ThreadLocalStorageBucket] associated with the given [isolate].
  ///
  /// If no bucket exists for that isolate, a new one is created and cached.
  ///
  /// This method is generic and returns a [ThreadLocalStorageBucket<T>], allowing
  /// type-safe value retrieval from the thread-local context.
  ///
  /// ### Example
  /// ```dart
  /// final isolate = Isolate.current;
  /// final bucket = isolateLocalValueStore.getBucket<int>(isolate);
  /// bucket.set(99);
  /// print(bucket.get()); // prints: 99
  /// ```
  ThreadLocalStorageBucket<T> getBucket<T>(Isolate isolate, ThreadLocalKey key) {
    final isolateMap = _isolateValues.putIfAbsent(isolate, () => <ThreadLocalKey, ThreadLocalStorageBucket<dynamic>>{});
    return isolateMap.putIfAbsent(key, () => ThreadLocalStorageBucket<T>(null, isolate)) as ThreadLocalStorageBucket<T>;
  }
}

/// {@template isolate_local_value_store_instance}
/// Singleton instance of the [_IsolateLocalValueStore].
///
/// Used internally by [ThreadLocal] to retrieve per-isolate buckets.
/// {@endtemplate}
final isolateLocalValueStore = _IsolateLocalValueStore();