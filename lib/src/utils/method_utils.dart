import 'package:jetleaf_build/jetleaf_build.dart';

import '../meta/method/method.dart';
import '../meta/protection_domain/protection_domain.dart';

/// A cached list of all method declarations visible to the JetLeaf [Runtime].
/// 
/// This list is populated once upon the first invocation of any
/// [MethodUtils] static method, ensuring that subsequent reflective operations
/// do not incur the overhead of repeated scans.
List<MethodDeclaration> _methodDeclarations = [];

/// {@template jet_method_utils}
/// Provides reflective utility functions for working with JetLeaf runtime
/// [Method] and [MethodDeclaration] instances.
///
/// This class centralizes common operations such as collecting annotated
/// methods and deduplicating them by identity, helping JetLeaf subsystems
/// like lifecycle management, annotation scanning, and component discovery
/// operate efficiently.
///
/// The static methods of [MethodUtils] are designed to be called by JetLeaf’s
/// internal processors, such as the `LifecycleRunListener`, without requiring
/// direct instantiation.
///
/// ### Example
/// ```dart
/// final annotatedMethods = <Method>{};
/// MethodUtils.collectMethods<OnApplicationReady>(annotatedMethods);
///
/// for (final method in annotatedMethods) {
///   print('Discovered lifecycle method: ${method.getName()}');
/// }
/// ```
///
/// The above example demonstrates scanning for all runtime methods annotated
/// with `@OnApplicationReady` and collecting them into a set for later
/// invocation by JetLeaf’s event system.
///
/// ### See also
/// - [Method]
/// - [ReflectableAnnotation]
/// - [Runtime]
/// - [ProtectionDomain]
/// {@endtemplate}
final class MethodUtils {
  /// {@template jet_method_utils_private_constructor}
  /// Initializes the [MethodUtils] utility by ensuring the global
  /// `_methodDeclarations` list is populated with all methods visible to
  /// the JetLeaf [Runtime].
  ///
  /// This constructor is private because the class exposes only static
  /// utilities; instantiation is not intended for external use.
  ///
  /// When first invoked, it calls `Runtime.getAllMethods()` and caches
  /// the resulting method declarations globally to avoid redundant
  /// reflection scans across JetLeaf components.
  ///
  /// ### Example
  /// ```dart
  /// // Not meant to be called directly; triggered implicitly when methods are collected.
  /// final _ = MethodUtils._();
  /// ```
  /// {@endtemplate}
  MethodUtils._() {
    _ensureInitialized();
  }

  /// {@template jet_method_utils_ensure_initialized}
  /// Ensures that the global cache of [MethodDeclaration] instances used by
  /// JetLeaf reflection utilities has been initialized.
  ///
  /// This internal safeguard checks whether the private
  /// [_methodDeclarations] list is empty and, if so, populates it by invoking
  /// [Runtime.getAllMethods()]. This guarantees that subsequent reflective
  /// operations—such as lifecycle annotation scanning or component discovery—
  /// operate on a consistent and preloaded snapshot of the JetLeaf runtime.
  ///
  /// By isolating initialization logic in this method, JetLeaf avoids
  /// redundant reflection scans across multiple utility calls (e.g.,
  /// [collectMethods]) while still ensuring thread-safe and lazy loading of
  /// method metadata.
  ///
  /// ### Example
  /// ```dart
  /// void main() {
  ///   MethodUtils._ensureInitialized();
  ///   final methods = Runtime.getAllMethods();
  ///   print('JetLeaf runtime method count: ${methods.length}');
  /// }
  /// ```
  ///
  /// In this example, `_ensureInitialized()` guarantees that all runtime
  /// method declarations are cached before any reflective introspection is
  /// performed.
  ///
  /// ### See also
  /// - [Runtime.getAllMethods]
  /// - [_methodDeclarations]
  /// - [collectMethods]
  /// {@endtemplate}
  static void _ensureInitialized() {
    if (_methodDeclarations.isEmpty) {
      _methodDeclarations = Runtime.getAllMethods();
    }
  }

