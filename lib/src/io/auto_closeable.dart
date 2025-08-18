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

/// {@template auto_closeable}
/// An object that may hold resources (such as file or socket handles)
/// until it is closed.
/// 
/// The [close] method of an [AutoCloseable] object is called automatically 
/// when exiting a try-finally block or using Dart's resource management patterns.
/// This construction ensures prompt release, avoiding resource exhaustion 
/// exceptions and errors that may otherwise occur.
/// 
/// ## API Note
/// It is possible, and in fact common, for a base class to implement 
/// [AutoCloseable] even though not all of its subclasses or instances will 
/// hold releasable resources. For code that must operate in complete generality, 
/// or when it is known that the [AutoCloseable] instance requires resource release, 
/// it is recommended to use try-finally constructions or Dart's resource management patterns.
/// 
/// ## Example Usage
/// ```dart
/// class FileResource implements AutoCloseable {
///   final File _file;
///   bool _closed = false;
///   
///   FileResource(String path) : _file = File(path);
///   
///   String readContent() {
///     if (_closed) throw NoGuaranteeException('Resource is closed');
///     return _file.readAsStringSync();
///   }
///   
///   @override
///   void close() {
///     if (!_closed) {
///       _closed = true;
///       // Cleanup resources here
///       print('File resource closed');
///     }
///   }
/// }
/// 
/// // Usage with try-finally
/// void useResource() {
///   final resource = FileResource('example.txt');
///   try {
///     final content = resource.readContent();
///     print(content);
///   } finally {
///     resource.close();
///   }
/// }
/// 
/// // Usage with helper function
/// T useResourceSafely<T>(AutoCloseable resource, T Function() action) {
///   try {
///     return action();
///   } finally {
///     resource.close();
///   }
/// }
/// ```
/// 
/// {@endtemplate}
abstract class AutoCloseable {
  /// {@macro auto_closeable}
  AutoCloseable();

  /// Closes this resource, relinquishing any underlying resources.
  /// 
  /// This method is invoked automatically on objects managed by resource
  /// management patterns or try-finally blocks.
  /// 
  /// ## API Note
  /// While this interface method is declared to throw [Exception], 
  /// implementers are strongly encouraged to declare concrete implementations 
  /// of the [close] method to throw more specific exceptions, or to throw no 
  /// exception at all if the close operation cannot fail.
  /// 
  /// Cases where the close operation may fail require careful attention by 
  /// implementers. It is strongly advised to relinquish the underlying resources 
  /// and to internally mark the resource as closed, prior to throwing the exception. 
  /// The [close] method is unlikely to be invoked more than once and so this 
  /// ensures that the resources are released in a timely manner.
  /// 
  /// ## Implementation Note
  /// Unlike Java's AutoCloseable.close method, this [close] method is not 
  /// required to be idempotent. In other words, calling this [close] method 
  /// more than once may have some visible side effect. However, implementers 
  /// of this interface are strongly encouraged to make their [close] methods idempotent.
  /// 
  /// ## Example
  /// ```dart
  /// class DatabaseConnection implements AutoCloseable {
  ///   bool _closed = false;
  ///   
  ///   @override
  ///   void close() {
  ///     if (_closed) return; // Idempotent implementation
  ///     
  ///     try {
  ///       // Close database connection
  ///       _closeConnection();
  ///       _closed = true;
  ///     } catch (e) {
  ///       _closed = true; // Mark as closed even if cleanup fails
  ///       rethrow;
  ///     }
  ///   }
  ///   
  ///   void _closeConnection() {
  ///     // Implementation-specific cleanup
  ///   }
  /// }
  /// ```
  /// 
  /// Throws [Exception] if this resource cannot be closed.
  FutureOr<void> close();
}