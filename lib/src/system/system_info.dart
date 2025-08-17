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

/// {@template system_info}
/// A snapshot of the runtime system state at the time the JetLeaf application is launched.
///
/// This class is designed to be:
/// - **Immutable**: All fields are `final`.
/// - **Serializable**: Easily converted to a JSON structure via [toJson].
/// - **Diagnostic-friendly**: Useful for logging, debugging, and monitoring.
///
/// Typical use cases:
/// - Exporting system information at startup for debugging.
/// - Sending telemetry or performance snapshots.
/// - Displaying runtime metadata in a dashboard.
///
/// Example:
/// ```dart
/// final info = SystemInfo(
///   mode: CompilationMode.aot,
///   isDill: true,
///   entrypoint: 'build/main.dill',
///   launchCommand: 'dart run build/main.dill',
///   ideRun: false,
///   dependencies: 34,
///   configurations: 12,
///   watch: false,
/// );
///
/// print(info.toJson());
/// ```
/// {@endtemplate}
class SystemInfo {
  /// The compilation mode (e.g., [CompiledDesign.jit], [CompiledDesign.aot]).
  final CompiledDesign mode;

  /// Whether the application is running from a `.dill` file.
  final bool isDill;

  /// The entrypoint file used to launch the application.
  final String entrypoint;

  /// The full launch command used to start the app.
  final String launchCommand;

  /// Whether the app was launched from an IDE (vs CLI).
  final bool ideRun;

  /// The number of dependencies resolved during bootstrap.
  final int dependencies;

  /// The number of configurations loaded (e.g., environment profiles).
  final int configurations;

  /// Whether hot-reload/watch mode is enabled.
  final bool watch;

  /// Whether the application is running with AOT compiler.
  final bool isRunningWithAot;

  /// Whether the application is running with JIT compiler.
  final bool isRunningWithJit;

  /// {@macro system_info}
  const SystemInfo({
    required this.mode,
    required this.isDill,
    required this.entrypoint,
    required this.launchCommand,
    required this.ideRun,
    required this.dependencies,
    required this.configurations,
    required this.watch,
    required this.isRunningWithAot,
    required this.isRunningWithJit,
  });

  /// Serializes this object into a JSON map.
  ///
  /// Useful for exporting runtime metadata.
  Map<String, Object> toJson() => {
    'mode': mode.name,
    'isDill': isDill,
    'entrypoint': entrypoint,
    'launchCommand': launchCommand,
    'ideRun': ideRun,
    'dependencies': dependencies,
    'configurations': configurations,
    'watch': watch,
    'isRunningWithAot': isRunningWithAot,
    'isRunningWithJit': isRunningWithJit,
  };

  @override
  String toString() {
    return 'SystemInfo(\n'
      'mode: $mode, \n'
      'isDill: $isDill, \n'
      'entrypoint: $entrypoint, \n'
      'launchCommand: $launchCommand, \n'
      'ideRun: $ideRun, \n'
      'dependencies: $dependencies, \n'
      'configurations: $configurations, \n'
      'watch: $watch, \n'
      'isRunningWithAot: $isRunningWithAot, \n'
      'isRunningWithJit: $isRunningWithJit\n'
    ')';
  }
}