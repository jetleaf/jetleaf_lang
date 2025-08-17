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

import 'dart:io';

import 'print_stream.dart';

/// {@template console_print_stream}
/// A concrete implementation of [PrintStream] that writes to the console using [stdout].
///
/// `ConsolePrintStream` provides a high-level abstraction over `stdout`,
/// offering utility methods like `write`, `writeln`, `newline`, `flush`, and `close`.
///
/// By default, it uses `stdout.nonBlocking` for efficient, non-blocking output,
/// but you can also provide a custom [IOSink] to redirect output (e.g., to a file).
///
/// ---
///
/// ### 📦 Example Usage:
/// ```dart
/// final stream = ConsolePrintStream();
/// stream.write('Hello');
/// stream.writeln(' world');
/// stream.newline();
/// stream.flush();
/// await stream.close();
/// ```
///
/// ---
///
/// This class is useful when abstracting over console or file output in
/// logging systems, REPLs, shell interfaces, and testable I/O components.
///
/// {@endtemplate}
class ConsolePrintStream implements PrintStream {
  final IOSink _sink;

  /// {@macro console_print_stream}
  ///
  /// Creates a [ConsolePrintStream] that writes to [stdout] by default.
  ///
  /// You may optionally provide a custom [sink] (e.g., file or socket).
  ConsolePrintStream([IOSink? sink]) : _sink = sink ?? stdout.nonBlocking;

  @override
  void print(Object? obj) {
    _sink.write(obj?.toString() ?? 'null');
  }

  @override
  void println([Object? obj]) {
    _sink.writeln(obj?.toString() ?? 'null');
  }

  @override
  void newline() {
    _sink.writeln('');
  }

  @override
  void flush() {
    _sink.flush();
  }

  @override
  Future<void> close() {
    return _sink.close();
  }
}