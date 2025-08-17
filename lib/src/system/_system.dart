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
import 'abstract_system_interface.dart';
import 'system_info.dart';

/// {@template default_system}
/// Default implementation of the [AbstractSystemInterface] interface used by JetLeaf.
///
/// This class encapsulates metadata about the runtime environment, including
/// whether the application was launched from a `.dill` file, the entrypoint path,
/// compilation mode, command-line invocation, dependency and configuration counts,
/// and development flags such as IDE or watch mode.
///
/// Typically constructed via [SystemDetector].
///
/// Example:
/// ```dart
/// final system = DefaultSystem(
///   isRunningFromDill: true,
///   entrypoint: '/bin/app.dill',
///   compilationMode: CompilationMode.release,
///   isIdeRun: false,
///   launchCommand: 'dart run bin/app.dart',
///   dependencyCount: 12,
///   configurationCount: 3,
///   watch: false,
/// );
/// ```
/// {@endtemplate}
class DefaultSystem implements AbstractSystemInterface {
  /// {@macro default_system}
  const DefaultSystem({
    required this.isRunningFromDill,
    required this.entrypoint,
    required this.mode,
    required this.isIdeRun,
    required this.launchCommand,
    required this.dependencyCount,
    required this.configurationCount,
    required this.watch,
    required this.isRunningWithAot,
    required this.isRunningWithJit,
  });

  @override
  final bool isRunningFromDill;

  @override
  final String entrypoint;

  @override
  final CompiledDesign mode;

  @override
  final bool isIdeRun;

  @override
  final String launchCommand;

  @override
  final int dependencyCount;

  @override
  final int configurationCount;

  @override
  final bool watch;

  @override
  final bool isRunningWithAot;

  @override
  final bool isRunningWithJit;

  /// Converts the current [AbstractSystemInterface] state into a [SystemInfo] snapshot
  /// for inspection or serialization.
  @override
  SystemInfo toSystemInfo() {
    return SystemInfo(
      mode: mode,
      isDill: isRunningFromDill,
      entrypoint: entrypoint,
      launchCommand: launchCommand,
      ideRun: isIdeRun,
      watch: watch,
      dependencies: dependencyCount,
      configurations: configurationCount,
      isRunningWithAot: isRunningWithAot,
      isRunningWithJit: isRunningWithJit,
    );
  }

  @override
  String toString() {
    return 'DefaultSystem(\n'
      'isRunningFromDill: $isRunningFromDill, \n'
      'entrypoint: $entrypoint, \n'
      'compilationMode: $mode, \n'
      'isIdeRun: $isIdeRun, \n'
      'launchCommand: $launchCommand, \n'
      'dependencyCount: $dependencyCount, \n'
      'configurationCount: $configurationCount, \n'
      'isRunningWithAot: $isRunningWithAot, \n'
      'isRunningWithJit: $isRunningWithJit, \n'
      'watch: $watch\n'
    ')';
  }
}