  /// {@template jet_method_utils_collect_methods}
  /// Collects all methods annotated with a given JetLeaf annotation type `T`
  /// and adds them to the provided [target] set after deduplication.
  ///
  /// This method performs a single reflective pass over the globally cached
  /// list of [_methodDeclarations] and filters out methods that contain an
  /// annotation of type `T` (which must extend [ReflectableAnnotation]).
  ///
  /// Each matching declaration is wrapped into a JetLeaf [Method] using
  /// [Method.declared], and the resulting list is passed to
  /// [_deduplicateByIdentity] to ensure only unique methods—based on their
  /// declaring class and name—are retained.
  ///
  /// ### Type Parameter
  /// - `T` — The annotation type extending [ReflectableAnnotation] to match.
  ///
  /// ### Parameters
  /// - [target] — The set into which the collected [Method]s are added.
  ///
  /// ### Example
  /// ```dart
  /// final startupMethods = <Method>{};
  /// MethodUtils.collectMethods<OnApplicationStarted>(startupMethods);
  /// ```
  ///
  /// In this example, all methods annotated with `@OnApplicationStarted`
  /// are identified, wrapped, and stored in [startupMethods] for later
  /// invocation when the JetLeaf runtime signals that phase.
  ///
  /// ### See also
  /// - [_deduplicateByIdentity]
  /// - [ReflectableAnnotation]
  /// - [ProtectionDomain]
  /// {@endtemplate}
  static void collectMethods<T extends ReflectableAnnotation>(Set<Method> target) {
    _ensureInitialized();

    final methods = _methodDeclarations
        .where((m) => m.getAnnotations().any((a) => a.getType() == T))
        .map((m) => Method.declared(m, ProtectionDomain.current()))
        .toList();

    target.addAll(_deduplicateByIdentity(methods));
  }

  /// {@template jet_method_utils_deduplicate_by_identity}
  /// Removes duplicate [Method] entries from the given iterable by comparing
  /// each method’s declaring class and method name combination.
  ///
  /// This deduplication step is critical in JetLeaf environments where
  /// reflective method discovery may include inherited or re-declared
  /// methods from multiple layers of the class hierarchy.
  ///
  /// Each unique method is identified by the key:
  /// ```
  /// ${method.getDeclaringClass().getQualifiedName()}#${method.getName()}
  /// ```
  ///
  /// Any method whose reflective access fails (for instance, if its declaring
  /// class cannot be resolved) is silently skipped for stability.
  ///
  /// ### Parameters
  /// - [methods] — The iterable of [Method] instances to deduplicate.
  ///
  /// ### Returns
  /// A new iterable containing only unique [Method]s.
  ///
  /// ### Example
  /// ```dart
  /// final uniqueMethods = MethodUtils._deduplicateByIdentity(allMethods);
  /// print('Found ${uniqueMethods.length} unique JetLeaf methods.');
  /// ```
  ///
  /// ### See also
  /// - [collectMethods]
  /// {@endtemplate}
  static Iterable<Method> _deduplicateByIdentity(Iterable<Method> methods) {
    final seen = <String>{};
    final result = <Method>[];

    for (final method in methods) {
      try {
        final identity = "${method.getDeclaringClass().getQualifiedName()}#${method.getName()}";
        if (seen.add(identity)) {
          result.add(method);
        }
      } catch (_) {
        continue;
      }
    }

    return result;
  }

  /// Returns a list of method names that are considered *default* or
  /// *framework-intrinsic* and should typically be ignored when scanning
  /// for repository operations.
  ///
  /// These methods originate from `Object` or the Dart runtime and are not
  /// user-defined behaviors relevant to repository processing.
  ///
  /// ### Returned method names:
  /// - `"=="` – Equality operator
  /// - `"hashCode"` – Hash code getter
  /// - `"toString"` – String representation
  /// - `"noSuchMethod"` – Fallback for missing invocations
  /// - `"runtimeType"` – Reflective access to the object's type
  ///
  /// ### Use Cases
  /// - Filtering out non-repository methods when building repository
  ///   definitions.
  /// - Avoiding accidental interception of built-in Dart object methods.
  ///
  /// ### Example
  /// ```dart
  /// final ignored = getDefaultMethodNames();
  /// if (!ignored.contains(method.name)) {
  ///   processRepositoryMethod(method);
  /// }
  /// ```
  static List<String> getDefaultMethodNames() => [
    "==",
    "hashCode",
    "toString",
    "noSuchMethod",
    "runtimeType",
  ];
}