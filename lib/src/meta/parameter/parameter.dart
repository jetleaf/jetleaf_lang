import 'package:jetleaf_build/jetleaf_build.dart';

import '../../exceptions.dart';
import '../annotation/annotation.dart';
import '../class/class.dart';
import '../constructor/constructor.dart';
import '../field/field.dart';
import '../core.dart';
import '../method/method.dart';
import '../protection_domain/protection_domain.dart';

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
abstract interface class Parameter extends Source {
  /// Gets the type of the parameter with proper generics.
  ///
  /// {@template parameter_get_type}
  /// Returns:
  /// - A [Class] instance representing the parameter type
  ///
  /// Example:
  /// ```dart
  /// final type = param.getClass<String>(); // Class<String>
  /// ```
  /// {@endtemplate}
  Class<Object> getClass();

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

  /// Gets the member that this parameter belongs to.
  /// 
  /// Can be a [Method], [Constructor], or [Field].
  ///
  /// {@template parameter_get_member}
  /// Returns:
  /// - The member that this parameter belongs to
  ///
  /// Example:
  /// ```dart
  /// void method(int param) {}
  /// // getMember() returns method
  /// ```
  /// {@endtemplate}
  Member getMember();
  
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