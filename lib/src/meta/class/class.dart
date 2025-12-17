import 'dart:async';
import 'dart:collection';

import 'package:jetleaf_build/jetleaf_build.dart';

import '../../commons/version.dart';
import '../../extensions/primitives/iterable.dart';
import '../../extensions/primitives/string.dart';
import '../../exceptions.dart';
import '../../utils/lang_utils.dart';
import '../class_loader/default_class_loader.dart';
import '../annotation/annotation.dart';
import '../constructor/constructor.dart';
import '../enum/enum_value.dart';
import '../field/field.dart';
import '../core.dart';
import '../function/function_class.dart';
import '../generic_source.dart';
import '../method/method.dart';
import '../protection_domain/protection_domain.dart';
import '../qualified_name/qualified_name.dart';
import '../record/record_class.dart';
import 'class_type.dart';

part '_class.dart';

/// {@template class_interface}
/// Provides reflective access to Dart class types and their metadata.
///
/// This interface enables runtime inspection and manipulation of class:
/// - Type information and hierarchy
/// - Constructors and instantiation
/// - Methods and fields
/// - Annotations and metadata
/// - Generic type parameters
///
/// {@template class_interface_features}
/// ## Key Features
/// - Type-safe reflection operations
/// - Generic type parameter support
/// - Class hierarchy navigation
/// - Instance creation
/// - Member inspection
/// - Annotation access
///
/// ## Implementation Notes
/// Concrete implementations typically wrap platform-specific reflection objects
/// while providing this uniform interface.
/// {@endtemplate}
///
/// {@template class_interface_example}
/// ## Example Usage
/// ```dart
/// // Get class metadata
/// final userClass = Class.forType<User>();
///
/// // Create instances
/// final user = userClass.newInstance({'name': 'Alice', 'age': 30});
///
/// // Inspect fields
/// final nameField = userClass.getField('name');
/// print(nameField?.get(user)); // 'Alice'
///
/// // Check type hierarchy
/// if (userClass.isSubclassOf(Class.forType<Person>())) {
///   print('User is a Person subclass');
/// }
/// ```
/// {@endtemplate}
///
/// Type Parameters:
/// - `T`: The class type being reflected
/// {@endtemplate}
@Generic(Class)
abstract class Class<T> extends Source implements FieldAccess, QualifiedName, GenericSource {
  @override
  Declaration getDeclaration() {
    checkAccess("getDeclaration", DomainPermission.READ_TYPE_INFO);
    return getClassDeclaration();
  }

  /// Gets the type declaration of this class.
  ///
  /// {@template class_get_type_declaration}
  /// Returns:
  /// - The [ClassDeclaration] representing the class
  /// - `null` for core types or unavailable declarations
  /// {@endtemplate}
  ClassDeclaration getClassDeclaration();

  // ---------------------------------------------------------------------------------------------------------
  // === Name Information ===
  // ---------------------------------------------------------------------------------------------------------
  
  /// Gets the simple class name without package or generic information.
  ///
  /// {@template class_simple_name}
  /// Returns:
  /// - The base class name (e.g., `List` for `List<String>`)
  ///
  /// Example:
  /// ```dart
  /// Class.forType<List<String>>().getSimpleName(); // 'List'
  /// ```
  /// {@endtemplate}
  String getSimpleName();

  /// Gets the canonical name with complete generic type information.
  ///
  /// {@template class_canonical_name}
  /// Returns:
  /// - The complete type signature including all generic parameters
  /// - Differs from [getName] by preserving exact generic specifications
  /// - Used for precise type matching and cache keys
  ///
  /// ## Canonical vs Name
  /// - **getName()**: May return simplified or display-friendly names
  /// - **getCanonicalName()**: Always returns complete, unambiguous type signature
  ///
  /// Example:
  /// ```dart
  /// final mapClass = Class.forType<Map<String, List<int>>>();
  /// print(mapClass.getName());          // May return 'Map'
  /// print(mapClass.getCanonicalName()); // Returns 'Map<String, List<int>>'
  /// ```
  ///
  /// ## Use Cases
  /// - Type equality comparisons
  /// - Cache key generation
  /// - Serialization/deserialization
  /// - Generic type preservation
  /// {@endtemplate}
  String getCanonicalName();

  // ---------------------------------------------------------------------------------------------------------
  // === Package Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Retrieves the **package URI** where this class is defined.
  ///
  /// {@template class_package_uri}
  /// This method returns a string identifying the package location of the
  /// class source. It is typically used for diagnostics, reflection, or
  /// resolving resources relative to the package.
  ///
  /// ### Returns
  /// - The package URI as a string, e.g., `package:myapp/models.dart`.
  /// - `dart:core` for Dart core types (e.g., `int`, `String`).
  /// - May be empty for dynamically generated or runtime-only types.
  ///
  /// ### Usage
  /// ```dart
  /// print(myClass.getPackageUri()); // → package:myapp/models.dart
  /// ```
  ///
  /// {@endtemplate}
  String getPackageUri();

  /// Retrieves the **package metadata** object containing this class.
  ///
  /// {@template class_get_package}
  /// Provides access to higher-level package information such as name,
  /// version, and other metadata tracked by JetLeaf’s reflection system.
  ///
  /// ### Returns
  /// - A [Package] object representing the package containing the class.
  /// - `null` if the class belongs to Dart core types or if package
  ///   information is unavailable.
  ///
  /// ### Usage
  /// ```dart
  /// final package = myClass.getPackage();
  /// if (package != null) {
  ///   print(package.getName());
  /// }
  /// ```
  ///
  /// {@endtemplate}
  Package? getPackage();

  /// Returns the concrete generic type arguments declared on this class.
  ///
  /// {@template class_get_type_arguments}
  /// This method exposes the resolved generic parameters associated with
  /// this [Class] instance.
  ///
  /// For example, given:
  /// ```dart
  /// class Box<T> {}
  /// class StringBox extends Box<String> {}
  /// ```
  /// Calling `getTypeArguments()` on `Class<StringBox>` would return a list
  /// containing `Class<String>`.
  ///
  /// ### Behavior
  /// - Returns an empty list if the class is not generic.
  /// - The order of elements matches the declaration order of the
  ///   type parameters.
  /// - Returned [Class] objects represent the *actual* resolved types,
  ///   not just the formal type variables.
  ///
  /// ### Returns
  /// - A list of [Class<Object>] representing the resolved type arguments.
  /// {@endtemplate}
  List<Class<Object>> getTypeArguments();

  /// Returns metadata links describing how generic type arguments are bound.
  ///
  /// {@template class_get_type_argument_links}
  /// This method provides structural information about the relationship
  /// between declared type parameters and their resolved arguments.
  ///
  /// [LinkDeclaration] instances may encode:
  /// - The source type parameter,
  /// - The target concrete type,
  /// - Variance or positional binding information,
  /// - Indirections through inherited or delegated generic declarations.
  ///
  /// This is primarily intended for advanced reflection, diagnostics,
  /// and framework-level type resolution.
  ///
  /// ### Behavior
  /// - Returns an empty list if no generic linkage information is available.
  /// - The order corresponds to the declaration order of type parameters.
  ///
  /// ### Returns
  /// - A list of [LinkDeclaration] objects describing generic bindings.
  /// {@endtemplate}
  List<LinkDeclaration> getTypeArgumentLinks();

