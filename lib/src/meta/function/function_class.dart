import 'dart:collection';

import 'package:jetleaf_build/jetleaf_build.dart';

import '../class/class.dart';
import '../class/delegating_class.dart';
import '../class_loader/default_class_loader.dart';
import '../method/method.dart';
import '../protection_domain/protection_domain.dart';

part '_function_class.dart';

/// Reflective representation of a Dart **function type** as a *structural
/// signature*, not a runtime class.
///
/// {@template function_class}
/// [FunctionClass] is a specialized [Class] abstraction used **only within
/// JetLeaf’s meta-model** to describe *function-typed parameters and methods*.
///
/// Unlike regular classes:
/// - A [FunctionClass] **cannot** be obtained via `Class.of()`
/// - It **does not represent a concrete runtime class**
/// - It exists solely to model the **shape of a function type**
///
/// This distinction is critical for reflection-heavy APIs such as:
/// - [Parameter]
/// - [Method]
/// - Dependency resolution
/// - Executable selection
///
/// ---
///
/// ## Why FunctionClass Exists
///
/// Consider the following parameters:
///
/// ```dart
/// void a(String user) {}
/// void b(String Function() user) {}
/// ```
///
/// From Dart’s type system alone, both appear as `String` at the top level.
/// However, semantically:
///
/// - `a` receives a **value**
/// - `b` receives a **callable contract**
///
/// JetLeaf preserves this distinction:
///
/// | Parameter | Parameter.getClass() | Meaning |
/// |----------|----------------------|--------|
/// | `String user` | `Class<String>` | Concrete value |
/// | `String Function() user` | `FunctionClass` | Callable signature |
///
/// This allows users of the meta-API to:
/// - Detect callable parameters
/// - Inspect return types
/// - Inspect parameter types
/// - Reason about invocation without execution
///
/// ---
///
/// ## Creation Model
///
/// [FunctionClass] instances are **never created directly**.
/// They are synthesized internally by JetLeaf when:
///
/// - Inspecting a [Parameter] whose type is a function
/// - Inspecting a [Method] return type that is a function
///
/// This ensures:
/// - Structural accuracy
/// - No runtime coupling
/// - Consistent reflection behavior
///
/// ---
///
/// ## Relationship to Class API
///
/// While [FunctionClass] implements [Class<Function>], it intentionally
/// diverges in behavior:
///
/// - It represents a **type signature**, not a concrete class
/// - Many standard [Class] operations are delegated or disabled
/// - Its primary purpose is *introspection*, not instantiation
///
/// Think of [FunctionClass] as:
///
/// > “A schema describing *how* a function looks, not *what* it is.”
///
/// {@endtemplate}
abstract class FunctionClass extends DelegatingClass<Function> implements Class<Function> {

  /// Returns the **declared return type** of the function signature.
  ///
  /// {@template function_class_get_return_type}
  /// This describes what the function *produces* when invoked,
  /// not the type of the parameter holding it.
  ///
  /// ### Example
  /// ```dart
  /// // Parameter type:
  /// // String Function() user
  ///
  /// final param = method.getParameter('user');
  /// final fc = param.getClass() as FunctionClass;
  ///
  /// fc.getReturnType(); // → Class<String>
  /// ```
  ///
  /// This enables precise differentiation between:
  /// - `String user`
  /// - `String Function() user`
  /// {@endtemplate}
  Class<Object> getReturnType();

  /// Returns the ordered list of **parameter types** accepted by the function.
  ///
  /// {@template function_class_get_parameters}
  /// These parameters describe the callable contract itself,
  /// not the surrounding method or constructor.
  ///
  /// ### Example
  /// ```dart
  /// // Parameter type:
  /// // int Function(String name, bool active)
  ///
  /// final fc = param.getClass() as FunctionClass;
  ///
  /// fc.getParameters(); // → [Class<String>, Class<bool>]
  /// ```
  ///
  /// This allows tooling and frameworks to:
  /// - Validate compatibility
  /// - Perform dependency resolution
  /// - Generate adapters or proxies
  /// {@endtemplate}
  List<Class<Object>> getParameters();

  /// Indicates whether the function type itself is nullable.
  ///
  /// {@template function_class_get_is_nullable}
  /// This reflects Dart null-safety at the *type-signature* level:
  ///
  /// - `String Function()` → non-nullable
  /// - `String Function()?` → nullable
  ///
  /// This does **not** describe the return type’s nullability.
  /// {@endtemplate}
  bool getIsNullable();

  /// Returns the reflective `call()` method if the function originates
  /// from a callable object.
  ///
  /// {@template function_class_get_method_call}
  /// This is primarily used when a function type is backed by
  /// an object implementing `call()`.
  ///
  /// For pure function signatures, this may be `null`.
  ///
  /// This distinction allows JetLeaf to unify:
  /// - Lambdas
  /// - Function tear-offs
  /// - Callable objects
  /// {@endtemplate}
  Method? getMethodCall();

  /// Returns the low-level declaration describing this function signature.
  ///
  /// {@template function_class_get_function_declaration}
  /// The [FunctionLinkDeclaration] is the canonical, immutable
  /// representation of the function’s structure.
  ///
  /// It is used internally for:
  /// - Type comparison
  /// - Generic substitution
  /// - Signature matching
  /// - Executable resolution
  /// {@endtemplate}
  FunctionLinkDeclaration getFunctionDeclaration();

  @override
  Declaration getDeclaration() => getFunctionDeclaration();

  /// Creates a [FunctionClass] bound to a function declaration.
  ///
  /// {@template function_class_linked}
  /// This factory is **internal by design** and is used by JetLeaf’s
  /// meta-model when constructing [Parameter] and [Method] descriptors.
  ///
  /// End users should never need to call this directly.
  /// {@endtemplate}
  /// 
  /// {@macro function_class}
  static FunctionClass linked(FunctionLinkDeclaration declaration, [ProtectionDomain? pd]) => _FunctionClass(declaration, pd ?? ProtectionDomain.current());
}