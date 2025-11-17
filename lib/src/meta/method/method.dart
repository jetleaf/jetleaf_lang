import 'dart:async';

import 'package:jetleaf_build/jetleaf_build.dart';

import '../../exceptions.dart';
import '../class_loader/default_class_loader.dart';
import '../annotation/annotation.dart';
import '../class/class.dart';
import '../core.dart';
import '../generic_source.dart';
import '../parameter/parameter.dart';
import '../protection_domain/protection_domain.dart';

part '_method.dart';

/// {@template method_interface}
/// Provides reflective access to class method metadata and invocation capabilities.
///
/// This interface enables runtime inspection and invocation of class methods,
/// including access to:
/// - Method signatures and return types
/// - Parameter metadata
/// - Modifiers (static, abstract, etc.)
/// - Type parameters
/// - Override information
///
/// {@template method_interface_features}
/// ## Key Features
/// - Type-safe method invocation
/// - Full signature inspection
/// - Parameter metadata access
/// - Override hierarchy navigation
/// - Generic type support
///
/// ## Implementation Notes
/// Concrete implementations typically wrap platform-specific reflection objects
/// while providing this uniform interface.
/// {@endtemplate}
///
/// {@template method_interface_example}
/// ## Example Usage
/// ```dart
/// // Get method metadata
/// final toStringMethod = objectClass.getMethod('toString');
///
/// // Inspect method properties
/// print('Return type: ${toStringMethod.getReturnType<String>().getName()}');
///
/// // Invoke the method
/// final result = toStringMethod.invoke(myObject);
/// print('Result: $result');
///
/// // Check override status
/// if (toStringMethod.isOverride()) {
///   print('This overrides a superclass method');
/// }
/// ```
/// {@endtemplate}
/// {@endtemplate}
abstract class Method extends Executable implements Member, GenericSource {
  /// Checks if this method is static.
  ///
  /// {@template method_is_static}
  /// Returns:
  /// - `true` if declared with `static` modifier
  /// - `false` for instance methods
  /// {@endtemplate}
  bool isStatic();
  
  /// Checks if this method is abstract.
  ///
  /// {@template method_is_abstract}
  /// Returns:
  /// - `true` if declared with `abstract` modifier
  /// - `false` for concrete methods
  ///
  /// Note:
  /// Abstract methods cannot be invoked.
  /// {@endtemplate}
  bool isAbstract();
  
  /// Checks if this method is a getter.
  ///
  /// {@template method_is_getter}
  /// Returns:
  /// - `true` if declared with `get` keyword
  /// - `false` otherwise
  ///
  /// Note:
  /// Getters have no parameters and return a value.
  /// {@endtemplate}
  bool isGetter();
  
  /// Checks if this method is a setter.
  ///
  /// {@template method_is_setter}
  /// Returns:
  /// - `true` if declared with `set` keyword
  /// - `false` otherwise
  ///
  /// Note:
  /// Setters have exactly one parameter and return void.
  /// {@endtemplate}
  bool isSetter();
  
  /// Checks if this method is a factory constructor.
  ///
  /// {@template method_is_factory}
  /// Returns:
  /// - `true` if declared with `factory` keyword
  /// - `false` otherwise
  ///
  /// Note:
  /// Factory methods may return subtypes of the declaring class.
  /// {@endtemplate}
  bool isFactory();

  /// Checks if this method overrides a superclass method.
  ///
  /// {@template method_is_override}
  /// Returns:
  /// - `true` if declared with `@override` or matches superclass signature
  /// - `false` otherwise
  ///
  /// See also:
  /// - [getOverriddenMethod] to retrieve the superclass method
  /// {@endtemplate}
  bool isOverride();

  /// {@template method_isVoid}
  /// Determines whether this method declares a `void` return type.
  ///
  /// This method inspects the method's declared return type and returns `true`
  /// if it is explicitly `void`. It is useful for AOP frameworks, reflection
  /// systems, and code generation tools that need to distinguish between
  /// methods that produce values and those that perform side effects only.
  ///
  /// ## Example
  /// ```dart
  /// class Logger {
  ///   void log(String message) {}
  ///   int countLogs() => 42;
  /// }
  ///
  /// final logMethod = Class(Logger).getMethod('log');
  /// final countMethod = Class(Logger).getMethod('countLogs');
  ///
  /// print(logMethod.isVoid());   // true
  /// print(countMethod.isVoid()); // false
  /// ```
  ///
  /// @return `true` if the method’s return type is `void`,
  ///         `false` otherwise.
  /// {@endtemplate}
  bool isVoid();

