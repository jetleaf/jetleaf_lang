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
import '../protection_domain/protection_domain.dart';
import 'record_field.dart';

part '_record.dart';

/// {@template record_type}
/// Provides reflective access to Dart record types and their fields.
///
/// This interface enables runtime inspection of record type metadata including:
/// - Positional and named field access
/// - Field counts and presence checks
/// - Complete signature generation
///
/// {@template record_type_features}
/// ## Key Features
/// - Complete record type introspection
/// - Type-safe field access
/// - Positional field ordering
/// - Named field lookup
/// - Signature generation
/// {@endtemplate}
///
/// {@template record_type_example}
/// ## Example Usage
/// ```dart
/// // Get record type information
/// final recordType = Class.forType<(int, String, {bool flag})>();
/// final record = recordType.asRecord();
///
/// // Access fields
/// final idField = record?.getPositionalField(0);
/// final flagField = record?.getNamedField('flag');
///
/// // Inspect structure
/// print('Has ${record?.getPositionalFieldCount()} positional fields');
/// print('Has ${record?.getNamedFieldCount()} named fields');
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class Record extends SourceElement {
  /// Gets the name of the record type.
  ///
  /// {@template record_get_name}
  /// Returns:
  /// - A string representation of the record type
  /// - Includes both positional and named fields
  ///
  /// Example:
  /// `'(int, String, {bool flag})'`
  /// {@endtemplate}
  String getName();
  
  /// Gets all positional fields in declaration order.
  ///
  /// {@template record_get_positional_fields}
  /// Returns:
  /// - An ordered list of [RecordField] objects
  /// - Empty list if no positional fields exist
  ///
  /// Order matches the declaration order in source.
  /// {@endtemplate}
  List<RecordField> getPositionalFields();
  
  /// Gets all named fields as a name-to-field map.
  ///
  /// {@template record_get_named_fields}
  /// Returns:
  /// - A map of field names to [RecordField] objects
  /// - Empty map if no named fields exist
  /// {@endtemplate}
  Map<String, RecordField> getNamedFields();
  
  /// Gets a positional field by index.
  ///
  /// {@template record_get_positional_field}
  /// Parameters:
  /// - [index]: Zero-based field position
  ///
  /// Returns:
  /// - The [RecordField] at the given position
  /// - `null` if index is out of bounds
  /// {@endtemplate}
  RecordField? getPositionalField(int index);
  
  /// Gets a named field by name.
  ///
  /// {@template record_get_named_field}
  /// Parameters:
  /// - [name]: The field name to look up
  ///
  /// Returns:
  /// - The [RecordField] with matching name
  /// - `null` if no matching field exists
  /// {@endtemplate}
  RecordField? getNamedField(String name);
  
  /// Gets the total number of fields.
  ///
  /// {@template record_field_count}
  /// Returns:
  /// - The sum of positional and named fields
  /// {@endtemplate}
  int getFieldCount();
  
  /// Gets the count of positional fields.
  ///
  /// {@template record_positional_field_count}
  /// Returns:
  /// - The number of positional fields
  /// - 0 if no positional fields exist
  /// {@endtemplate}
  int getPositionalFieldCount();
  
  /// Gets the count of named fields.
  ///
  /// {@template record_named_field_count}
  /// Returns:
  /// - The number of named fields
  /// - 0 if no named fields exist
  /// {@endtemplate}
  int getNamedFieldCount();
  
  /// Checks if this record has any positional fields.
  ///
  /// {@template record_has_positional_fields}
  /// Returns:
  /// - `true` if at least one positional field exists
  /// - `false` otherwise
  /// {@endtemplate}
  bool hasPositionalFields();
  
  /// Checks if this record has any named fields.
  ///
  /// {@template record_has_named_fields}
  /// Returns:
  /// - `true` if at least one named field exists
  /// - `false` otherwise
  /// {@endtemplate}
  bool hasNamedFields();
  
  /// Gets the complete record signature as a string.
  ///
  /// {@template record_signature}
  /// Format matches Dart syntax:
  /// - Parentheses for positional fields
  /// - Curly braces for named fields
  /// - Proper type annotations
  ///
  /// Example outputs:
  /// - `(int, String)`
  /// - `({String name, int age})`
  /// - `(int id, String name, {bool active})`
  /// {@endtemplate}
  String getSignature();
  
  /// Creates a Record instance from reflection metadata.
  ///
  /// {@template record_factory}
  /// Parameters:
  /// - [declaration]: The record reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [Record] implementation
  /// {@endtemplate}
  static Record declared(RecordDeclaration declaration, ProtectionDomain domain) {
    return _Record(declaration, domain);
  }
}