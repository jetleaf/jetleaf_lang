import 'dart:mirrors' as mirrors;

/// {@template reflection_utils}
/// Lightweight runtime reflection utility built on top of `dart:mirrors`.
///
/// This class provides convenience methods for inspecting runtime types
/// and instances to determine their *qualified names*, i.e. the fully
/// resolved identity of a symbol within its library or package context.
///
/// Qualified names are formatted as:
///
/// ```
/// package:my_app/models/user.dart.User
/// dart:core.String
/// ```
///
/// This utility is used internally within Jetleaf for tasks like
/// class resolution, dependency registration, and annotation scanning.
///
/// > **Note:** Reflection via `dart:mirrors` may not be supported in all
/// runtime environments (e.g. Flutter AOT). This utility is primarily
/// intended for development or server-side usage.
/// {@endtemplate}
final class ReflectionUtils {
  /// Private constructor to prevent instantiation.
  const ReflectionUtils._();

  // ─────────────────────────────────────────────────────────────
  // Instance Reflection
  // ─────────────────────────────────────────────────────────────

  /// {@template reflection_utils.find_qualified_name}
  /// Returns the **qualified name** of an object instance.
  ///
  /// This method inspects the runtime type of the given [instance]
  /// and constructs a fully-qualified symbol reference including
  /// its originating library URI.
  ///
  /// ### Example
  /// ```dart
  /// final user = User();
  /// print(ReflectionUtils.findQualifiedName(user));
  /// // → "package:my_app/models/user.dart.User"
  /// ```
  ///
  /// ### Returns
  /// A string containing the qualified name, e.g.
  /// `dart:core.String` or `package:jetleaf_core/src/log/log_property.dart.LogProperty`.
  ///
  /// ### Notes
  /// - If the source URI cannot be resolved, `"unknown"` is used as a fallback.
  /// {@endtemplate}
  static String findQualifiedName(Object instance) {
    final mirror = mirrors.reflect(instance);
    final classMirror = mirror.type;

    final className = mirrors.MirrorSystem.getName(classMirror.simpleName);

    // Library URI is taken from owner or type location
    final libraryUri = classMirror.owner?.location?.sourceUri.toString() ??
        (classMirror.location?.sourceUri.toString() ?? 'unknown');

    return buildQualifiedName(className, libraryUri);
  }

  // ─────────────────────────────────────────────────────────────
  // Type Reflection
  // ─────────────────────────────────────────────────────────────

  /// {@template reflection_utils.find_qualified_name_from_type}
  /// Returns the **qualified name** of a static [Type].
  ///
  /// Unlike [findQualifiedName], this method operates directly on
  /// the type object itself, not an instance.
  ///
  /// ### Example
  /// ```dart
  /// print(ReflectionUtils.findQualifiedNameFromType(String));
  /// // → "dart:core.String"
  /// ```
  ///
  /// ### Returns
  /// A string representing the type’s fully qualified symbol.
  ///
  /// ### Notes
  /// - Falls back to `"unknown"` if the library URI is not available.
  /// {@endtemplate}
  static String findQualifiedNameFromType(Type type) {
    final typeMirror = mirrors.reflectType(type);
    final typeName = mirrors.MirrorSystem.getName(typeMirror.simpleName);
    final libraryUri = typeMirror.location?.sourceUri.toString() ?? 'unknown';

    return buildQualifiedName(typeName, libraryUri);
  }

  // ─────────────────────────────────────────────────────────────
  // Internal Utilities
  // ─────────────────────────────────────────────────────────────

  /// {@template reflection_utils.build_qualified_name}
  /// Builds a fully qualified name from a type [name] and its
  /// associated [libraryUri].
  ///
  /// This is a small helper used internally by both
  /// [findQualifiedName] and [findQualifiedNameFromType].
  ///
  /// Example:
  /// ```dart
  /// ReflectionUtils.buildQualifiedName('User', 'package:my_app/models/user.dart');
  /// // → "package:my_app/models/user.dart.User"
  /// ```
  /// {@endtemplate}
  static String buildQualifiedName(String typeName, String libraryUri) {
    // Ensures there’s only one dot between segments
    return '$libraryUri.$typeName'.replaceAll('..', '.');
  }
}