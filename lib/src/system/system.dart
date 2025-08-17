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

import 'dart:io' as io;

import 'package:meta/meta.dart';

import 'compiled_design.dart';
import 'abstract_system_interface.dart';
import 'system_info.dart';

/// {@template system_context}
/// Internal system context used by JetLeaf to store and delegate
/// environment details collected at startup.
///
/// This acts as a proxy to a [AbstractSystemInterface] instance, allowing global access
/// to system information like:
/// 
/// - Entrypoint path
/// - Compilation mode
/// - Dependency/configuration counts
/// - Whether the app is running from a `.dill` file
///
/// The actual [AbstractSystemInterface] instance is injected via the [system] setter
/// after detection. Accessing [System] before it is initialized will result in
/// a runtime error.
///
/// This class is marked `@internal` and is not intended for public use.
/// {@endtemplate}
@internal
class InternalSystemContext implements AbstractSystemInterface {
  late AbstractSystemInterface _system;

  /// {@macro system_context}
  InternalSystemContext._();

  /// Sets the backing [AbstractSystemInterface] implementation.
  ///
  /// Must be called during framework bootstrap before accessing
  /// any properties on [System].
  set system(AbstractSystemInterface system) {
    _system = system;
  }

  @override
  CompiledDesign get mode => _system.mode;

  @override
  int get configurationCount => _system.configurationCount;

  @override
  int get dependencyCount => _system.dependencyCount;

  @override
  String get entrypoint => _system.entrypoint;

  @override
  bool get isIdeRun => _system.isIdeRun;

  @override
  bool get isRunningFromDill => _system.isRunningFromDill;

  @override
  String get launchCommand => _system.launchCommand;

  @override
  SystemInfo toSystemInfo() => _system.toSystemInfo();

  @override
  bool get watch => _system.watch;

  @override
  bool get isRunningWithAot => _system.isRunningWithAot;

  @override
  bool get isRunningWithJit => _system.isRunningWithJit;

  /// Returns [stdout], the standard output stream.
  io.Stdout get out => io.stdout;

  /// Returns [stderr], the standard error stream.
  io.Stdout get err => io.stderr;

  /// Exit the Dart VM process immediately with the given exit code.
  ///
  /// This does not wait for any asynchronous operations to terminate nor execute
  /// `finally` blocks. Using [exit] is therefore very likely to lose data.
  ///
  /// Child processes are not explicitly terminated (but they may terminate
  /// themselves when they detect that their parent has exited).
  ///
  /// While debugging, the VM will not respect the `--pause-isolates-on-exit`
  /// flag if [exit] is called as invoking this method causes the Dart VM
  /// process to shutdown immediately. To properly break on exit, consider
  /// calling [debugger] from `dart:developer` or [Isolate.pause] from
  /// `dart:isolate` on [Isolate.current] to pause the isolate before
  /// invoking [exit].
  ///
  /// The handling of exit codes is platform specific.
  ///
  /// On Linux and OS X an exit code for normal termination will always
  /// be in the range `[0..255]`. If an exit code outside this range is
  /// set the actual exit code will be the lower 8 bits masked off and
  /// treated as an unsigned value. E.g. using an exit code of -1 will
  /// result in an actual exit code of 255 being reported.
  ///
  /// On Windows the exit code can be set to any 32-bit value. However
  /// some of these values are reserved for reporting system errors like
  /// crashes.
  ///
  /// Besides this the Dart executable itself uses an exit code of `254`
  /// for reporting compile time errors and an exit code of `255` for
  /// reporting runtime error (unhandled exception).
  ///
  /// Due to these facts it is recommended to only use exit codes in the
  /// range \[0..127\] for communicating the result of running a Dart
  /// program to the surrounding environment. This will avoid any
  /// cross-platform issues.
  Never exit(int exitCode) => io.exit(exitCode);
}

/// {@template std_extension}
/// Extension to simulate Java's `System.out` and `System.err` utilities in Dart.
///
/// Adds helper methods to [Stdout] for convenient output printing, such as:
/// - `println()`
/// - `printf()`
/// - `printErr()`
///
/// Example usage:
/// ```dart
/// stdout.println("Hello, world!");
/// stdout.printf('Welcome, %s. You have %d messages.\n', ['John', 5]);
/// stdout.printErr("Something went wrong.");
/// ```
/// {@endtemplate}
extension StdExtension on io.Stdout {
  /// Prints a string without a newline (like `System.out.print`)
  void print(String message) {
    write(message);
  }

