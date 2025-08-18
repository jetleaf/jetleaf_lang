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

/// {@template closeable}
/// An object that may hold resources until it is closed.
/// 
/// The [close] method is invoked to release resources that the object is
/// holding (such as open files). The close method is idempotent - calling
/// it multiple times should have no additional effect.
/// 
/// ## Example Usage
/// ```dart
/// class FileResource implements Closeable {
///   final File _file;
///   bool _closed = false;
///   
///   FileResource(String path) : _file = File(path);
///   
///   @override
///   Future<void> close() async {
///     if (_closed) return;
///     _closed = true;
///     // Perform cleanup
///   }
/// }
/// 
/// // Usage with try-finally
/// final resource = FileResource('data.txt');
/// try {
///   // Use resource
/// } finally {
///   await resource.close();
/// }
/// ```
/// 
/// {@endtemplate}
abstract class Closeable {
  /// {@macro closeable}
  Closeable();
  
  /// Closes this resource, relinquishing any underlying resources.
  /// 
  /// This method is invoked automatically when using try-with-resources
  /// patterns or should be called explicitly in a finally block.
  /// 
  /// The close method is idempotent - calling it multiple times should
  /// have no additional effect beyond the first call.
  /// 
  /// ## Implementation Note
  /// Implementations should ensure that resources are properly released
  /// even if an exception occurs during the close operation. It's recommended
  /// to mark the resource as closed before attempting cleanup operations.
  /// 
  /// ## Example
  /// ```dart
  /// @override
  /// Future<void> close() async {
  ///   if (_closed) return; // Idempotent
  ///   
  ///   try {
  ///     await _performCleanup();
  ///   } finally {
  ///     _closed = true; // Always mark as closed
  ///   }
  /// }
  /// ```
  /// 
  /// Throws [IOException] if an I/O error occurs during closing.
  Future<void> close();
}