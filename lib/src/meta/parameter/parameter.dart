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

import '../../declaration/declaration.dart';
import '../annotation/annotation.dart';
import '../class/class.dart';
import '../protection_domain/protection_domain.dart';
import '../meta.dart';

part '_parameter.dart';

/// {@template parameter_interface}
/// Provides reflective access to method/constructor parameter metadata.
///
/// This interface enables inspection of:
/// - Parameter types and positions
/// - Optional/required status
/// - Named vs positional parameters
/// - Default values
/// - Annotations
///
/// {@template parameter_interface_features}
/// ## Key Features
/// - Type-safe parameter type access
/// - Default value inspection
/// - Parameter kind detection (named/positional)
/// - Signature generation
/// - Annotation support
///
/// ## Implementation Notes
/// Concrete implementations typically wrap platform-specific reflection objects
/// while providing this uniform interface.
/// {@endtemplate}
///
/// {@template parameter_interface_example}
/// ## Example Usage
/// ```dart
/// // Get parameter metadata
/// final params = method.getParameters();
/// final firstParam = params[0];
///
/// // Inspect parameter properties
/// print('Name: ${firstParam.getName()}');
/// print('Type: ${firstParam.getType<dynamic>().getName()}');
/// print('Optional: ${firstParam.isOptional()}');
///
/// // Check for default value
/// if (firstParam.hasDefaultValue()) {
///   print('Default: ${firstParam.getDefaultValue()}');
/// }
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract interface class Parameter extends SourceElement {
  /// Gets the declared name of the parameter.
  ///
  /// {@template parameter_get_name}
  /// Returns:
  /// - The parameter name as declared in source
  /// - Empty string for positional parameters
  ///
  /// Example:
  /// ```dart
  /// void method(String param1, {int param2}) {}
  /// // getName() returns:
  /// // '' for param1 (positional)
  /// // 'param2' for named param
  /// ```
  /// {@endtemplate}
  String getName();
  
  /// Gets the type of the parameter with proper generics.
  ///
  /// {@template parameter_get_type}
  /// Type Parameters:
  /// - `P`: The expected parameter type
  ///
  /// Returns:
  /// - A [Class<P>] instance representing the parameter type
  ///
  /// Example:
  /// ```dart
  /// final type = param.getClass<String>(); // Class<String>
  /// ```
  /// {@endtemplate}
  Class<P> getClass<P>();

  /// Gets the type of the parameter.
  ///
  /// {@template parameter_get_type}
  /// Returns:
  /// - The parameter type as a [Type]
  ///
  /// Example:
  /// ```dart
  /// final type = param.getType(); // Type
  /// ```
  /// {@endtemplate}
  Type getType();
  
  /// Gets the parameter's position in the parameter list.
  ///
  /// {@template parameter_get_index}
  /// Returns:
  /// - Zero-based index in the method's parameter list
  ///
  /// Note:
  /// Named parameters typically appear after positional parameters
  /// in the index order.
  /// {@endtemplate}
  int getIndex();
  
  /// Checks if this parameter is optional.
  ///
  /// {@template parameter_is_optional}
  /// Returns:
  /// - `true` if either:
  ///   - Positional parameter in square brackets `[param]`
  ///   - Named parameter in curly braces `{param}`
  /// - `false` for required parameters
  /// {@endtemplate}
  bool isOptional();
  
  /// Checks if this is a named parameter.
  ///
  /// {@template parameter_is_named}
  /// Returns:
  /// - `true` if declared in curly braces `{param}`
  /// - `false` for positional parameters
  /// {@endtemplate}
  bool isNamed();
  
  /// Checks if this is a positional parameter.
  ///
  /// {@template parameter_is_positional}
  /// Returns:
  /// - `true` if declared without braces or in square brackets `[param]`
  /// - `false` for named parameters
  /// {@endtemplate}
  bool isPositional();
  
  /// Checks if this parameter is required.
  ///
  /// {@template parameter_is_required}
  /// Returns:
  /// - `true` if declared with `required` keyword
  /// - `false` for optional parameters
  ///
  /// Note:
  /// Differs from [isOptional] as some named parameters may be required.
  /// {@endtemplate}
  bool isRequired();
  
  /// Checks if this parameter has a default value.
  ///
  /// {@template parameter_has_default}
  /// Returns:
  /// - `true` if parameter has a default value
  /// - `false` if required or optional without default
  ///
  /// See also:
  /// - [getDefaultValue] to retrieve the value
  /// {@endtemplate}
  bool hasDefaultValue();
  
  /// Gets the default value of the parameter.
  ///
  /// {@template parameter_get_default}
  /// Returns:
  /// - The default value if specified
  /// - `null` if no default exists
  ///
  /// Example:
  /// ```dart
  /// void method([int param = 42]) {}
  /// // getDefaultValue() returns 42
  /// ```
  /// {@endtemplate}
  dynamic getDefaultValue();
  
  /// Gets a string representation of the parameter signature.
  ///
  /// {@template parameter_get_signature}
  /// Format includes:
  /// - Parameter kind (named/positional)
  /// - Type information
  /// - Default values if present
  ///
  /// Example outputs:
  /// - `String name`
  /// - `[int index = 0]`
  /// - `{required bool flag}`
  /// {@endtemplate}
  String getSignature();
  
  /// Creates a Parameter instance from reflection metadata.
  ///
  /// {@template parameter_factory}
  /// Parameters:
  /// - [declaration]: The parameter reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [Parameter] implementation
  ///
  /// Typical implementation:
  /// ```dart
  /// static Parameter declared(ParameterDeclaration d, ProtectionDomain p) {
  ///   return _ParameterImpl(d, p);
  /// }
  /// ```
  /// {@endtemplate}
  static Parameter declared(ParameterDeclaration declaration, ProtectionDomain domain) {
    return _Parameter(declaration, domain);
  }
}