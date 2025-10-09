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

import '../properties/properties.dart';

/// {@template system_detector}
/// Strategy interface for detecting and creating SystemEnvironment instances.
///
/// This interface defines the contract for environment detection strategies. Different
/// implementations can provide various detection mechanisms for different
/// deployment scenarios.
///
/// The detector is responsible for:
/// - Analyzing runtime environment
/// - Detecting compilation modes
/// - Identifying execution context
/// - Creating configured [Properties] instances
///
/// Example usage:
/// ```dart
/// final detector = DefaultSystemDetector();
/// final properties = detector.detect(args);
/// ```
/// {@endtemplate}
abstract interface class SystemDetector {
  /// {@macro system_detector}
  const SystemDetector();

  /// Detects the current system environment and returns a configured instance
  ///
  /// [args] are the command-line arguments passed to the application
  /// Returns a fully configured [Properties] instance
  Properties detect(List<String> args);

  /// Returns true if this detector can handle the current environment
  bool canDetect();

  /// Returns the priority of this detector (higher values take precedence)
  int getPriority() => 0;
}