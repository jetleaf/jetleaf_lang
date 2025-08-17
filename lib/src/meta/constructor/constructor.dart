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
import '../parameter/parameter.dart';
import '../protection_domain/protection_domain.dart';

part '_constructor.dart';

/// {@template constructor_interface}
/// Provides reflective access to class constructor metadata and instantiation.
///
/// This interface enables runtime inspection and invocation of class constructors,
/// including access to:
/// - Constructor parameters
/// - Factory constructor detection
/// - Instance creation
/// - Declaring class information
///
/// {@template constructor_interface_features}
/// ## Key Features
/// - Named and unnamed constructor support
/// - Parameter inspection
/// - Type-safe instance creation
/// - Factory constructor handling
///
/// ## Implementation Notes
/// Concrete implementations typically wrap platform-specific reflection objects
/// while providing this uniform interface.
/// {@endtemplate}
///
/// {@template constructor_interface_example}
/// ## Example Usage
/// ```dart
/// // Get constructor metadata
/// final namedConstructor = userClass.getConstructor('fromJson');
///
/// // Inspect parameters
/// if (namedConstructor.getParameterCount() > 0) {
///   final firstParam = namedConstructor.getParameterAt(0);
///   print('First parameter: ${firstParam.getName()}');
/// }
///
/// // Create instances
/// final user = namedConstructor.newInstance({'json': userData});
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class Constructor extends ExecutableElement {
  /// Gets the name of the constructor.
  ///
  /// {@template constructor_get_name}
  /// Returns:
  /// - The constructor name as declared in source
  /// - Empty string for default unnamed constructors
  ///
  /// Examples:
  /// - `''` for `ClassName()`
  /// - `'fromJson'` for `ClassName.fromJson()`
  /// {@endtemplate}
  String getName();
  
  /// Gets the class that declares this constructor.
  ///
  /// {@template constructor_declaring_class}
  /// Type Parameters:
  /// - `D`: The expected declaring class type
  ///
  /// Returns:
  /// - The [Class<D>] where this constructor is defined
  ///
  /// Example:
  /// ```dart
  /// final declaringClass = constructor.getDeclaringClass<User>();
  /// ```
  /// {@endtemplate}
  Class<D> getDeclaringClass<D>();
  
  /// Checks if this is a factory constructor.
  ///
  /// {@template constructor_is_factory}
  /// Returns:
  /// - `true` if declared with `factory` keyword
  /// - `false` for generative constructors
  ///
  /// Note:
  /// Factory constructors may return instances of subtypes.
  /// {@endtemplate}
  bool isFactory();
  
  /// Creates a new instance using named arguments.
  ///
  /// {@template constructor_new_instance}
  /// Parameters:
  /// - [arguments]: Optional named arguments matching constructor parameters
  ///
  /// Returns:
  /// - A new instance of the declaring class
  ///
  /// Throws:
  /// - [InvalidArgumentException] if arguments don't match parameters
  /// - [UnsupportedOperationException] for abstract classes
  ///
  /// Example:
  /// ```dart
  /// final instance = constructor.newInstance({'name': 'Alice', 'age': 30});
  /// ```
  /// {@endtemplate}
  Instance newInstance<Instance>([Map<String, dynamic>? arguments]);
  
  /// Creates a new instance using positional arguments.
  ///
  /// {@template constructor_new_instance_positional}
  /// Parameters:
  /// - [args]: Positional arguments in declaration order
  ///
  /// Returns:
  /// - A new instance of the declaring class
  ///
  /// Throws:
  /// - [InvalidArgumentException] if argument count/type mismatch
  ///
  /// Example:
  /// ```dart
  /// final instance = constructor.newInstanceWithArgs(['Alice', 30]);
  /// ```
  /// {@endtemplate}
  Instance newInstanceWithArgs<Instance>(List<dynamic> args);
  
  /// Creates a Constructor instance from reflection metadata.
  ///
  /// {@template constructor_factory}
  /// Parameters:
  /// - [declaration]: The constructor reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [Constructor] implementation
  ///
  /// Typical implementation:
  /// ```dart
  /// static Constructor declared(ConstructorDeclaration d, ProtectionDomain p) {
  ///   return _ConstructorImpl(d, p);
  /// }
  /// ```
  /// {@endtemplate}
  static Constructor declared(ConstructorDeclaration declaration, ProtectionDomain domain) {
    return _Constructor(declaration, domain);
  }
}