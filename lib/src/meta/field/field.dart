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

import '../../exceptions.dart';
import '../../declaration/declaration.dart';
import '../meta.dart';
import '../annotation/annotation.dart';
import '../class/class.dart';
import '../protection_domain/protection_domain.dart';

part '_field.dart';

/// {@template field_interface}
/// Provides reflective access to class field metadata and value manipulation.
///
/// This interface enables runtime inspection and modification of class fields,
/// including access to:
/// - Field types and declarations
/// - Modifiers (final, const, etc.)
/// - Value getters/setters
/// - Access permissions
///
/// {@template field_interface_features}
/// ## Key Features
/// - Type-safe field value access
/// - Modifier inspection
/// - Read/write permission checking
/// - Declaring class resolution
/// - Signature generation
///
/// ## Implementation Notes
/// Concrete implementations typically wrap platform-specific reflection objects
/// while providing this uniform interface.
/// {@endtemplate}
///
/// {@template field_interface_example}
/// ## Example Usage
/// ```dart
/// // Get field metadata
/// final nameField = userClass.getField('name');
///
/// // Inspect field properties
/// print('Field type: ${nameField.getType<String>().getName()}');
/// print('Is final: ${nameField.isFinal()}');
///
/// // Access field values
/// final currentName = nameField.getValue(userInstance);
/// nameField.setValue(userInstance, 'New Name');
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class Field extends SourceElement {
  /// Gets the name of the field.
  ///
  /// {@template field_get_name}
  /// Returns:
  /// - The field name as declared in source
  ///
  /// Example:
  /// ```dart
  /// class User {
  ///   String name; // Returns 'name'
  /// }
  /// ```
  /// {@endtemplate}
  String getName();
  
  /// Gets the type of the field.
  ///
  /// {@template field_get_type}
  /// Type Parameters:
  /// - `T`: The expected field type
  ///
  /// Returns:
  /// - A [Class<T>] representing the field's declared type
  ///
  /// Example:
  /// ```dart
  /// final type = field.getClass<String>(); // Class<String>
  /// ```
  /// {@endtemplate}
  Class<T> getClass<T>();

  /// Gets the type of the field.
  ///
  /// {@template field_get_type}
  /// Returns:
  /// - The field type as a [Type]
  ///
  /// Example:
  /// ```dart
  /// final type = field.getType(); // Type
  /// ```
  /// {@endtemplate}
  Type getType();
  
  /// Gets the class that declares this field.
  ///
  /// {@template field_declaring_class}
  /// Type Parameters:
  /// - `D`: The expected declaring class type
  ///
  /// Returns:
  /// - The [Class<D>] where this field is defined
  ///
  /// Example:
  /// ```dart
  /// final declaringClass = field.getDeclaringClass<User>();
  /// ```
  /// {@endtemplate}
  Class<D> getDeclaringClass<D>();
  
  /// Checks if this field is static.
  ///
  /// {@template field_is_static}
  /// Returns:
  /// - `true` if declared with `static` modifier
  /// - `false` for instance fields
  ///
  /// Note:
  /// Static fields can be accessed with a null instance.
  /// {@endtemplate}
  bool isStatic();
  
  /// Checks if this field is final.
  ///
  /// {@template field_is_final}
  /// Returns:
  /// - `true` if declared with `final` modifier
  /// - `false` otherwise
  ///
  /// Note:
  /// Final fields can only be set once (typically during construction).
  /// {@endtemplate}
  bool isFinal();
  
  /// Checks if this field is const.
  ///
  /// {@template field_is_const}
  /// Returns:
  /// - `true` if declared with `const` modifier
  /// - `false` otherwise
  ///
  /// Note:
  /// Const fields are compile-time constants.
  /// {@endtemplate}
  bool isConst();
  
  /// Checks if this field is late.
  ///
  /// {@template field_is_late}
  /// Returns:
  /// - `true` if declared with `late` modifier
  /// - `false` otherwise
  ///
  /// Note:
  /// Late fields require null safety and support lazy initialization.
  /// {@endtemplate}
  bool isLate();
  
  /// Checks if this field is abstract.
  ///
  /// {@template field_is_abstract}
  /// Returns:
  /// - `true` if declared in an abstract class without initialization
  /// - `false` for concrete fields
  ///
  /// Note:
  /// Abstract fields cannot be accessed directly.
  /// {@endtemplate}
  bool isAbstract();
  
  /// Gets the field's value from an instance.
  ///
  /// {@template field_get_value}
  /// Parameters:
  /// - [instance]: The object instance (null for static fields)
  ///
  /// Returns:
  /// - The current field value
  ///
  /// Throws:
  /// - [AccessError] if field is not readable
  /// - [NullReferenceError] for null instance on instance fields
  ///
  /// Example:
  /// ```dart
  /// final value = field.getValue(instance);
  /// ```
  /// {@endtemplate}
  dynamic getValue(Object? instance);
  
  /// Sets the field's value on an instance.
  ///
  /// {@template field_set_value}
  /// Parameters:
  /// - [instance]: The object instance (null for static fields)
  /// - [value]: The new value to set
  ///
  /// Throws:
  /// - [AccessError] if field is not writable
  /// - [TypeError] for invalid value types
  /// - [FinalFieldError] when modifying final fields
  ///
  /// Example:
  /// ```dart
  /// field.setValue(instance, newValue);
  /// ```
  /// {@endtemplate}
  void setValue(Object? instance, dynamic value);
  
  /// Gets the field's value with type safety.
  ///
  /// {@template field_get_value_as}
  /// Type Parameters:
  /// - `T`: The expected return type
  ///
  /// Parameters:
  /// - [instance]: The object instance
  ///
  /// Returns:
  /// - The field value cast to type T
  /// - `null` if value is null or type conversion fails
  ///
  /// Example:
  /// ```dart
  /// final name = field.getValueAs<String>(instance);
  /// ```
  /// {@endtemplate}
  T? getValueAs<T>(Object? instance);
  
  /// Sets the field's value with type checking.
  ///
  /// {@template field_set_value_checked}
  /// Parameters:
  /// - [instance]: The object instance
  /// - [value]: The new value to set
  ///
  /// Throws:
  /// - [TypeError] if value doesn't match field type
  /// - Additional errors from [setValue]
  ///
  /// Example:
  /// ```dart
  /// field.setValueWithTypeCheck(instance, newValue);
  /// ```
  /// {@endtemplate}
  void setValueWithTypeCheck(Object? instance, dynamic value);
  
  /// Checks if this field can be read.
  ///
  /// {@template field_is_readable}
  /// Returns:
  /// - `true` if:
  ///   - Not abstract
  ///   - Has getter (for properties)
  ///   - Not write-only
  /// - `false` otherwise
  /// {@endtemplate}
  bool isReadable();
  
  /// Checks if this field can be written.
  ///
  /// {@template field_is_writable}
  /// Returns:
  /// - `true` if:
  ///   - Not final/const
  ///   - Not abstract
  ///   - Has setter (for properties)
  ///   - Not read-only
  /// - `false` otherwise
  /// {@endtemplate}
  bool isWritable();
  
  /// Gets the field's signature as a string.
  ///
  /// {@template field_signature}
  /// Format includes:
  /// - Modifiers (final, late, etc.)
  /// - Type information
  /// - Name
  ///
  /// Example outputs:
  /// - `final String name`
  /// - `late int _count`
  /// - `static const Duration timeout = Duration(seconds: 30)`
  /// {@endtemplate}
  String getSignature();
  
  /// Creates a Field instance from reflection metadata.
  ///
  /// {@template field_factory}
  /// Parameters:
  /// - [declaration]: The field reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [Field] implementation
  ///
  /// Typical implementation:
  /// ```dart
  /// static Field declared(FieldDeclaration d, ProtectionDomain p) {
  ///   return _FieldImpl(d, p);
  /// }
  /// ```
  /// {@endtemplate}
  static Field declared(FieldDeclaration declaration, ProtectionDomain domain) {
    return _Field(declaration, domain);
  }
}