  // ---------------------------------------------------------------------------------------------------------
  // === Type Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Returns the **runtime-resolved Dart type** represented by this [Class].
  ///
  /// {@template class_get_type}
  /// This method exposes the `Type` object as it exists at runtime after
  /// Dart’s generic resolution and potential type erasure have been applied.
  ///
  /// ### Returns
  /// - A Dart [Type] instance corresponding to the resolved runtime type.
  /// - Generic parameters are included *only if* they are preserved by the
  ///   runtime and available through reflection.
  ///
  /// ### Usage
  /// ```dart
  /// final type = clazz.getType();
  /// print(type); // e.g. List<String> or List<dynamic>
  /// ```
  ///
  /// ### Notes
  /// - Due to Dart’s runtime model, generic information may be partially or
  ///   fully erased depending on context.
  /// - This method reflects what Dart itself recognizes as the type at
  ///   runtime, not necessarily the type originally requested by JetLeaf.
  ///
  /// {@endtemplate}
  Type getType();

  /// Returns the **original, JetLeaf-resolved type** requested by this [Class].
  ///
  /// {@template class_get_original}
  /// Unlike [getType], this method exposes the type as **intended and tracked
  /// by JetLeaf’s reflection system**, even when Dart’s runtime has erased or
  /// altered generic information.
  ///
  /// This distinction exists because JetLeaf employs its own strategy for
  /// modeling generic types and mitigating Dart’s type-erasure behavior.
  ///
  /// ### Returns
  /// - The underlying Dart [Type] corresponding to the original generic
  ///   declaration.
  /// - May differ from [getType] when generic parameters are erased or
  ///   normalized by the runtime.
  ///
  /// ### Example
  /// ```dart
  /// final runtimeType = clazz.getType();     // e.g. List<dynamic>
  /// final originalType = clazz.getOriginal(); // e.g. List<String>
  /// ```
  ///
  /// ### Design Notes
  /// - Use [getOriginal] when exact generic intent matters (e.g. dependency
  ///   resolution, serialization, or code generation).
  /// - Use [getType] when interacting with Dart runtime APIs or type checks.
  ///
  /// {@endtemplate}
  Type getOriginal();

  // ---------------------------------------------------------------------------------------------------------
  // === Type Design ===
  // ---------------------------------------------------------------------------------------------------------

  /// Checks whether this class represents a **record type**.
  ///
  /// {@template class_is_record}
  /// Returns:
  /// - `true` if this class represents a Dart **record type**
  ///   (e.g. `(int, String)` or `({int id, String name})`).
  /// - `false` for all non-record types such as classes, enums, functions,
  ///   mixins, or primitives.
  ///
  /// Record types are a Dart 3.0+ language feature that allow lightweight,
  /// immutable aggregates with positional and/or named fields.
  ///
  /// ### Usage
  /// ```dart
  /// if (clazz.isRecord()) {
  ///   // Treat as a record type and inspect its fields
  /// }
  /// ```
  ///
  /// ### Design Notes
  /// - This method is intended for reflective and type-introspection logic
  ///   that needs to distinguish record types from traditional classes.
  /// - A `true` result indicates the underlying reflective model represents
  ///   a record, not merely a class containing record-typed fields.
  ///
  /// ### Compatibility
  /// - Available for Dart 3.0+ where records are supported by the language.
  /// - Framework support for records may be partial depending on the
  ///   JetLeaf version.
  ///
  /// {@endtemplate}
  bool isRecord();

  /// Checks whether this class represents a **function type**.
  ///
  /// {@template class_is_function}
  /// Returns:
  /// - `true` if this class represents a function or callable type
  ///   (i.e. `Function`, a function signature, or a framework-recognized
  ///   function class).
  /// - `false` for all non-function types such as classes, enums, records,
  ///   mixins, or primitives.
  ///
  /// A function type may represent:
  /// - The Dart core `Function` type
  /// - A concrete function signature (e.g. `int Function(String)`)
  /// - A framework-specific `FunctionClass` abstraction used to model
  ///   executable types reflectively
  ///
  /// ### Usage
  /// ```dart
  /// if (clazz.isFunction()) {
  ///   // Treat as an invokable function type
  /// }
  /// ```
  ///
  /// ### Design Notes
  /// - This method is used by reflection, invocation, and executable-selection
  ///   logic to determine whether a type should be treated as callable.
  /// - Implementations typically check whether the underlying reflective model
  ///   resolves to a `FunctionClass`.
  /// - A `true` result does **not** guarantee invokability without parameters;
  ///   callers must still inspect parameter metadata.
  ///
  /// ### Compatibility
  /// - Supported across all Dart versions where function types are available.
  /// - Independent of record-type support.
  ///
  /// {@endtemplate}
  bool isFunction();

  /// Checks if this class represents a standard class type.
  ///
  /// {@template class_is_class}
  /// Returns:
  /// - `true` for regular class declarations
  /// - `false` for other declaration types (mixin, enum, etc.)
  ///
  /// Example:
  /// ```dart
  /// class User {}
  /// Class<User>().isClass(); // true
  /// ```
  /// {@endtemplate}
  /// 
  /// **Note**: This method will always return true since version 1.0.9.
  /// Make use of other methods to distinguish which [Class] API you are accessing.
  /// 
  /// See: [isMixin], [isEnum]
  /// 
  /// Deprecated
  bool isClass();

  /// Checks if this class is a mixin declaration.
  ///
  /// {@template class_is_mixin}
  /// Returns:
  /// - `true` if declared with `mixin` keyword
  /// - `false` for regular classes
  ///
  /// Example:
  /// ```dart
  /// mixin Serializable {}
  /// Class<Serializable>().isMixin(); // true
  /// ```
  /// {@endtemplate}
  bool isMixin();

  /// Checks if this class is an enum declaration.
  ///
  /// {@template class_is_enum}
  /// Returns:
  /// - `true` for enum types
  /// - `false` for other class kinds
  ///
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// Class<Status>().isEnum(); // true
  /// ```
  /// {@endtemplate}
  bool isEnum();

  // ---------------------------------------------------------------------------------------------------------
  // === Access Comparators ===
  // ---------------------------------------------------------------------------------------------------------

  /// Checks if the display name matches the canonical name.
  /// 
  /// {@template class_is_canonical}
  /// Returns:
  /// - `true` if [getName] and [getCanonicalName] return identical values
  /// - `false` if they differ (e.g., simplified vs complete generic names)
  ///
  /// ## Purpose
  /// Determines whether the class name includes complete generic information
  /// or uses a simplified representation. This is important for:
  /// - Type resolution accuracy
  /// - Generic parameter preservation
  /// - Cache key consistency
  ///
  /// ## Example
  /// ```dart
  /// final listClass = Class.forType<List<String>>();
  /// if (!listClass.isCanonical()) {
  ///   // Use getCanonicalName() for precise type information
  ///   final fullName = listClass.getCanonicalName();
  /// }
  /// ```
  ///
  /// ## Implementation Note
  /// Normally, [getName] can return simplified names for display purposes,
  /// while [getCanonicalName] preserves complete generic specifications.
  /// This method helps determine which name format is being used.
  /// {@endtemplate}
  bool isCanonical();

