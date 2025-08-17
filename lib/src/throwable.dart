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

/// {@template throwable}
/// Base class for all throwable exceptions in JetLeaf.
///
/// This abstract type combines both [Error] and [Exception] so that all
/// JetLeaf errors can be caught using `on Exception`, `on Error`, or
/// the shared `on Throwable` type. This provides consistency across the
/// framework for handling system-level and application-level errors.
///
/// Extend this class for any custom exceptions that should be treated as
/// fatal or critical by the JetLeaf runtime.
/// {@endtemplate}
abstract interface class Throwable implements Error, Exception {
  /// The message associated with this exception.
  /// 
  /// It defaults to the string representation of the exception.
  String getMessage() => toString();

  /// The stack trace associated with this exception.
  /// 
  /// It defaults to [StackTrace.current] if not provided.
  StackTrace getStackTrace() => StackTrace.current;

  /// The cause of this exception, if any.
  /// 
  /// It defaults to the exception itself if not provided.
  Object getCause() => this;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

/// {@template runtime_exception}
/// Represents an unchecked runtime exception in JetLeaf.
///
/// A [RuntimeException] signals a system-level failure or application bug
/// that was not expected at runtime. This is commonly used for failures
/// such as invalid application state, misconfigurations, or internal
/// logic errors that are not recoverable.
///
/// It includes a [message], optional [cause], and a [stackTrace] (defaults
/// to [StackTrace.current] if not provided).
///
/// ### Example:
/// ```dart
/// throw RuntimeException('Invalid state', cause: SomeOtherError());
/// ```
/// {@endtemplate}
class RuntimeException extends Error implements Throwable {
  /// The message describing the error.
  final String message;

  /// The underlying cause of this exception, if any.
  final Object? cause;

  /// The associated stack trace.
  @override
  final StackTrace stackTrace;

  /// Creates a new [RuntimeException] with a message and [StackTrace].
  /// 
  /// {@macro runtime_exception}
  RuntimeException(this.message, {this.cause, StackTrace? stackTrace}) : stackTrace = stackTrace ?? StackTrace.current;

  @override
  String getMessage() => message;

  @override
  StackTrace getStackTrace() => stackTrace;

  @override
  Object getCause() => cause ?? this;

  @override
  String toString() {
    final buffer = StringBuffer('RuntimeException: $message\n$stackTrace');
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }

    return buffer.toString();
  }
}

/// {@template exception_extensions}
/// Extension on [Exception] to provide utility methods such as printing stack traces.
/// {@endtemplate}
extension ExceptionExtensions on Exception {
  /// Prints the exception and optional [StackTrace] if available.
  ///
  /// Usage:
  /// ```dart
  /// try {
  ///   throw FormatException('Invalid format');
  /// } catch (e) {
  ///   (e as Exception).printStackTrace();
  /// }
  /// ```
  void printStackTrace([StackTrace? stacktrace, bool useErrorPrint = false]) {
    if (useErrorPrint) {
      stderr.write(this);
    } else {
      print(this);
    }

    if (stacktrace != null) {
      if (useErrorPrint) {
        stderr.write(stacktrace);
      } else {
        print(stacktrace);
      }
    }
  }
}

/// {@template error_extensions}
/// Extension on [Error] for printing full stack traces conveniently.
/// {@endtemplate}
extension ErrorExtensions on Error {
  /// Prints the error along with its stack trace.
  void printStackTrace([bool useErrorPrint = false]) {
    if (useErrorPrint) {
      stderr.write(this);
    } else {
      print(this);
    }

    if (stackTrace != null) {
      if (useErrorPrint) {
        stderr.write(stackTrace);
      } else {
        print(stackTrace);
      }
    }
  }
}

/// {@template stacktrace_extensions}
/// Extension on [StackTrace] to print itself.
/// {@endtemplate}
extension StackTraceExtensions on StackTrace {
  /// Prints the [StackTrace] to console.
  void printStackTrace([bool useErrorPrint = false]) {
    if (useErrorPrint) {
      stderr.write(this);
    } else {
      print(this);
    }
  }
}

/// {@template runtime_exception_extensions}
/// Extension on [RuntimeException] to support pretty stack trace printing.
///
/// Usage:
/// ```dart
/// try {
///   throw RuntimeException('Oops!');
/// } catch (e) {
///   if (e is RuntimeException) {
///     e.printStackTrace();
///   }
/// }
/// ```
/// {@endtemplate}
extension RuntimeExceptionExtensions on RuntimeException {
  /// {@macro runtime_exception_extensions}
  void printStackTrace([bool useErrorPrint = false]) {
    if (useErrorPrint) {
      Error.safeToString(toString()).split('\n').forEach(print);
    } else {
      print(toString());
    }
  }
}

/// {@template throwable_extensions}
/// Extension on [Throwable] to support printing stack traces in a unified way.
/// 
/// Useful when catching general JetLeaf exceptions:
/// ```dart
/// catch (e) {
///   if (e is Throwable) {
///     e.printStackTrace();
///   }
/// }
/// ```
/// {@endtemplate}
extension ThrowableExtensions on Throwable {
  /// {@macro throwable_extensions}
  void printStackTrace([bool useErrorPrint = false]) {
    if (useErrorPrint) {
      Error.safeToString(toString()).split('\n').forEach(print);
    } else {
      print(toString());
    }
  }
}