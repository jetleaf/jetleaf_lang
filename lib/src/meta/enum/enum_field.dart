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
import '../meta.dart';
import '../protection_domain/protection_domain.dart';

part '_enum_field.dart';

/// {@template enum_field}
/// Provides reflective access to individual values within an enumerated type.
///
/// This interface enables runtime inspection of enum values including:
/// - Value names and identities
/// - Parent enum type information
/// - Protection domain awareness
///
/// {@template enum_field_features}
/// ## Key Features
/// - Type-safe enum value reflection
/// - Name and value access
/// - Parent enum resolution
/// - Security through protection domains
///
/// ## Implementations
/// Concrete implementations typically wrap platform-specific reflection objects
/// while providing this uniform interface.
/// {@endtemplate}
///
/// {@template enum_field_example}
/// ## Example Usage
/// ```dart
/// enum Status { active, paused }
///
/// // Get enum field metadata
/// final activeField = reflector.getEnumField(Status.active);
/// print(activeField.getName()); // 'active'
/// print(activeField.getValue() == Status.active); // true
///
/// // Get parent enum
/// final enumDecl = activeField.getEnum();
/// print(enumDecl.getName()); // 'Status'
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class EnumField extends ProtectionElement {
  /// Gets the declared name of this enum value.
  ///
  /// {@template enum_field_get_name}
  /// Returns:
  /// - The identifier name as declared in source code
  /// - Matches exactly what appears after the enum dot (Status.active → 'active')
  /// {@endtemplate}
  String getName();

  /// Gets the runtime value of this enum field.
  ///
  /// {@template enum_field_get_value}
  /// Returns:
  /// - The actual enum value instance
  /// - Can be used for direct comparison (===) with runtime values
  ///
  /// Example:
  /// ```dart
  /// field.getValue() == Status.active // true for active field
  /// ```
  /// {@endtemplate}
  dynamic getValue();

  /// The position of the enum value as-is in the enum class
  /// 
  /// Cannot be -1
  int getPosition();

  /// Gets the enum declaration that contains this field.
  ///
  /// {@template enum_field_get_enum}
  /// Returns:
  /// - The [EnumDeclaration] representing the parent enum type
  ///
  /// Example:
  /// ```dart
  /// final enumType = field.getEnum();
  /// print(enumType.getName()); // 'Status'
  /// ```
  /// {@endtemplate}
  EnumDeclaration getEnum();

  /// Creates an EnumField instance from reflection metadata.
  ///
  /// {@template enum_field_factory}
  /// Parameters:
  /// - [declaration]: The enum field reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [EnumField] implementation
  ///
  /// Typical implementation:
  /// ```dart
  /// static EnumField declared(EnumFieldDeclaration d, ProtectionDomain p) {
  ///   return _EnumFieldImpl(d, p);
  /// }
  /// ```
  /// {@endtemplate}
  static EnumField declared(EnumFieldDeclaration declaration, ProtectionDomain domain) {
    return _EnumField(declaration, domain);
  }
}