  /// {@template method_isFutureVoid}
  /// Determines whether this method declares a `Future<void>` return type.
  ///
  /// This method inspects the declared return type of the method and returns
  /// `true` if it represents an asynchronous computation that completes with
  /// no value (i.e., a `Future<void>`).  
  ///
  /// It is particularly useful in reflection, proxy generation, or method
  /// interceptors where you need to distinguish between:
  /// - **Asynchronous void methods** (`Future<void>`) that perform side effects,
  /// - **Asynchronous value-returning methods** (`Future<T>`), and
  /// - **Synchronous void methods** (`void`).
  ///
  /// ## Example
  /// ```dart
  /// class Example {
  ///   Future<void> save() async {}
  ///   Future<int> compute() async => 42;
  ///   void reset() {}
  /// }
  ///
  /// final saveMethod = Class(Example).getMethod('save');
  /// final computeMethod = Class(Example).getMethod('compute');
  /// final resetMethod = Class(Example).getMethod('reset');
  ///
  /// print(saveMethod.isFutureVoid());   // true
  /// print(computeMethod.isFutureVoid()); // false
  /// print(resetMethod.isFutureVoid());   // false
  /// ```
  ///
  /// @return `true` if the method’s return type is `Future<void>`,
  ///         `false` otherwise.
  /// {@endtemplate}
  bool isFutureVoid();

  /// {@template method_isAsync}
  /// Determines whether this method is **asynchronous** — i.e., declared using
  /// the `async` keyword or returning a [Future]-like type.
  ///
  /// Unlike [isFutureVoid], which specifically checks for a `Future<void>`
  /// return type, this method performs a broader inspection to determine
  /// whether the method represents *any* asynchronous computation.
  ///
  /// ### Typical Uses
  /// - **Dynamic invocation frameworks**: to decide whether to `await` the result.
  /// - **Proxy or interceptor implementations**: to preserve correct async semantics.
  /// - **Runtime analysis tools**: to distinguish between synchronous and asynchronous flows.
  ///
  /// ### Example
  /// ```dart
  /// class Example {
  ///   Future<void> save() async {}
  ///   Future<int> compute() async => 42;
  ///   void reset() {}
  /// }
  ///
  /// final saveMethod = Class(Example).getMethod('save');
  /// final computeMethod = Class(Example).getMethod('compute');
  /// final resetMethod = Class(Example).getMethod('reset');
  ///
  /// print(saveMethod.isAsync());   // true
  /// print(computeMethod.isAsync()); // true
  /// print(resetMethod.isAsync());   // false
  /// ```
  ///
  /// ### Return
  /// `true` if the method is declared as asynchronous (returns a [Future] or
  /// is marked with `async`), otherwise `false`.
  /// {@endtemplate}
  bool isAsync();
  
  /// Gets the method that this method overrides.
  ///
  /// {@template method_overridden_method}
  /// Returns:
  /// - The [Method] from the superclass being overridden
  /// - `null` if this doesn't override any method
  ///
  /// Note:
  /// Only checks direct overrides in the immediate superclass.
  /// {@endtemplate}
  Method? getOverriddenMethod();
  
  /// Invokes the method on an instance with named arguments.
  ///
  /// {@template method_invoke}
  /// Parameters:
  /// - [instance]: The object instance (null for static methods)
  /// - [arguments]: Optional named arguments
  ///
  /// Returns:
  /// - The method's return value
  /// - May return `null` for void methods
  ///
  /// Throws:
  /// - [InvalidArgumentException] if arguments don't match parameters
  /// - [NoSuchMethodException] for invalid invocations
  ///
  /// Example:
  /// ```dart
  /// final result = method.invoke(instance, {'param1': value});
  /// 
  /// final result = method.invokeWithArgs(instance, null, [arg1, arg2]);
  /// ```
  /// {@endtemplate}
  dynamic invoke(Object? instance, [Map<String, dynamic>? arguments, List<dynamic> args = const []]);
  
  /// Creates a Method instance from reflection metadata.
  ///
  /// {@template method_factory}
  /// Parameters:
  /// - [declaration]: The method reflection metadata
  /// - [domain]: The protection domain for security
  ///
  /// Returns:
  /// - A concrete [Method] implementation
  ///
  /// Typical implementation:
  /// ```dart
  /// static Method declared(MethodDeclaration d, ProtectionDomain p) {
  ///   return _MethodImpl(d, p);
  /// }
  /// ```
  /// {@endtemplate}
  static Method declared(MethodDeclaration declaration, ProtectionDomain domain) {
    return _Method(declaration, domain);
  }
}