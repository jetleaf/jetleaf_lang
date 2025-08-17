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

import 'annotation/annotation.dart';
import 'class/class.dart';
import 'parameter/parameter.dart';
import 'protection_domain/protection_domain.dart';

/// {@template protection_element}
/// Abstract interface for elements that can have protection domains.
///
/// {@template protection_element_features}
/// ## Key Features
/// - Protection domain integration
/// - Permission checking
///
/// ## Implementations
/// Typically implemented by:
/// - [ClassMetadata] for class-level annotations
/// - [MethodMetadata] for method annotations
/// - [FieldMetadata] for field annotations
/// - [ParameterMetadata] for parameter annotations
/// {@endtemplate}
/// {@endtemplate}
abstract class ProtectionElement {
  /// Gets the protection domain governing access to this element.
  ///
  /// {@template source_metadata_protection}
  /// Protection domains control:
  /// - Visibility of the element
  /// - Access to sensitive metadata
  /// - Security constraints
  ///
  /// Returns:
  /// - The [ProtectionDomain] associated with this element
  ///
  /// See also:
  /// - [checkAccess] for permission verification
  /// {@endtemplate}
  ProtectionDomain getProtectionDomain();

  /// Verifies access permissions before performing sensitive operations.
  ///
  /// {@template source_metadata_check_access}
  /// Parameters:
  /// - [operation]: Description of the operation being performed
  /// - [permission]: Required permission level
  ///
  /// Throws:
  /// - [AccessDeniedError] if permissions are insufficient
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   metadata.checkAccess('privateFieldAccess', DomainPermission.high);
  ///   // Perform sensitive operation
  /// } on AccessDeniedError {
  ///   print('Insufficient permissions');
  /// }
  /// ```
  /// {@endtemplate}
  void checkAccess(String operation, DomainPermission permission) {
    getProtectionDomain().checkAccess(operation, permission);
  }
}