  /// Checks if this class is abstract.
  ///
  /// {@template class_is_abstract}
  /// Returns:
  /// - `true` if the class is declared with `abstract` modifier
  /// - `false` for concrete classes
  ///
  /// Example:
  /// ```dart
  /// abstract class Animal {}
  /// class Dog extends Animal {}
  ///
  /// Class.forType<Animal>().isAbstract(); // true
  /// Class.forType<Dog>().isAbstract();    // false
  /// ```
  /// {@endtemplate}
  bool isAbstract();

  /// Checks if this class is final (cannot be extended).
  ///
  /// {@template class_is_final}
  /// Returns:
  /// - `true` if the class is declared with `final` modifier
  /// - `false` for extendable classes
  ///
  /// Example:
  /// ```dart
  /// final class Immutable {}
  /// class Mutable {}
  ///
  /// Class.forType<Immutable>().isFinal(); // true
  /// Class.forType<Mutable>().isFinal();   // false
  /// ```
  /// {@endtemplate}
  bool isFinal();

  /// Checks if this class is sealed (exhaustive pattern matching).
  ///
  /// {@template class_is_sealed}
  /// Returns:
  /// - `true` if the class is declared with `sealed` modifier
  /// - `false` for non-sealed classes
  ///
  /// Note:
  /// Sealed classes enable exhaustive checking in pattern matching.
  /// {@endtemplate}
  bool isSealed();

  /// Checks if this class is an interface (abstract with no concrete members).
  ///
  /// {@template class_is_interface}
  /// Returns:
  /// - `true` if the class serves as a pure interface
  /// - `false` for classes with implementations
  ///
  /// Example:
  /// ```dart
  /// interface class PureInterface {
  ///   void method();
  /// }
  /// ```
  /// {@endtemplate}
  bool isInterface();

  /// Checks if this class is a base class (can be extended but not implemented).
  ///
  /// {@template class_is_base}
  /// Returns:
  /// - `true` if the class is declared with `base` modifier
  /// - `false` for non-base classes
  ///
  /// Note:
  /// Base classes enforce inheritance control.
  /// {@endtemplate}
  bool isBase();

  /// Checks if this class is invokable.
  /// 
  /// Invokable classes are classes that is not an abstract class or an abstract that has
  /// atleast one factory constructor.
  ///
  /// {@template class_is_invokable}
  /// Returns:
  /// - `true` if the class is invokable
  /// - `false` for non-invokable classes
  ///
  /// Example:
  /// ```dart
  /// class Invokable {}
  /// class NonInvokable {}
  ///
  /// Class.forType<Invokable>().isInvokable(); // true
  /// Class.forType<NonInvokable>().isInvokable();   // false
  /// ```
  /// {@endtemplate}
  bool isInvokable();

    /// Checks whether this class represents the `void` type.
  ///
  /// {@template class_is_void}
  /// Returns:
  /// - `true` if the class corresponds to Dart's `void` type
  /// - `false` for all other types
  ///
  /// ## Notes
  /// - Useful in reflection or code-generation contexts to differentiate
  ///   between methods that return `void` versus any other type.
  /// - Aligns with `Type`-level checks but operates on the JetLeaf `Class` abstraction.
  /// {@endtemplate}
  bool isVoid();

  /// Checks whether this class represents the `dynamic` type.
  ///
  /// {@template class_is_dynamic}
  /// Returns:
  /// - `true` if the class corresponds to Dart's `dynamic` type
  /// - `false` for all other types
  ///
  /// ## Notes
  /// - Essential for reflection, type resolution, and argument normalization.
  /// - Differentiates between fully typed generics and untyped or dynamic values.
  /// {@endtemplate}
  bool isDynamic();

  /// Indicates whether this class is **synthetic** (framework-generated)
  /// rather than directly declared in user source code.
  ///
  /// {@template class_is_synthetic}
  /// A *synthetic class* is a logical or derived representation created
  /// by JetLeaf to model language constructs that do not have a concrete,
  /// user-declared class definition.
  ///
  /// Synthetic classes commonly arise from:
  /// - Function signatures (e.g. [FunctionClass])
  /// - Record types (future support)
  /// - Parameter or method-derived types
  /// - Internal framework adapters or proxies
  ///
  /// ### Behavior
  /// - `true` if the class is generated or inferred by the framework
  /// - `false` if the class corresponds to a real, user-declared type
  ///
  /// ### Example
  /// ```dart
  /// final param = method.getParameter('callback');
  /// final cls = param.getClass();
  ///
  /// cls.isSynthetic(); // → true for FunctionClass
  /// ```
  ///
  /// ### Notes
  /// - Synthetic classes typically cannot be instantiated directly.
  /// - They may not have a source file, package URI, or constructors.
  /// - This flag is essential for distinguishing *structural types*
  ///   from *runtime types* during reflection and dependency resolution.
  ///
  /// {@endtemplate}
  bool isSynthetic();

  /// {@template method_isAsync}
  /// Determines whether this method is asynchronous.
  ///
  /// A method is considered asynchronous if its declared return type
  /// is either [Future] or [FutureOr]. This check allows AOP or reflection
  /// mechanisms to distinguish between synchronous and asynchronous methods
  /// when performing advice invocation, proxying, or instrumentation.
  ///
  /// ## Example
  /// ```dart
  /// class UserService {
  ///   Future<void> fetchUser() async {}
  ///   void saveUser() {}
  /// }
  ///
  /// final methodFetch = Class(UserService).getMethod('fetchUser');
  /// final methodSave = Class(UserService).getMethod('saveUser');
  ///
  /// print(methodFetch.isAsync()); // true
  /// print(methodSave.isAsync());  // false
  /// ```
  ///
  /// @return `true` if the method's return type is [Future] or [FutureOr],
  ///         `false` otherwise.
  /// {@endtemplate}
  bool isAsync();

  // ---------------------------------------------------------------------------------------------------------
  // === Type Comparators ===
  // ---------------------------------------------------------------------------------------------------------

  /// Checks if this class represents an array type.
  ///
  /// {@template class_is_array}
  /// Returns:
  /// - `true` for List types with fixed length semantics
  /// - `false` for regular List types
  /// {@endtemplate}
  bool isArray();

  /// Checks if this class represents a primitive type.
  ///
  /// {@template class_is_primitive}
  /// Returns:
  /// - `true` for Dart core primitives (int, double, bool, String, etc.)
  /// - `false` for object types
  /// {@endtemplate}
  bool isPrimitive();

  /// Checks if an object is an instance of this class.
  ///
  /// {@template class_is_instance}
  /// Parameters:
  /// - [obj]: The object to check
  ///
  /// Returns:
  /// - `true` if obj is non-null and an instance of T
  /// - `false` otherwise
  ///
  /// Example:
  /// ```dart
  /// Class.forType<String>().isInstance('hello'); // true
  /// ```
  /// {@endtemplate}
  bool isInstance(Object? obj);
  
