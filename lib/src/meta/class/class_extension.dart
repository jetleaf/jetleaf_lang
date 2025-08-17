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

import '../protection_domain/protection_domain.dart';
import 'class.dart';

/// {@template class_extension}
/// Extension providing reflection capabilities to all Dart objects.
///
/// Adds convenient methods for accessing runtime type information
/// through the JetLeaf reflection system.
///
/// {@template class_extension_features}
/// ## Features
/// - Type-safe class reflection access
/// - Shortcut getter for common use cases
/// - Automatic protection domain handling
/// {@endtemplate}
///
/// {@template class_extension_example}
/// ## Example Usage
/// ```dart
/// final myObject = SomeClass();
/// 
/// // Get class metadata
/// final classInfo = myObject.getClass();
/// print('Object type: ${classInfo.getName()}');
///
/// // Shortcut syntax
/// final constructors = myObject.clazz.getConstructors();
/// ```
/// {@endtemplate}
/// {@endtemplate}
extension ClassExtension on Object {
  /// Gets the [Class] metadata for this object's runtime type.
  ///
  /// {@template get_class_method}
  /// Returns:
  /// - A [Class<Object>] instance representing the object's type
  /// - Uses the current protection domain for security
  ///
  /// Equivalent to:
  /// ```dart
  /// Class.forType<Object>(runtimeType, ProtectionDomain.current())
  /// ```
  /// {@endtemplate}
  Class getClass() => Class.forObject(this, ProtectionDomain.system());

  /// Shortcut getter for [getClass].
  ///
  /// {@template clazz_getter}
  /// Provides more concise syntax for accessing class metadata:
  /// 
  /// ```dart
  /// object.clazz // Instead of object.getClass()
  /// ```
  /// {@endtemplate}
  Class get clazz => getClass();
}

/// {@template class_string_extension}
/// Extension adding class reflection capabilities to String objects.
///
/// Enables convenient conversion from string representations to [Class] instances.
/// Particularly useful when working with serialized type information or dynamic
/// type loading.
///
/// {@template class_string_extension_features}
/// ## Key Features
/// - Convert qualified names to Class instances
/// - Convert simple type names to Class instances
/// - Automatic protection domain handling
/// - Type-safe reflection operations
/// {@endtemplate}
///
/// {@template class_string_extension_example}
/// ## Example Usage
/// ```dart
/// // From qualified name
/// final classFromQualified = 'package:myapp/models.dart#User'
///   .getQualifiedClass();
///
/// // From simple name  
/// final classFromSimple = 'String'.getSimpleClass();
/// ```
/// {@endtemplate}
/// {@endtemplate}
extension ClassStringExtension on String {
  /// Converts a fully qualified class name to a [Class] instance.
  ///
  /// {@template get_qualified_class}
  /// Format Requirements:
  /// - Package URI (e.g., `package:myapp/models.dart`)
  /// - Class name separated by `#`
  /// - Optional nested class notation with `.`
  ///
  /// Example Patterns:
  /// - `package:path/file.dart#ClassName`
  /// - `package:path/file.dart#OuterClass.InnerClass`
  /// - `dart:core#String`
  ///
  /// Returns:
  /// - A [Class] instance for the qualified type
  /// - Throws [ReflectionException] if invalid format or type not found
  ///
  /// Example:
  /// ```dart
  /// final classRef = 'package:myapp/models.dart#User'
  ///   .getQualifiedClass();
  /// ```
  /// {@endtemplate}
  Class getQualifiedClass() => Class.fromQualifiedName(this, ProtectionDomain.system());

  /// Converts a simple type name to a [Class] instance.
  ///
  /// {@template get_simple_class}
  /// Supported Types:
  /// - Core types (String, int, bool, etc.)
  /// - User-defined types in current scope
  /// - Generic types (`List<String>`, `Map<int,String>`)
  ///
  /// Returns:
  /// - A [Class] instance for the simple type
  /// - Throws [ReflectionException] if type not found
  ///
  /// Example:
  /// ```dart
  /// // Core type
  /// final stringClass = 'String'.getSimpleClass();
  ///
  /// // Generic type  
  /// final listClass = 'List<int>'.getSimpleClass();
  ///
  /// // User type
  /// final userClass = 'UserModel'.getSimpleClass();
  /// ```
  /// {@endtemplate}
  Class getSimpleClass() => Class.fromSimpleName(this, ProtectionDomain.system());
}

/// {@template class_type_extension}
/// Extension adding class reflection capabilities to Type objects.
///
/// Enables convenient conversion from type objects to [Class] instances.
/// Particularly useful when working with dynamic type information or type
/// reflection.
///
/// {@template class_type_extension_features}
/// ## Key Features
/// - Convert type objects to Class instances
/// - Automatic protection domain handling
/// - Type-safe reflection operations
/// {@endtemplate}
///
/// {@template class_type_extension_example}
/// ## Example Usage
/// ```dart
/// // From type object
/// final classFromType = String.getClass();
/// ```
/// {@endtemplate}
/// {@endtemplate}
extension ClassTypeExtension on Type {
  /// Gets the [Class] metadata for this type object.
  ///
  /// {@template get_class_method}
  /// Returns:
  /// - A [Class] instance for the type object
  /// - Uses the current protection domain for security
  ///
  /// Example:
  /// ```dart
  /// final classRef = String.getClass();
  /// ```
  /// {@endtemplate}
  Class getClass() => Class.forType(this, ProtectionDomain.system());
}