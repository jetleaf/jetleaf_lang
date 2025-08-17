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

import '_system.dart';
import 'compiled_design.dart';
import 'abstract_system_interface.dart';
import 'system.dart';
import 'system_detector.dart';

/// {@template system_detector}
/// Discovers system-level data for JetLeaf and
/// creates a fully resolved [AbstractSystemInterface] instance.
///
/// This class is used internally during application bootstrap
/// to populate a [AbstractSystemInterface] instance that contains runtime
/// metadata such as:
/// - Compilation mode (debug, profile, release)
/// - Whether running from a `.dill` file
/// - Launch command
/// - Entrypoint
/// - IDE detection
/// - Watch mode status
///
/// Typically used via:
/// ```dart
/// final system = DefaultSystemDetector().detect(args);
/// ```
/// {@endtemplate}
class DefaultSystemDetector implements SystemDetector {
  /// {@macro system_detector}
  const DefaultSystemDetector();

  /// Detects the runtime environment and returns a [AbstractSystemInterface] instance.
  ///
  /// The returned [AbstractSystemInterface] contains key runtime information such as:
  /// - Whether the app is running from a `.dill` file
  /// - The Dart compilation mode
  /// - The launch command
  /// - IDE vs CLI launch
  /// - Watch mode status (if `--watch` was passed)
  ///
  /// [args] should be the raw CLI arguments passed to `main()`.
  @override
  AbstractSystemInterface detect(List<String> args) {
    final mode = _detectCompilationMode();
    final command = Platform.executableArguments.join(' ');
    final entry = Platform.script.toFilePath();
    final isDill = entry.endsWith('.dill');
    final isRunningWithAot = const bool.fromEnvironment('dart.vm.product');

    // Placeholder values for dependency/config counts.
    final result = DefaultSystem(
      isRunningFromDill: isDill,
      entrypoint: entry,
      mode: mode,
      isIdeRun: _detectIdeRun(),
      launchCommand: command,
      dependencyCount: 0,
      configurationCount: 0,
      watch: args.contains('--watch'),
      isRunningWithAot: isRunningWithAot,
      isRunningWithJit: !isRunningWithAot,
    );

    System.system = result;
    return result;
  }

  /// Detects the current Dart compilation mode.
  ///
  /// Returns one of [CompiledDesign.release], [CompiledDesign.profile],
  /// or [CompiledDesign.debug] based on VM environment flags.
  static CompiledDesign _detectCompilationMode() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return CompiledDesign.release;
    } else {
      return CompiledDesign.debug;
    }
  }

  /// Returns `true` if the application was launched from an IDE.
  ///
  /// This is inferred by checking for VM service flags like
  /// `--enable-vm-service` or `--observe`.
  static bool _detectIdeRun() {
    final args = Platform.executableArguments.join(' ').toLowerCase();
    return args.contains('--enable-vm-service') || args.contains('--observe');
  }
}