  /// Checks type assignability from another class.
  ///
  /// {@template class_is_assignable}
  /// Parameters:
  /// - [other]: The potential supertype to check
  ///
  /// Returns:
  /// - `true` if this class can be assigned to [other]
  /// - `false` otherwise
  ///
  /// Example:
  /// ```dart
  /// Class.forType<Circle>().isAssignableFrom(Class.forType<Shape>()); // true
  /// ```
  /// 
  /// #### Type Assignability Table:
  /// ```sql
  /// DART TYPE ASSIGNABILITY TABLE
  /// ────────────────────────────────────────────────────────────────────────────
  /// From (B) → To (A)                     A.isAssignableFrom(B)   Valid?   Notes
  /// ────────────────────────────────────────────────────────────────────────────
  /// Object    ← String                   ✅ true                  ✅      String extends Object
  /// String    ← Object                   ❌ false                 ❌      Super not assignable from subclass
  /// num       ← int                      ✅ true                  ✅      int is a subclass of num
  /// int       ← num                      ❌ false                 ❌      num is broader than int
  /// List<int> ← List<int>                ✅ true                  ✅      Same type
  /// List<T>   ← List<S>                  ❌ false                 ❌      Dart generics are invariant
  /// List<dynamic> ← List<int>            ❌ false                 ❌      Still invariant
  /// A         ← B (B extends A)          ✅ true                  ✅      Subclass to superclass is OK
  /// A         ← C (unrelated)            ❌ false                 ❌      No inheritance/interface link
  /// Interface ← Class implements Itf     ✅ true                  ✅      Implements is assignable to interface
  /// Mixin     ← Class with Mixin         ✅ true                  ✅      Mixed-in type present
  /// dynamic   ← anything                 ✅ true                  ✅      dynamic accepts all types
  /// anything  ← dynamic                  ✅ true (unsafe)         ✅      Allowed but unchecked
  /// Never     ← anything                 ❌ false                 ❌      Never can’t accept anything
  /// anything  ← Never                    ✅ true                  ✅      Never fits anywhere (bottom type)
  /// ────────────────────────────────────────────────────────────────────────────
  ///
  /// RULE OF THUMB:
  /// A.isAssignableFrom(B) → Can you do: A a = B();
  /// ✓ Subclass → Superclass: OK
  /// ✗ Superclass → Subclass: Not OK
  /// ✓ Class implements Interface → Interface: OK
  /// ✗ Interface → Class: Not OK
  /// ✓ Identical types: OK
  /// ✗ Unrelated types: Not OK
  /// ```
  ///
  /// Checks if this type is assignable from the given [other] type.
  /// 
  /// Returns `true` if a value of type [other] can be assigned to a variable of this type.
  /// This follows Dart's assignability rules including inheritance, interfaces, and mixins.
  /// {@endtemplate}
  bool isAssignableFrom(Class other);

  /// Checks if this type is assignable to another type.
  ///
  /// {@template class_is_assignable_to}
  /// Parameters:
  /// - [other]: The target type to check assignability to
  ///
  /// Returns:
  /// - `true` if this type can be assigned to [other]
  /// - `false` otherwise
  ///
  /// ## Assignability Rules
  /// This method implements Dart's type assignability rules:
  /// - Subclass to superclass: ✅ Allowed
  /// - Superclass to subclass: ❌ Not allowed
  /// - Class to implemented interface: ✅ Allowed
  /// - Interface to implementing class: ❌ Not allowed
  /// - Identical types: ✅ Allowed
  /// - Unrelated types: ❌ Not allowed
  ///
  /// #### Type Assignability Table:
  /// ```sql
  /// DART TYPE ASSIGNABILITY TABLE
  /// ────────────────────────────────────────────────────────────────────────────
  /// From (A) → To (B)                   A.isAssignableTo(B)   Valid?   Notes
  /// ────────────────────────────────────────────────────────────────────────────
  /// String    → Object                 ✅ true               ✅      String extends Object
  /// Object    → String                 ❌ false              ❌      Superclass to subclass not allowed
  /// int       → num                    ✅ true               ✅      int is a subtype of num
  /// num       → int                    ❌ false              ❌      Can't assign broader to narrower
  /// List<int> → List<int>              ✅ true               ✅      Identical type
  /// List<S>   → List<T>                ❌ false              ❌      Dart generics are invariant
  /// List<int> → List<dynamic>          ❌ false              ❌      Invariant generics
  /// B         → A (B extends A)        ✅ true               ✅      Subclass to superclass: OK
  /// C         → A (no relation)        ❌ false              ❌      Unrelated types
  /// Class     → Interface (implements) ✅ true               ✅      Implements interface
  /// Class     → Mixin (with mixin)     ✅ true               ✅      Class includes mixin
  /// anything  → dynamic                ✅ true               ✅      Everything is assignable to dynamic
  /// dynamic   → anything               ✅ true (unchecked)   ✅      Allowed but unsafe
  /// anything  → Never                  ❌ false              ❌      Can't assign anything to Never
  /// Never     → anything               ✅ true               ✅      Never fits anywhere
  /// ────────────────────────────────────────────────────────────────────────────
  ///
  /// RULE OF THUMB:
  /// A.isAssignableTo(B) → Can you do: B b = A();
  /// ✓ Subclass → Superclass: OK
  /// ✗ Superclass → Subclass: Not OK
  /// ✓ Class → Interface it implements: OK
  /// ✗ Interface → Class: Not OK
  /// ✓ Identical types: OK
  /// ✗ Unrelated types: Not OK
  /// ```
  ///
  /// ## Example
  /// ```dart
  /// final stringClass = Class.forType<String>();
  /// final objectClass = Class.forType<Object>();
  /// 
  /// print(stringClass.isAssignableTo(objectClass)); // true - String → Object
  /// print(objectClass.isAssignableTo(stringClass)); // false - Object → String
  /// ```
  ///
  /// ## Relationship to isAssignableFrom
  /// This is the inverse of [isAssignableFrom]:
  /// - `A.isAssignableTo(B)` ≡ `B.isAssignableFrom(A)`
  /// - Use [isAssignableTo] when asking "Can I assign this to that?"
  /// - Use [isAssignableFrom] when asking "Can that be assigned to this?"
  /// {@endtemplate}
  bool isAssignableTo(Class other);
  
  /// Checks if this class directly extends another class.
  ///
  /// {@template class_is_subclass}
  /// Parameters:
  /// - [other]: The potential superclass
  ///
  /// Returns:
  /// - `true` if this directly extends [other]
  /// - `false` otherwise
  ///
  /// See also:
  /// - [isAssignableFrom] for indirect hierarchy checks
  /// {@endtemplate}
  bool isSubclassOf(Class other);

  // ---------------------------------------------------------------------------------------------------------
  // === Super Class Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets the direct superclass with proper generic typing.
  ///
  /// {@template class_get_superclass}
  /// Type Parameters:
  /// - `S`: The expected superclass type
  ///
  /// Returns:
  /// - The superclass with resolved generic parameters
  /// - `null` if no superclass exists
  ///
  /// Example:
  /// ```dart
  /// class Parent<T> {}
  /// class Child extends Parent<String> {}
  ///
  /// final childClass = Class.forType<Child>();
  /// final parentClass = childClass.getSuperClass<Parent>();
  /// print(parentClass?.componentType<String>()); // Class<String>
  /// ```
  /// {@endtemplate}
  Class<S>? getSuperClass<S>();

