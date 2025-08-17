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

import '../annotations.dart';
import '../resolvable_type.dart';

part '_parameterized_type_reference.dart';

/// {@template parameterized_type_reference}
/// A runtime type reference for capturing and working with parameterized/generic types.
///
/// This class solves the Dart limitation where `List<String>.runtimeType` loses
/// generic type arguments. By creating a subclass (typically anonymous), the type
/// information is preserved at runtime.
///
/// ## Usage
///
/// ### Basic Usage
/// ```dart
/// final listRef = ParameterizedTypeReference<List<String>>();
/// print(listRef.getType()); // List<String>
/// ```
///
/// ### With Complex Types
/// ```dart
/// final complexRef = ParameterizedTypeReference<Map<String, List<int>>>();
/// print(complexRef.getType()); // Map<String, List<int>>
/// ```
///
/// ### With ResolvableType
/// ```dart
/// final ref = ParameterizedTypeReference<Set<double>>();
/// final resolvable = ref.getResolvableType();
/// print(resolvable.genericParameters[0].type); // double
/// ```
///
/// ## Implementation Notes
/// - Always create as an anonymous subclass using the factory constructor
/// - The actual type capture happens through Dart's type inference
/// - Works with nested generic types (e.g., `Map<String, List<int>>`)
/// {@endtemplate}
@Generic(ParameterizedTypeReference)
abstract class ParameterizedTypeReference<T> {
  /// Creates a type reference that captures the generic type parameter.
  ///
  /// The factory constructor returns an anonymous subclass that preserves
  /// the generic type information at runtime.
  ///
  /// Example:
  /// ```dart
  /// // Correct - creates anonymous subclass
  /// final goodRef = ParameterizedTypeReference<Map<String, dynamic>>();
  ///
  /// // Incorrect - loses type information
  /// final badRef = _ParameterizedTypeReference<Map<String, dynamic>>();
  /// ```
  /// 
  /// {@macro parameterized_type_reference}
  factory ParameterizedTypeReference() => _ParameterizedTypeReference<T>();

  /// {@template parameterized_type_reference_get_type}
  /// Returns the captured generic type with all type arguments preserved.
  ///
  /// This is the primary method for accessing the runtime type information
  /// that would otherwise be lost with standard `runtimeType` checks.
  ///
  /// Example:
  /// ```dart
  /// final ref = ParameterizedTypeReference<Future<String>>();
  /// Type t = ref.getType(); // Future<String>
  /// ```
  /// {@endtemplate}
  Type getType();

  /// {@template parameterized_type_reference_get_resolvable}
  /// Returns a [ResolvableType] representation of the captured type.
  ///
  /// This provides additional capabilities for working with the type:
  /// - Accessing generic parameters
  /// - Checking assignability
  /// - Type resolution
  ///
  /// Example:
  /// ```dart
  /// final ref = ParameterizedTypeReference<List<num>>();
  /// final resolvable = ref.getResolvableType();
  ///
  /// print(resolvable.genericParameters.length); // 1
  /// print(resolvable.genericParameters[0].type); // num
  /// ```
  /// {@endtemplate}
  ResolvableType getResolvableType() => ResolvableType.forClass(getType());
}