/// {@template source_metadata}
/// Abstract base class for all reflection metadata that can be annotated.
///
/// Provides common functionality for working with annotations and protection
/// domains across all reflectable elements (classes, methods, fields, etc.).
///
/// {@template source_metadata_features}
/// ## Key Features
/// - Annotation discovery and filtering by type
/// - Protection domain integration
/// - Type-safe annotation access
/// - Permission checking
///
/// ## Implementations
/// Typically implemented by:
/// - [ClassMetadata] for class-level annotations
/// - [MethodMetadata] for method annotations
/// - [FieldMetadata] for field annotations
/// - [ParameterMetadata] for parameter annotations
/// {@endtemplate}
///
/// {@template source_metadata_example}
/// ## Example Usage
/// ```dart
/// // Get class metadata
/// final classMeta = reflector.getClass('MyClass');
///
/// // Check for specific annotation
/// if (classMeta.hasAnnotation<JsonSerializable>()) {
///   // Get annotation instance
///   final jsonAnn = classMeta.getAnnotation<JsonSerializable>();
///   print('Uses JSON serialization');
/// }
///
/// // Get all controller annotations
/// final controllers = classMeta.getAnnotations<RestController>();
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class SourceElement extends ProtectionElement {
  /// Gets all annotations applied to this element.
  ///
  /// {@template source_metadata_all_annotations}
  /// Returns:
  /// - A list of all [Annotation] instances on this element
  /// - Empty list if no annotations exist
  ///
  /// Note:
  /// Includes both runtime-retained and source-only annotations
  /// when available in the reflection environment.
  ///
  /// Example:
  /// ```dart
  /// for (final ann in element.getAllAnnotations()) {
  ///   print('Found annotation: ${ann.getSignature()}');
  /// }
  /// ```
  /// {@endtemplate}
  List<Annotation> getAllAnnotations();
  
  /// Gets a single annotation by type, if present.
  ///
  /// {@template source_metadata_get_annotation}
  /// Type Parameters:
  /// - `A`: The annotation type to look for
  ///
  /// Returns:
  /// - The annotation instance of type `A` if found
  /// - `null` if no matching annotation exists
  ///
  /// Example:
  /// ```dart
  /// final deprecated = method.getAnnotation<Deprecated>();
  /// if (deprecated != null) {
  ///   print('Deprecation message: ${deprecated.message}');
  /// }
  /// ```
  /// {@endtemplate}
  A? getAnnotation<A>() {
    checkAccess('getAnnotation', DomainPermission.READ_ANNOTATIONS);

    final annotations = getAllAnnotations();
    for (final annotation in annotations) {
      if (annotation.getClass().getType() == A) {
        return annotation.getInstance<A>();
      }
    }
    return null;
  }
  
  /// Gets all annotations of a specific type.
  ///
  /// {@template source_metadata_get_annotations}
  /// Type Parameters:
  /// - `A`: The annotation type to filter for
  ///
  /// Returns:
  /// - A list of all matching annotation instances
  /// - Empty list if none found
  ///
  /// Note:
  /// Useful for repeatable annotations that may appear multiple times.
  ///
  /// Example:
  /// ```dart
  /// final routes = method.getAnnotations<Route>();
  /// for (final route in routes) {
  ///   print('Route path: ${route.path}');
  /// }
  /// ```
  /// {@endtemplate}
  List<A> getAnnotations<A>() {
    checkAccess('getAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = getAllAnnotations();
    return annotations.where((a) => a.getClass().getType() == A).map((a) => a.getInstance<A>()).toList();
  }
  
  /// Checks if this element has a specific annotation.
  ///
  /// {@template source_metadata_has_annotation}
  /// Type Parameters:
  /// - `A`: The annotation type to check for
  ///
  /// Returns:
  /// - `true` if the annotation is present
  /// - `false` otherwise
  ///
  /// Example:
  /// ```dart
  /// if (field.hasAnnotation<Transient>()) {
  ///   print('Field is transient and will not be serialized');
  /// }
  /// ```
  /// {@endtemplate}
  bool hasAnnotation<A>() {
    checkAccess('hasAnnotation', DomainPermission.READ_ANNOTATIONS);
    return getAnnotation<A>() != null;
  }
}

/// {@template executable_element}
/// Abstract base class for executable elements (methods, constructors, functions).
///
/// Provides common functionality for inspecting and working with callable elements
/// including parameters, invocation validation, and signature generation.
///
/// {@template executable_element_features}
/// ## Key Features
/// - Parameter inspection and validation
/// - Signature generation
/// - Invocation argument checking
/// - Const/var/final determination
///
/// ## Implementations
/// Typically implemented by:
/// - [MethodElement] for class methods
/// - [ConstructorElement] for constructors
/// - [FunctionElement] for standalone functions
/// {@endtemplate}
///
/// {@template executable_element_example}
/// ## Example Usage
/// ```dart
/// // Get executable element from reflection
/// final methodElement = classElement.getMethod('calculate');
///
/// // Check parameters
/// if (methodElement.getParameterCount() > 0) {
///   final firstParam = methodElement.getParameterAt(0);
///   print('First parameter: ${firstParam.getName()}');
/// }
///
/// // Validate arguments
/// if (methodElement.canAcceptArguments({'x': 1, 'y': 2})) {
///   print('Method can accept these named arguments');
/// }
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class ExecutableElement extends SourceElement {
  /// Gets all parameters of this executable element.
  ///
  /// {@template executable_get_parameters}
  /// Returns:
  /// - An ordered list of [Parameter] objects
  /// - Empty list if no parameters exist
  ///
  /// Order matches the declaration order in source.
  ///
  /// Example:
  /// ```dart
  /// void method(int a, String b) {}
  /// // Returns [Parameter(a), Parameter(b)]
  /// ```
  /// {@endtemplate}
  List<Parameter> getParameters();

  /// Gets the total number of parameters.
  ///
  /// {@template executable_parameter_count}
  /// Returns:
  /// - The count of all parameters (required and optional)
  ///
  /// Equivalent to `getParameters().length` but more efficient.
  /// {@endtemplate}
  int getParameterCount();

  /// Gets a parameter by name.
  ///
  /// {@template executable_get_parameter}
  /// Parameters:
  /// - [name]: The parameter name to look up
  ///
  /// Returns:
  /// - The [Parameter] if found (named parameters only)
  /// - `null` if no matching named parameter exists
  ///
  /// Note:
  /// Positional parameters cannot be retrieved by name.
  /// {@endtemplate}
  Parameter? getParameter(String name);

  /// Gets a parameter by index.
  ///
  /// {@template executable_get_parameter_at}
  /// Parameters:
  /// - [index]: Zero-based parameter position
  ///
  /// Returns:
  /// - The [Parameter] at the given index
  /// - `null` if index is out of bounds
  ///
  /// Example:
  /// ```dart
  /// // For method(int a, String b)
  /// getParameterAt(1) // Returns Parameter(b)
  /// ```
  /// {@endtemplate}
  Parameter? getParameterAt(int index);

  /// Gets the types of all parameters.
  ///
  /// {@template executable_parameter_types}
  /// Returns:
  /// - A list of [Class] objects representing parameter types
  /// - Order matches parameter declaration order
  ///
  /// Example:
  /// ```dart
  /// // For method(int a, String b)
  /// // Returns [Class<int>, Class<String>]
  /// ```
  /// {@endtemplate}
  List<Class> getParameterTypes();

  /// Checks if named arguments can be accepted.
  ///
  /// {@template executable_can_accept_arguments}
  /// Parameters:
  /// - [arguments]: Map of argument names to values
  ///
  /// Returns:
  /// - `true` if:
  ///   - All required parameters are provided
  ///   - No extra unknown parameters exist
  ///   - Types are compatible
  /// - `false` otherwise
  ///
  /// Example:
  /// ```dart
  /// canAcceptArguments({'name': 'Alice', 'age': 30})
  /// ```
  /// {@endtemplate}
  bool canAcceptArguments(Map<String, dynamic> arguments);

  /// Checks if positional arguments can be accepted.
  ///
  /// {@template executable_can_accept_positional}
  /// Parameters:
  /// - [args]: List of positional arguments
  ///
  /// Returns:
  /// - `true` if:
  ///   - Minimum required count is met
  ///   - Optional parameters are within bounds
  ///   - Types are compatible
  /// - `false` otherwise
  ///
  /// Example:
  /// ```dart
  /// canAcceptPositionalArguments([1, 'hello'])
  /// ```
  /// {@endtemplate}
  bool canAcceptPositionalArguments(List<dynamic> args);

  /// Gets the executable signature as a string.
  ///
  /// {@template executable_signature}
  /// Format includes:
  /// - Return type (if known)
  /// - Name
  /// - Parameter list with types
  /// - Optional/required markers
  ///
  /// Example outputs:
  /// - `void print(String message)`
  /// - `Map<String, int>.fromEntries(Iterable<MapEntry<String, int>> entries)`
  /// - `{required int timeout, bool retry = false}`
  /// {@endtemplate}
  String getSignature();

  /// Checks if this executable is declared as const.
  ///
  /// {@template executable_is_const}
  /// Returns:
  /// - `true` if declared with `const` modifier
  /// - `false` otherwise
  ///
  /// Note:
  /// Differs from `isFinal` as const implies compile-time constant.
  /// {@endtemplate}
  bool isConst();
}