  /// Gets the generic arguments from the superclass declaration.
  ///
  /// {@template class_get_superclass_arguments}
  /// Type Parameters:
  /// - `S`: The superclass type to examine
  ///
  /// Returns:
  /// - List of generic type arguments
  /// - Empty list if no generics exist
  ///
  /// Example:
  /// ```dart
  /// class Converter extends ConverterFactory<num, num> {}
  ///
  /// final args = Class.forType<Converter>()
  ///   .getSuperClassArguments<ConverterFactory>();
  /// print(args); // [Class<num>, Class<num>]
  /// ```
  /// {@endtemplate}
  List<Class> getSuperClassArguments();

  /// Gets the declared superclass without generic resolution.
  ///
  /// {@template class_get_declared_superclass}
  /// Returns:
  /// - The raw superclass as declared in source
  /// - `null` if no superclass exists
  ///
  /// Contrast with [getSuperClass] which resolves generics.
  /// {@endtemplate}
  Class? getDeclaredSuperClass();

  // ---------------------------------------------------------------------------------------------------------
  // === Sub Class Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets all direct subclasses of this class.
  ///
  /// {@template class_get_subclasses}
  /// Returns:
  /// - List of all classes that directly extend this class
  /// - Empty list if no subclasses exist
  ///
  /// Note:
  /// Only returns classes known to the current reflection context.
  /// {@endtemplate}
  List<Class> getSubClasses();

  /// Gets a specific direct subclass by type.
  ///
  /// {@template class_get_subclass}
  /// Type Parameters:
  /// - `S`: The expected subclass type
  ///
  /// Returns:
  /// - The subclass if it exists
  /// - `null` if no matching subclass found
  /// {@endtemplate}
  Class<S>? getSubClass<S>();

  // ---------------------------------------------------------------------------------------------------------
  // === Interface Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets all interfaces directly implemented by this class.
  /// 
  /// **Note**: For a mixin, this method returns the constraints applied to the mixin.
  ///
  /// {@template class_get_all_interfaces}
  /// Returns:
  /// - List of all interfaces (including transitive)
  /// - Empty list if no interfaces implemented
  ///
  /// Note:
  /// Includes both explicitly implemented and inherited interfaces.
  /// {@endtemplate}
  List<Class> getAllInterfaces();

  /// Gets implemented interfaces of specific type.
  /// 
  /// **Note**: For a mixin, this method returns the constraints applied to the mixin.
  ///
  /// {@template class_get_interfaces}
  /// Type Parameters:
  /// - `I`: The interface type to filter for
  ///
  /// Returns:
  /// - List of matching interfaces
  /// - Empty list if none found
  /// {@endtemplate}
  List<Class<I>> getInterfaces<I>();

  /// Gets a specific implemented interface.
  /// 
  /// **Note**: For a mixin, this method returns a specific constraint applied to the mixin.
  ///
  /// {@template class_get_interface}
  /// Type Parameters:
  /// - `I`: The exact interface type to retrieve
  ///
  /// Returns:
  /// - The interface if implemented
  /// - `null` if not found
  /// {@endtemplate}
  Class<I>? getInterface<I>();

  /// Gets generic arguments from a specific implemented interface.
  /// 
  /// **Note**: For a mixin, this method returns a specific constraint arguments applied to the mixin.
  ///
  /// {@template class_get_interface_arguments}
  /// Type Parameters:
  /// - `I`: The interface type to examine
  ///
  /// Returns:
  /// - List of generic type arguments
  /// - Empty list if interface has no generics
  /// {@endtemplate}
  List<Class> getInterfaceArguments<I>();

  /// Gets generic arguments from all implemented interfaces.
  /// 
  /// **Note**: For a mixin, this method returns all constraint arguments applied to the mixin.
  ///
  /// {@template class_get_all_interface_arguments}
  /// Returns:
  /// - Flattened list of all interface generic arguments
  /// - Empty list if no generics exist
  /// {@endtemplate}
  List<Class> getAllInterfaceArguments();

  /// Gets all directly declared interfaces (non-transitive).
  /// 
  /// **Note**: For a mixin, this method returns all directly declared constraints applied to the mixin.
  /// 
  /// ------------------------------------------------------------------------------
  /// 
  /// ### Interface Design
  ///
  /// {@template class_get_all_declared_interfaces}
  /// Returns:
  /// - List of interfaces explicitly declared on this class
  /// - Empty list if no interfaces declared
  /// - Does NOT include inherited interfaces from superclasses
  ///
  /// #### Declared vs All Interfaces
  /// - **getDeclaredInterfaces()**: Only direct `implements` declarations
  /// - **getAllInterfaces()**: Includes inherited interfaces from hierarchy
  ///
  /// Example:
  /// ```dart
  /// interface class Readable {}
  /// interface class Writable {}
  /// class BaseStream implements Readable {}
  /// class FileStream extends BaseStream implements Writable {}
  ///
  /// final fileClass = Class.forType<FileStream>();
  /// final declared = fileClass.getAllDeclaredInterfaces();  // [Writable]
  /// final all = fileClass.getAllInterfaces();               // [Writable, Readable]
  /// ```
  /// {@endtemplate}
  /// 
  /// ------------------------------------------------------------------------------
  /// 
  /// ### Mixin Design
  /// 
  /// {@template class_get_all_declared_constraints}
  /// Returns:
  /// - List of constraints explicitly declared on this class
  /// - Empty list if no constraints declared
  /// - Does NOT include inherited constraints from superclasses
  ///
  /// #### Declared vs All constraints
  /// - **getDeclaredInterfaces()**: Only direct `implements` declarations
  /// - **getAllInterfaces()**: Includes inherited constraints from hierarchy
  ///
  /// Example:
  /// ```dart
  /// mixin class Readable {}
  /// mixin class Writable {}
  /// mixin BaseStream on Readable {}
  /// mixin FileStream on BaseStream, Writable {}
  ///
  /// final fileClass = Class.forType<FileStream>();
  /// final declared = fileClass.getAllDeclaredInterfaces();  // [Writable]
  /// final all = fileClass.getAllInterfaces();               // [Writable, Readable]
  /// ```
  /// {@endtemplate}
  List<Class> getAllDeclaredInterfaces();

  /// Gets declared interfaces of specific type (non-transitive).
  /// 
  /// **Note**: For a mixin, this method returns the declared constraints of a specific type applied to the mixin.
  ///
  /// {@template class_get_declared_interfaces}
  /// Type Parameters:
  /// - `I`: The interface type to filter for
  ///
  /// Returns:
  /// - List of matching declared interfaces
  /// - Empty list if none found
  /// - Only includes direct declarations, not inherited
  /// {@endtemplate}
  List<Class<I>> getDeclaredInterfaces<I>();

  /// Gets a specific declared interface (non-transitive).
  /// 
  /// **Note**: For a mixin, this method returns specific declared constraint applied to the mixin.
  ///
  /// {@template class_get_declared_interface}
  /// Type Parameters:
  /// - `I`: The exact interface type to retrieve
  ///
  /// Returns:
  /// - The interface if directly declared
  /// - `null` if not found or only inherited
  /// {@endtemplate}
  Class<I>? getDeclaredInterface<I>();

