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
import '../enums/compilation_mode.dart';
import '../properties/properties.dart';
import '../properties/system_properties.dart';
import 'system_detector.dart';

/// {@template default_system_environment_detector}
/// Default implementation of SystemEnvironmentDetector for standard Dart environments.
///
/// This detector analyzes the current Dart runtime environment using Platform APIs
/// and creates a properly configured DefaultSystemEnvironment instance.
///
/// Detection capabilities:
/// - Compilation mode analysis (debug/profile/release)
/// - AOT vs JIT runtime detection
/// - IDE launch detection via VM service flags
/// - .dill file execution detection
/// - Watch mode argument parsing
///
/// Example usage:
/// ```dart
/// final detector = StandardSystemDetector();
/// if (detector.canDetect()) {
///   final properties = detector.detect(args);
///   // Use properties...
/// }
/// ```
/// {@endtemplate}
class StandardSystemDetector implements SystemDetector {
  /// {@macro default_system_environment_detector}
  const StandardSystemDetector();

  @override
  Properties detect(List<String> args) {
    final compilationMode = _detectCompilationMode();
    final entrypoint = io.Platform.script.toFilePath();
    final runningFromDill = entrypoint.endsWith('.dill');
    final runningAot = _isRunningAot();
    final runningJit = !runningAot;
    final launchCommand = _buildLaunchCommand();
    final ideRunning = _isIdeRunning();
    final watchModeEnabled = _isWatchModeEnabled(args);

    return SystemPropertiesBuilder()
      .compilationMode(compilationMode)
      .runningFromDill(runningFromDill)
      .runningAot(runningAot)
      .runningJit(runningJit)
      .entrypoint(entrypoint)
      .launchCommand(launchCommand)
      .ideRunning(ideRunning)
      .watchModeEnabled(watchModeEnabled)
      .build();
  }

  @override
  bool canDetect() => true; // Can always detect standard Dart environments

  @override
  int getPriority() => 100; // Default priority

  /// Detects the current Dart compilation mode
  CompilationMode _detectCompilationMode() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return CompilationMode.release;
    } else if (const bool.fromEnvironment('dart.vm.profile')) {
      return CompilationMode.profile;
    } else {
      return CompilationMode.debug;
    }
  }

  /// Returns true if running with AOT compilation
  bool _isRunningAot() {
    final entry = io.Platform.script.toFilePath();

    if (entry.endsWith('.dill') || entry.endsWith('.dart')) {
      return false; // JIT environments
    }

    return io.Platform.version.toLowerCase().contains('precompiled');
  }

  /// Builds the launch command string
  String _buildLaunchCommand() {
    final executable = io.Platform.executable;
    final args = io.Platform.executableArguments.join(' ');
    return '$executable $args'.trim();
  }

  /// Returns true if launched from an IDE environment
  bool _isIdeRunning() {
    final args = io.Platform.executableArguments.join(' ').toLowerCase();
    return args.contains('--enable-vm-service') || 
           args.contains('--observe') ||
           args.contains('--debug');
  }

  /// Returns true if watch mode is enabled
  bool _isWatchModeEnabled(List<String> args) {
    return args.contains('--watch') || args.contains('-w');
  }
}