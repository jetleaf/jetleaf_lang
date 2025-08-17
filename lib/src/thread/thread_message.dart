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

part of 'thread.dart';

/// {@template thread_message}
/// Wrapper message passed to the Isolate's entry point function.
///
/// Contains a [SendPort] for replying and an optional [data] payload.
///
/// This message is automatically constructed by [Thread.start()].
///
/// Example usage:
/// ```dart
/// void entry(ThreadMessage message) {
///   final reply = message.replyPort;
///   final input = message.data;
///   // process...
///   reply.send('done');
/// }
/// ```
/// {@endtemplate}
class ThreadMessage {
  /// Port used to send messages back to the main thread.
  final SendPort replyPort;

  /// Initial message or payload sent to the isolate.
  final dynamic data;

  /// {@macro thread_message}
  ThreadMessage(this.replyPort, this.data);
}