  /// Gets generic arguments from a specific declared interface.
  /// 
  /// **Note**: For a mixin, this method returns the generic arguments from a specific constraint applied to the mixin.
  ///
  /// {@template class_get_declared_interface_arguments}
  /// Type Parameters:
  /// - `I`: The interface type to examine
  ///
  /// Returns:
  /// - List of generic type arguments from direct declaration
  /// - Empty list if interface has no generics or is not declared
  /// {@endtemplate}
  List<Class> getDeclaredInterfaceArguments<I>();

  /// Gets generic arguments from all declared interfaces.
  /// 
  /// **Note**: For a mixin, this method returns the generic arguments from all declared constraints applied to the mixin.
  ///
  /// {@template class_get_all_declared_interface_arguments}
  /// Returns:
  /// - Flattened list of all declared interface generic arguments
  /// - Empty list if no generics exist in declared interfaces
  /// {@endtemplate}
  List<Class> getAllDeclaredInterfaceArguments();

  // ---------------------------------------------------------------------------------------------------------
  // === Mixin Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets all mixins applied to this class.
  ///
  /// {@template class_get_all_mixins}
  /// Returns:
  /// - List of all mixins (including those from superclasses)
  /// - Empty list if no mixins applied
  /// {@endtemplate}
  List<Class> getAllMixins();

  /// Gets mixins of specific type applied to this class.
  ///
  /// {@template class_get_mixins}
  /// Type Parameters:
  /// - `I`: The mixin type to filter for
  ///
  /// Returns:
  /// - List of matching mixins
  /// - Empty list if none found
  /// {@endtemplate}
  List<Class<I>> getMixins<I>();

  /// Gets a specific mixin applied to this class.
  ///
  /// {@template class_get_mixin}
  /// Type Parameters:
  /// - `I`: The exact mixin type to retrieve
  ///
  /// Returns:
  /// - The mixin if applied
  /// - `null` if not found
  /// {@endtemplate}
  Class<I>? getMixin<I>();

  /// Gets generic arguments from a specific applied mixin.
  ///
  /// {@template class_get_mixins_arguments}
  /// Type Parameters:
  /// - `M`: The mixin type to examine
  ///
  /// Returns:
  /// - List of generic type arguments
  /// - Empty list if mixin has no generics
  /// {@endtemplate}
  List<Class> getMixinsArguments<M>();

  /// Gets generic arguments from all applied mixins.
  ///
  /// {@template class_get_all_mixins_arguments}
  /// Returns:
  /// - Flattened list of all mixin generic arguments
  /// - Empty list if no generics exist
  /// {@endtemplate}
  List<Class> getAllMixinsArguments();

   /// Gets all directly declared mixins (non-transitive).
  ///
  /// {@template class_get_all_declared_mixins}
  /// Returns:
  /// - List of mixins explicitly applied to this class
  /// - Empty list if no mixins declared
  /// - Does NOT include inherited mixins from superclasses
  ///
  /// ## Declared vs All Mixins
  /// - **getDeclaredMixins()**: Only direct `with` declarations
  /// - **getAllMixins()**: Includes inherited mixins from hierarchy
  ///
  /// Example:
  /// ```dart
  /// mixin Loggable {}
  /// mixin Cacheable {}
  /// class BaseService with Loggable {}
  /// class UserService extends BaseService with Cacheable {}
  ///
  /// final userClass = Class.forType<UserService>();
  /// final declared = userClass.getAllDeclaredMixins();  // [Cacheable]
  /// final all = userClass.getAllMixins();               // [Cacheable, Loggable]
  /// ```
  /// {@endtemplate}
  List<Class> getAllDeclaredMixins();

  /// Gets generic arguments from a specific declared mixin.
  ///
  /// {@template class_get_declared_mixins_arguments}
  /// Type Parameters:
  /// - `M`: The mixin type to examine
  ///
  /// Returns:
  /// - List of generic type arguments from direct declaration
  /// - Empty list if mixin has no generics or is not declared
  /// {@endtemplate}
  List<Class> getDeclaredMixinsArguments<M>();

  /// Gets generic arguments from all declared mixins.
  ///
  /// {@template class_get_all_declared_mixins_arguments}
  /// Returns:
  /// - Flattened list of all declared mixin generic arguments
  /// - Empty list if no generics exist in declared mixins
  /// {@endtemplate}
  List<Class> getAllDeclaredMixinsArguments();

  /// Gets a specific declared mixin (non-transitive).
  ///
  /// {@template class_get_declared_mixin}
  /// Type Parameters:
  /// - `I`: The exact mixin type to retrieve
  ///
  /// Returns:
  /// - The mixin if directly applied
  /// - `null` if not found or only inherited
  /// {@endtemplate}
  Class<I>? getDeclaredMixin<I>();

  /// Gets declared mixins of specific type (non-transitive).
  ///
  /// {@template class_get_declared_mixins}
  /// Type Parameters:
  /// - `I`: The mixin type to filter for
  ///
  /// Returns:
  /// - List of matching declared mixins
  /// - Empty list if none found
  /// - Only includes direct declarations, not inherited
  /// {@endtemplate}
  List<Class<I>> getDeclaredMixins<I>();

  // ---------------------------------------------------------------------------------------------------------
  // === Annotation Information ===
  // ---------------------------------------------------------------------------------------------------------

  // Gets all annotations applied to this element.
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
  A? getAnnotation<A>();
  
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
  List<A> getAnnotations<A>();
  
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
  bool hasAnnotation<A>();

  // ---------------------------------------------------------------------------------------------------------
  // === Constructor Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets the default unnamed constructor for this class.
  ///
  /// {@template class_get_default_constructor}
  /// Returns:
  /// - The default constructor if one exists
  /// - `null` if the class has no default constructor
  ///
  /// Example:
  /// ```dart
  /// class User {
  ///   User(this.name);  // Default constructor
  ///   final String name;
  /// }
  ///
  /// final constructor = Class.forType<User>().getDefaultConstructor();
  /// print(constructor?.parameters.length); // 1
  /// ```
  /// {@endtemplate}
  Constructor? getDefaultConstructor();

  /// Gets a constructor by its declared name.
  ///
  /// {@template class_get_constructor}
  /// Parameters:
  /// - [name]: The constructor name (empty string for default constructor)
  ///
  /// Returns:
  /// - The matching constructor if found
  /// - `null` if no matching constructor exists
  ///
  /// Example:
  /// ```dart
  /// class Point {
  ///   Point.origin() : x = 0, y = 0;
  /// }
  ///
  /// final constructor = Class.forType<Point>().getConstructor('origin');
  /// ```
  /// 
  /// For factory constructors, include the 'factory' prefix:
  /// ```dart
  /// getConstructor('factory fromJson');
  /// ```
  /// {@endtemplate}
  Constructor? getConstructor(String name);

