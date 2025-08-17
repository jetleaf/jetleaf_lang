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
import '../annotation/annotation.dart';
import '../class/class.dart';
import '../protection_domain/protection_domain.dart';

part '_record_field.dart';

/// {@template record_field}
/// Represents a field within a Dart record type with reflection capabilities.
///
/// Provides access to metadata about individual fields in records, including:
/// - Field names (for named fields)
/// - Field types
/// - Position information (for positional fields)
///
/// {@template record_field_features}
/// ## Key Features
/// - Distinguishes between named and positional fields
/// - Provides type information for each field
/// - Maintains positional field ordering
/// - Generates accurate signatures
/// {@endtemplate}
///
/// {@template record_field_example}
/// ## Example Usage
/// ```dart
/// final recordType = Class.forType<(int, String, {bool flag})>();
/// final record = recordType.asRecord();
/// final firstField = record?.getPositionalField(0);
/// 
/// print(firstField?.getClass<int>()?.getName()); // 'int'
/// print(firstField?.isPositional()); // true
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class RecordField extends SourceElement {
  /// Gets the name of the field.
  ///
  /// {@template record_field_get_name}
  /// Returns:
  /// - The declared name for named fields
  /// - A synthetic positional name (e.g., '\$1') for positional fields
  /// {@endtemplate}
  String getName();
  
  /// Gets the type of the field as a [Class<T>].
  ///
  /// {@template record_field_get_class}
  /// Type Parameters:
  /// - `T`: The expected field type
  ///
  /// Returns:
  /// - A [Class<T>] instance representing the field's type
  ///
  /// Example:
  /// ```dart
  /// final type = field.getClass<String>();
  /// ```
  /// {@endtemplate}
  Class<T> getClass<T>();

  /// Gets the runtime type of the field.
  ///
  /// {@template record_field_get_type}
  /// Returns:
  /// - The Dart [Type] of this field
  /// {@endtemplate}
  Type getType();
  
  /// Gets the position index for positional fields.
  ///
  /// {@template record_field_get_position}
  /// Returns:
  /// - The zero-based position for positional fields
  /// - `null` for named fields
  /// {@endtemplate}
  int? getPosition();
  
  /// Checks if this is a named field.
  ///
  /// {@template record_field_is_named}
  /// Returns:
  /// - `true` if declared with a name in curly braces `{namedField}`
  /// - `false` for positional fields
  /// {@endtemplate}
  bool isNamed();
  
  /// Checks if this is a positional field.
  ///
  /// {@template record_field_is_positional}
  /// Returns:
  /// - `true` if declared without a name
  /// - `false` for named fields
  /// {@endtemplate}
  bool isPositional();
  
  /// Gets the field signature as a string.
  ///
  /// {@template record_field_signature}
  /// Format includes:
  /// - Type information
  /// - Name (for named fields)
  /// - Position (for synthetic names)
  ///
  /// Example outputs:
  /// - `String $1` (positional)
  /// - `bool flag` (named)
  /// {@endtemplate}
  String getSignature();
  
  /// Creates a RecordField instance from reflection metadata.
  ///
  /// {@template record_field_factory}
  /// Parameters:
  /// - [declaration]: The field reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [RecordField] implementation
  /// {@endtemplate}
  static RecordField declared(RecordFieldDeclaration declaration, ProtectionDomain domain) {
    return _RecordField(declaration, domain);
  }
}