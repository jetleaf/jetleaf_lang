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

import '../exceptions.dart';

/// {@template flushable}
/// An object that can be flushed.
/// 
/// The flush method is invoked to write any buffered output to the underlying
/// stream or device. This is particularly important for buffered streams where
/// data may be held in memory until the buffer is full or explicitly flushed.
/// 
/// ## Example Usage
/// ```dart
/// class BufferedOutput implements Flushable {
///   final List<int> _buffer = [];
///   final OutputStream _output;
///   
///   BufferedOutput(this._output);
///   
///   void write(int byte) {
///     _buffer.add(byte);
///     if (_buffer.length >= 1024) {
///       flush(); // Auto-flush when buffer is full
///     }
///   }
///   
///   @override
///   Future<void> flush() async {
///     if (_buffer.isNotEmpty) {
///       await _output.write(_buffer);
///       _buffer.clear();
///     }
///   }
/// }
/// ```
/// 
/// {@endtemplate}
abstract class Flushable {
  /// {@macro flushable}
  Flushable();

  /// Flushes this stream by writing any buffered output to the underlying stream.
  /// 
  /// If the intended destination of this stream is an abstraction provided by
  /// the underlying operating system, for example a file, then flushing the
  /// stream guarantees only that bytes previously written to the stream are
  /// passed to the operating system for writing; it does not guarantee that
  /// they are actually written to a physical device such as a disk drive.
  /// 
  /// ## Implementation Note
  /// Implementations should ensure that all buffered data is written to the
  /// underlying stream. If the underlying stream is also [Flushable], it
  /// should be flushed as well to ensure data reaches its final destination.
  /// 
  /// ## Example
  /// ```dart
  /// @override
  /// Future<void> flush() async {
  ///   // Write buffered data to underlying stream
  ///   if (_buffer.isNotEmpty) {
  ///     await _underlyingStream.write(_buffer);
  ///     _buffer.clear();
  ///   }
  ///   
  ///   // Flush underlying stream if it's also flushable
  ///   if (_underlyingStream is Flushable) {
  ///     await (_underlyingStream as Flushable).flush();
  ///   }
  /// }
  /// ```
  /// 
  /// Throws [IOException] if an I/O error occurs during flushing.
  Future<void> flush();
}