  /// Gets a constructor by its parameter types.
  ///
  /// {@template class_get_constructor_by_signature}
  /// Parameters:
  /// - [paramTypes]: List of parameter types in exact order
  ///
  /// Returns:
  /// - The exact constructor match if found
  /// - `null` if no matching signature exists
  ///
  /// Example:
  /// ```dart
  /// class Converter {
  ///   String convert(int value) => value.toString();
  ///   String convert(double value) => value.toString();
  /// }
  ///
  /// final constructor = Class.forType<Converter>()
  ///   .getConstructorBySignature([Class.forType<int>()]);
  /// ```
  /// {@endtemplate}
  Constructor? getConstructorBySignature(List<Class> paramTypes);

  /// Gets the best constructor for the given parameter types.
  ///
  /// {@template class_get_best_constructor}
  /// Parameters:
  /// - [paramTypes]: List of parameter types in exact order
  ///
  /// Returns:
  /// - The best constructor match if found
  /// - `null` if no matching signature exists
  ///
  /// Example:
  /// ```dart
  /// class Converter {
  ///   String convert(int value) => value.toString();
  ///   String convert(double value) => value.toString();
  /// }
  ///
  /// final constructor = Class.forType<Converter>()
  ///   .getBestConstructor([Class.forType<int>()]);
  /// ```
  /// {@endtemplate}
  Constructor? getBestConstructor(List<Class> paramTypes);

  /// {@template get_no_arg_constructor}
  /// Retrieves the no-argument constructor of this [Constructor] instance, if available.
  ///
  /// By default, only constructors with **no parameters** are considered.
  /// However, if [acceptWhenAllParametersAreOptional] is set to `true`, then
  /// constructors whose parameters are *all optional* will also be accepted.
  ///
  /// ### Parameters
  /// - [acceptWhenAllParametersAreOptional] (default: `false`)  
  ///   If `true`, constructors where all parameters are optional will be returned
  ///   even if they are not strictly "no-arg".
  ///
  /// ### Returns
  /// - A [Constructor] representing the no-arg constructor if one exists.
  /// - Otherwise, `null`.
  ///
  /// ### Example
  /// ```dart
  /// final clazz = Class<MyService>();
  /// final ctor = clazz.getConstructors()
  ///     .getNoArgConstructor(true);
  ///
  /// if (ctor != null) {
  ///   final instance = ctor.newInstance();
  ///   print("Created instance: $instance");
  /// } else {
  ///   print("No suitable constructor found.");
  /// }
  /// ```
  /// {@endtemplate}
  Constructor? getNoArgConstructor([bool acceptWhenAllParametersAreOptional = false]);

  /// Gets all constructors declared in this class.
  ///
  /// {@template class_get_constructors}
  /// Returns:
  /// - List of all constructors (both generative and factory)
  /// - Empty list if no constructors exist
  ///
  /// Example:
  /// ```dart
  /// final ctors = Class.forType<MyClass>().getConstructors();
  /// ctors.forEach((c) => print(c.name));
  /// ```
  /// 
  /// Includes:
  /// - Default unnamed constructor
  /// - Named constructors
  /// - Factory constructors
  /// {@endtemplate}
  List<Constructor> getConstructors();

  // ---------------------------------------------------------------------------------------------------------
  // === Method Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets a method by its name.
  ///
  /// {@template class_get_method}
  /// Parameters:
  /// - [name]: The method name to look up
  ///
  /// Returns:
  /// - The first matching method found
  /// - `null` if no method with this name exists
  ///
  /// Example:
  /// ```dart
  /// class Calculator {
  ///   int add(int a, int b) => a + b;
  /// }
  ///
  /// final method = Class.forType<Calculator>().getMethod('add');
  /// print(method?.returnType.getName()); // 'int'
  /// ```
  /// 
  /// Note:
  /// - Does not consider inheritance hierarchy
  /// - For overloaded methods, use [getMethodBySignature]
  /// {@endtemplate}
  Method? getMethod(String name);

  /// Gets a method by its name and parameter types.
  ///
  /// {@template class_get_method_by_signature}
  /// Parameters:
  /// - [name]: The method name
  /// - [parameterTypes]: List of parameter types in exact order
  ///
  /// Returns:
  /// - The exact method match if found
  /// - `null` if no matching signature exists
  ///
  /// Example:
  /// ```dart
  /// class Converter {
  ///   String convert(int value) => value.toString();
  ///   String convert(double value) => value.toString();
  /// }
  ///
  /// final method = Class.forType<Converter>()
  ///   .getMethodBySignature('convert', [Class.forType<int>()]);
  /// ```
  /// {@endtemplate}
  Method? getMethodBySignature(String name, List<Class> parameterTypes);

  /// Gets all methods declared in this class.
  ///
  /// {@template class_get_methods}
  /// Returns:
  /// - List of all methods (instance and static)
  /// - Empty list if no methods exist
  ///
  /// Example:
  /// ```dart
  /// final methods = Class.forType<MyService>().getMethods();
  /// methods.forEach((m) => print(m.name));
  /// ```
  /// 
  /// Includes:
  /// - Instance methods
  /// - Static methods
  /// - Operator overloads
  /// - Getters/setters
  /// 
  /// Excludes:
  /// - Inherited methods (use [getMethods] for hierarchy traversal)
  /// {@endtemplate}
  List<Method> getMethods();

  /// Gets all methods declared in this class and its hierarchy.
  ///
  /// {@template class_get_all_methods_in_hierarchy}
  /// Returns:
  /// - List of all methods (instance and static)
  /// - Empty list if no methods exist
  ///
  /// Example:
  /// ```dart
  /// final methods = Class.forType<MyService>().getAllMethodsInHierarchy();
  /// methods.forEach((m) => print(m.name));
  /// ```
  /// 
  /// Includes:
  /// - Instance methods
  /// - Static methods
  /// - Operator overloads
  /// - Getters/setters
  /// 
  /// Excludes:
  /// - Inherited methods (use [getMethods] for hierarchy traversal)
  /// {@endtemplate}
  List<Method> getAllMethodsInHierarchy();

  /// Gets all methods that are overridden in this class.
  ///
  /// {@template class_get_overridden_methods}
  /// Returns:
  /// - List of all methods that are overridden in this class
  /// - Empty list if no methods are overridden
  ///
  /// Example:
  /// ```dart
  /// final overriddenMethods = Class.forType<MyService>().getOverriddenMethods();
  /// overriddenMethods.forEach((m) => print(m.name));
  /// ```
  /// {@endtemplate}
  List<Method> getOverriddenMethods();

  /// Gets all methods with a specific name.
  ///
  /// {@template class_get_methods_by_name}
  /// Parameters:
  /// - [name]: The method name to filter by
  ///
  /// Returns:
  /// - List of all overloads with this name
  /// - Empty list if no matches found
  ///
  /// Example:
  /// ```dart
  /// class Overloader {
  ///   void test(int a) {}
  ///   void test(String s) {}
  /// }
  ///
  /// final overloads = Class.forType<Overloader>().getMethodsByName('test');
  /// print(overloads.length); // 2
  /// ```
  /// {@endtemplate}
  List<Method> getMethodsByName(String name);

  /// Gets all enum values as [Field] if this is an enum class.
  ///
  /// {@template class_get_enum_values}
  /// Returns:
  /// - List of enum fields with metadata
  /// - Empty list for non-enum types
  ///
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// final values = Class.forType<Status>().getEnumValuesAsFields();
  /// print(values.map((e) => e.name)); // ['active', 'inactive']
  /// ```
  /// {@endtemplate}
  List<Field> getEnumValuesAsFields();