  /// Prints a string followed by a newline (like `System.out.println`)
  void println([Object? message = '']) {
    writeln(message);
  }

  /// Prints a formatted string using Dart's string interpolation.
  /// Simulates Java-style `printf`.
  ///
  /// Example:
  /// ```dart
  /// stdout.printf('Hello, %s! You are %d years old.\n', ['John', 30]);
  /// ```
  void printf(String format, List<Object?> args) {
    String formatted = _format(format, args);
    write(formatted);
  }

  /// Prints to `stderr` with a newline.
  void printErr(Object? message) {
    io.stderr.writeln(message);
  }

  /// Formats a Java-style printf string with %s and %d placeholders.
  String _format(String format, List<Object?> args) {
    var buffer = StringBuffer();
    var parts = format.split(RegExp(r'(%[sd])'));
    var argIndex = 0;

    for (var part in parts) {
      if (part == '%s' || part == '%d') {
        if (argIndex < args.length) {
          buffer.write(args[argIndex]);
          argIndex++;
        } else {
          buffer.write(part);
        }
      } else {
        buffer.write(part);
      }
    }

    return buffer.toString();
  }
}

/// Returns a map of all platform-related properties similar to Java's System.getProperties().
///
/// Includes information such as:
/// - Dart version
/// - Operating system
/// - OS version
/// - Dart executable
/// - Locale
/// - Number of processors, etc.
Map<String, String> _properties = {
  'dart.version': io.Platform.version,
  'os.name': io.Platform.operatingSystem,
  'os.version': io.Platform.operatingSystemVersion,
  'locale.name': io.Platform.localeName,
  'executable': io.Platform.executable,
  'resolvedExecutable': io.Platform.resolvedExecutable,
  'numberOfProcessors': io.Platform.numberOfProcessors.toString(),
  'pathSeparator': io.Platform.pathSeparator,
  'script': io.Platform.script.toString(),
  'packageConfig': io.Platform.packageConfig ?? '',
  'executableArguments': io.Platform.executableArguments.join(' '),
  'version': io.Platform.version,
};

/// {@template system_extension}
/// Extension on [InternalSystemContext] that provides access to system-level
/// and environment-related properties similar to Java's `System.getProperties()`
/// and `System.getenv()`.
///
/// This includes metadata about the Dart runtime, host operating system,
/// environment variables, and more.
///
/// ### Example
/// ```dart
/// final properties = context.getProperties();
/// print(properties['os.name']); // e.g., 'macos'
///
/// final dartVersion = context.getProperty('dart.version');
/// print(dartVersion); // e.g., '3.3.0'
///
/// final env = context.getEnv();
/// print(env['PATH']);
///
/// final home = context.getEnvVar('HOME');
/// print(home);
/// ```
///
/// Useful in cross-platform utilities, diagnostics, and configuration loading.
/// {@endtemplate}
extension SystemExtension on InternalSystemContext {
  /// {@macro system_extension}
  ///
  /// Returns a map of all available system-related properties.
  ///
  /// This is similar to Java's `System.getProperties()` and may include:
  /// - `dart.version`
  /// - `dart.executable`
  /// - `os.name`
  /// - `os.version`
  /// - `os.arch`
  /// - `locale`
  /// - `cpu.cores`
  ///
  /// You can retrieve a specific property using [getProperty].
  Map<String, String> getProperties() => _properties;

  /// Returns the system property value for the given [name], or `null` if not found.
  ///
  /// ### Example
  /// ```dart
  /// final version = context.getProperty('dart.version');
  /// ```
  String? getProperty(String name) => _properties[name];

  /// {@macro system_extension}
  ///
  /// Returns a map of the environment variables accessible to the current
  /// Dart process.
  ///
  /// Equivalent to Java’s `System.getenv()`.
  ///
  /// ### Example
  /// ```dart
  /// final env = context.getEnv();
  /// print(env['PATH']);
  /// ```
  Map<String, String> getEnv() => io.Platform.environment;

  /// Returns the environment variable value for the given [name], or `null` if not defined.
  ///
  /// ### Example
  /// ```dart
  /// final userHome = context.getEnvVar('HOME');
  /// ```
  String? getEnvVar(String name) => io.Platform.environment[name];
}

/// {@macro system}
final InternalSystemContext System = InternalSystemContext._();