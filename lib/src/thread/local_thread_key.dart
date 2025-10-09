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

part of 'local_thread.dart';

/// {@template thread_local_key}
/// A unique key used to identify a specific [DartThreadLocal] instance
/// within a Dart [Zone]. Each [DartThreadLocal] gets its own unique ID.
/// {@endtemplate}
@internal
class LocalThreadKey {
  /// The unique integer ID for this key.
  final int id;
  LocalThreadKey._(this.id); // Private constructor

  static int _nextId = 0; // Counter for generating unique IDs

  /// Generates a new unique [LocalThreadKey].
  static LocalThreadKey generate() => LocalThreadKey._(_nextId++);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalThreadKey &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '_ThreadLocalKey(id: $id)';
}