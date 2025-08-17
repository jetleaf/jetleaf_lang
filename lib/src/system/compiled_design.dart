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

/// {@template compiled_design}
/// Enumeration of Dart compilation modes.
///
/// Dart supports multiple runtime modes, each optimized for a different use case:
///
/// - [debug]: Used during development. Provides hot reload and assertions.
/// - [profile]: Used to analyze performance with minimal optimizations.
/// - [release]: Fully optimized mode for production deployment.
///
/// JetLeaf uses this enum to capture how the application was compiled and run
/// at startup time, typically via [SystemDetector].
///
/// Example:
/// ```dart
/// if (mode == CompilationMode.release) {
///   print('Production mode enabled');
/// }
/// ```
/// {@endtemplate}
enum CompiledDesign {
  /// {@macro compiled_design}
  debug,

  /// {@macro compiled_design}
  release;

  @override
  String toString() => name;
}