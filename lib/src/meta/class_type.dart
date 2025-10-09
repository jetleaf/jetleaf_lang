import '../declaration/declaration.dart';
import 'class.dart';
import 'protection_domain.dart';

/// {@template class_type}
/// The `ClassType` class in **Jetleaf** represents a reference to a Dart 
/// class, optionally including metadata such as package, protection domain, 
/// or type declaration.
///
/// It provides a convenient way to convert a class reference into a [Class] 
/// instance used by the Jetleaf framework for reflection, conditional 
/// processing, or pod registration.
///
/// ### Key Features:
/// - Supports optional class [name], [package], [ProtectionDomain], and [TypeDeclaration].
/// - Can convert itself into a [Class] instance using [toClass].
/// - Integrates with Jetleaf's type system for dynamic class handling.
///
/// ### Usage Example:
/// ```dart
/// import 'package:jetleaf/jetleaf.dart';
///
/// // Create a ClassType by name
/// final simpleClass = ClassType(name: 'UserService');
///
/// // Convert to a Jetleaf Class instance
/// final userClass = simpleClass.toClass();
///
/// // Create a ClassType with a TypeDeclaration
/// final declaredClass = ClassType(declaration: someTypeDeclaration);
/// final declaredClassInstance = declaredClass.toClass();
/// ```
/// {@endtemplate}
class ClassType<T> {
  /// {@template class_type_name}
  /// The simple name of the class.
  ///
  /// Optional. If not provided, the [toClass] method will use the declaration 
  /// or create a generic class instance.
  /// 
  /// {@endtemplate}
  final String? name;

  /// {@template class_type_package}
  /// The package the class belongs to, if any.
  ///
  /// Optional. Used by [toClass] to resolve the fully qualified class name.
  /// 
  /// {@endtemplate}
  final String? package;

  /// {@template class_type_pd}
  /// The [ProtectionDomain] associated with this class reference.
  ///
  /// If not provided, defaults to [ProtectionDomain.current] when calling [toClass].
  /// 
  /// {@endtemplate}
  final ProtectionDomain? pd;

  /// {@template class_type_declaration}
  /// Optional [TypeDeclaration] that represents the class declaration.
  ///
  /// If provided, [toClass] will use this declaration to create a [Class] 
  /// instance.
  /// 
  /// {@endtemplate}
  final TypeDeclaration? declaration;

  /// {@macro class_type}
  const ClassType({this.name, this.package, this.pd, this.declaration});

  /// {@template class_type_toClass}
  /// Converts this [ClassType] into a [Class] instance used by Jetleaf.
  ///
  /// Logic:
  /// 1. If [declaration] is provided, returns `Class.declared(declaration, pd)`.
  /// 2. If [name] is provided, returns `Class.forName(name, pd, package)`.
  /// 3. Otherwise, returns a generic `Class<T>` with the given [pd] and [package].
  ///
  /// ### Example:
  /// ```dart
  /// final classRef = ClassType(name: 'UserService');
  /// final userClass = classRef.toClass();
  ///
  /// final declaredClassRef = ClassType(declaration: someTypeDeclaration);
  /// final declaredClass = declaredClassRef.toClass();
  /// ```
  /// {@endtemplate}
  Class<T> toClass() {
    if (declaration != null) {
      return Class.declared(declaration!, pd ?? ProtectionDomain.current());
    }

    if (name != null) {
      return Class.forName(name!, pd ?? ProtectionDomain.current(), package);
    }

    return Class<T>(pd ?? ProtectionDomain.current(), package);
  }
}