  /// Gets all enum values if this is an enum class.
  ///
  /// {@template class_get_enum_values}
  /// Returns:
  /// - List of enum fields with metadata
  /// - Empty list for non-enum types
  ///
  /// Example:
  /// ```dart
  /// enum Status { active, inactive }
  /// final values = Class.forType<Status>().getEnumValuesAsFields();
  /// print(values.map((e) => e.name)); // ['active', 'inactive']
  /// ```
  /// {@endtemplate}
  List<EnumValue> getEnumValues();

  // ---------------------------------------------------------------------------------------------------------
  // === Member Information ===
  // ---------------------------------------------------------------------------------------------------------

  /// Gets all members (fields, methods, constructors) declared in this class.
  ///
  /// {@template class_get_declared_members}
  /// Returns:
  /// - Combined list of all class members
  /// - Empty list if no members exist
  ///
  /// Example:
  /// ```dart
  /// final members = Class.forType<MyClass>().getDeclaredMembers();
  /// members.forEach((m) {
  ///   if (m is Field) print('Field: ${m.name}');
  ///   if (m is Method) print('Method: ${m.name}');
  /// });
  /// ```
  /// 
  /// Ordering:
  /// - Fields appear before methods
  /// - Declaration order is not guaranteed
  /// {@endtemplate}
  List<Member> getDeclaredMembers();

  // ---------------------------------------------------------------------------------------------------------
  // === Instance Creation ===
  // ---------------------------------------------------------------------------------------------------------

  /// Creates an instance using the default constructor.
  ///
  /// {@template class_new_instance}
  /// Parameters:
  /// - [constructorName]: The constructor name
  /// - [arguments]: Optional named arguments for construction
  ///
  /// Returns:
  /// - A new instance of type T
  ///
  /// Throws:
  /// - [ConstructorNotFoundException] if no default constructor exists
  /// - [UnresolvedTypeInstantiationException] if the type is unresolved. Normally represented with `_ClassMirror`.
  /// - [PrivateConstructorInvocationException] if the constructor being invoked is a private constructor
  /// - [InvalidArgumentException] for invalid arguments
  /// - [GenericResolutionException] if the type cannot be resolved by Jetleaf
  ///
  /// Example:
  /// ```dart
  /// final user = userClass.newInstance({'name': 'Alice'}, 'origin');
  /// ```
  /// {@endtemplate}
  T newInstance([Map<String, dynamic>? arguments, String? constructorName]);

  // ---------------------------------------------------------------------------------------------------------
  // === Factory ===
  // ---------------------------------------------------------------------------------------------------------

  /// {@macro class}
  factory Class([ProtectionDomain? domain, String? package, LinkDeclaration? link]) {
    return _Class(T.toString(), domain ?? ProtectionDomain.current(), package, link);
  }

  /// Creates a Class instance for type F.
  ///
  /// {@template class_of}
  /// Type Parameters:
  /// - `F`: The class type to reflect
  ///
  /// Parameters:
  /// - [domain]: Optional protection domain
  /// - [package]: Optional package name to search with
  ///
  /// Returns:
  /// - A [Class] instance for the type
  /// {@endtemplate}
  static Class<F> of<F>([ProtectionDomain? domain, String? package, LinkDeclaration? link]) => Class<F>(domain, package, link);

  /// Creates a Class instance for a runtime type.
  ///
  /// {@template class_for_type}
  /// Type Parameters:
  /// - `Type`: The class type to reflect
  ///
  /// Parameters:
  /// - [domain]: Optional protection domain
  /// - [package]: Optional package name to search with
  ///
  /// Returns:
  /// - A [Class] instance for the type
  ///
  /// Example:
  /// ```dart
  /// final listClass = Class.forType(List<String>);
  /// ```
  /// {@endtemplate}
  static Class<C> forType<C>(C type, [ProtectionDomain? domain, String? package, LinkDeclaration? link]) {
    return _Class<C>(type.toString(), domain ?? ProtectionDomain.current(), package, link);
  }

  /// Creates a Class instance for a runtime type name.
  ///
  /// {@template class_for_name}
  /// Type Parameters:
  /// - `C`: The class type to reflect
  ///
  /// Parameters:
  /// - [name]: The class name to reflect
  /// - [domain]: Optional protection domain
  /// - [package]: Optional package name to search with
  ///
  /// Returns:
  /// - A [Class] instance for the named type
  /// {@endtemplate}
  static Class<C> forName<C>(String name, [ProtectionDomain? domain, String? package, LinkDeclaration? link]) {
    return _Class<C>(name, domain ?? ProtectionDomain.current(), package, link);
  }

  /// Creates a Class instance from type declaration metadata.
  /// 
  /// {@template class_declared}
  /// Parameters:
  /// - [declaration]: The type metadata declaration
  /// - [domain]: Protection domain for security
  ///
  /// Returns:
  /// - A new Class instance with resolved metadata
  ///
  /// Used internally by the reflection system.
  /// {@endtemplate}
  static Class<C> declared<C>(ClassDeclaration declaration, ProtectionDomain domain) {
    return _Class<C>.declared(declaration, domain);
  }

  /// Creates a Class instance from a fully qualified name.
  ///
  /// {@template class_from_qualified_name}
  /// Parameters:
  /// - [qualifiedName]: The complete type path (e.g., "dart:core/string.dart.String")
  /// - [domain]: Optional protection domain
  ///
  /// Returns:
  /// - A Class instance for the named type
  ///
  /// Throws:
  /// - [ClassNotFoundException] if type cannot be resolved
  /// {@endtemplate}
  static Class<C> fromQualifiedName<C>(String qualifiedName, [ProtectionDomain? domain, LinkDeclaration? link]) {
    return _Class<C>.fromQualifiedName(qualifiedName, domain ?? ProtectionDomain.current(), link);
  }

  /// Creates a Class instance for an object's runtime type.
  ///
  /// {@template class_for_object}
  /// Parameters:
  /// - [obj]: The object to reflect
  /// - [domain]: Optional protection domain
  /// - [package]: Optional package name to search with
  ///
  /// Returns:
  /// - A [Class] instance for the object's type
  /// {@endtemplate}
  static Class<Object> forObject(Object obj, [ProtectionDomain? domain, String? package, LinkDeclaration? link]) {
    return LangUtils.obtainClass(obj, package: package, pd: domain, link: link);
  }
}

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
/// final constructors = myObject.getClass().getConstructors();
/// ```
/// {@endtemplate}
/// {@endtemplate}
extension ClassExtension on Object {
  /// Gets the [Class] metadata for this object's runtime type.
  /// 
  /// Parameters:
  /// - [domain]: Optional protection domain
  /// - [package]: Optional package name to search with
  ///
  /// Returns:
  /// - A [Class<Object>] instance representing the object's type
  /// - Uses the current protection domain for security
  ///
  /// Equivalent to:
  /// ```dart
  /// Class.forType<Object>(runtimeType, ProtectionDomain.current())
  /// ```
  Class getClass([ProtectionDomain? domain, String? package]) => LangUtils.obtainClass(this, pd: domain, package: package);
}