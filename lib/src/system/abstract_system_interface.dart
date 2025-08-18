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

import 'compiled_design.dart';
import 'system_info.dart';

/// {@template system}
/// Represents runtime system-level metadata for the JetLeaf framework.
///
/// The [AbstractSystemInterface] abstraction captures diagnostic and environmental information
/// about the running application. This includes the entrypoint, compilation mode,
/// launch command, IDE/debug status, and dependency/configuration statistics.
///
/// The framework can use this data to introspect the state of the runtime
/// and provide detailed logs, telemetry, and diagnostics.
///
/// Example usage:
/// ```dart
/// print(System.toSystemInfo());
/// ```
/// {@endtemplate}
abstract interface class AbstractSystemInterface {
  /// {@macro system}
  const AbstractSystemInterface();

  /// Returns the current Dart VM compilation mode.
  ///
  /// Typically [CompiledDesign.debug], [CompiledDesign.profile], or [CompiledDesign.release].
  CompiledDesign get mode;

  /// Whether the application is running from a precompiled `.dill` file.
  ///
  /// This is often `true` in production builds or bootstrapped JetLeaf apps.
  bool get isRunningFromDill;

  /// Whether the application is running with AOT compiler.
  /// 
  /// This is often `true` in production builds or bootstrapped JetLeaf apps.
  bool get isRunningWithAot;

  /// Whether the application is running with JIT compiler.
  /// 
  /// This is often `true` in development builds or bootstrapped JetLeaf apps.
  bool get isRunningWithJit;

  /// The full path of the application's entry file.
  ///
  /// May point to a `.dart` source file or `.dill` binary.
  String get entrypoint;

  /// The original command used to launch the Dart application.
  ///
  /// For example: `dart run build/main.dill`.
  String get launchCommand;

  /// Whether the application was launched via an IDE in debug/observe mode.
  ///
  /// JetLeaf uses this to determine if features like hot reload or debug logging should be enabled.
  bool get isIdeRun;

  /// The number of dependencies resolved in the current application context.
  ///
  /// Useful for startup diagnostics and dependency graph analysis.
  int get dependencyCount;

  /// The number of JetLeaf configuration classes discovered (e.g. `@Configuration`).
  ///
  /// This value is populated after the application context has been refreshed.
  int get configurationCount;

  /// Whether the application is in watch mode (i.e., file changes are monitored).
  ///
  /// Useful for tooling or CLI runners that support live reload.
  bool get watch;

  /// Returns a full [SystemInfo] snapshot describing this runtime environment.
  SystemInfo toSystemInfo();

  @override
  String toString() {
    return 'System(\n'
      'entrypoint: $entrypoint, \n'
      'compilationMode: $mode, \n'
      'isRunningWithAot: $isRunningWithAot, \n'
      'isRunningWithJit: $isRunningWithJit, \n'
      'isIdeRun: $isIdeRun, \n'
      'launchCommand: $launchCommand, \n'
      'dependencyCount: $dependencyCount, \n'
      'configurationCount: $configurationCount\n'
      'watch: $watch\n'
    ')';
  }
}