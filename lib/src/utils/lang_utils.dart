import 'package:dart_internal/extract_type_arguments.dart';
import 'package:jetleaf_build/jetleaf_build.dart';

import '../extensions/primitives/string.dart';
import '../exceptions.dart';
import '../meta/class/class.dart';
import '../meta/class/class_type.dart';
import '../meta/function/function_class.dart';
import '../meta/protection_domain/protection_domain.dart';
import '../meta/record/record_class.dart';

/// {@template lang_utils}
/// Utility class providing **type resolution helpers** for JetLeaf meta-APIs.
///
/// `LangUtils` focuses on obtaining JetLeaf [Class] representations for:
/// - Runtime objects (`obtainClass`)  
/// - Link-time declarations (`obtainClassFromLink`)  
///
/// This allows JetLeaf to provide full meta-models for **functions**, **records**, 
/// generic collections, maps, and normal Dart classes, unifying link-time and runtime
/// type information.
///
/// The utilities handle:
/// - Functions → converted to [FunctionClass]  
/// - Records → converted to [RecordClass]  
/// - Collections → generic type arguments extracted  
/// - Maps → key/value type arguments extracted  
/// - Dynamic / void types → mapped to JetLeaf singletons  
/// - Fallback resolution using qualified names or runtime `Type` objects
/// {@endtemplate}
abstract final class LangUtils {
  /// {@macro lang_utils}
  LangUtils._();

  /// Resolves the [Class] representation of a runtime [object].
  ///
  /// This method inspects the object and determines the appropriate JetLeaf
  /// [Class] instance, handling a wide range of cases:
  ///
  /// ### Behavior
  /// 1. **Functions** → returns a [FunctionClass] representing the function signature.  
  /// 2. **Records** → returns a [RecordClass] representing the record shape.  
  /// 3. **Collections** (`List`, `Set`, `Iterable`) → extracts generic type arguments.  
  /// 4. **Maps** → extracts key and value type arguments.  
  /// 5. **Dynamic / Void / Other types** → uses qualified names or runtime type for resolution.  
  ///
  /// ### Parameters
  /// - [object]: The runtime object to resolve.  
  /// - [pd]: Optional [ProtectionDomain] to enforce access or security rules.  
  /// - [package]: Optional package name hint for resolution.  
  /// - [link]: Optional [LinkDeclaration] if the object originates from a link-time declaration.  
  ///
  /// ### Returns
  /// A fully resolved [Class<Object>] representing the object's type in JetLeaf.
  ///
  /// ### Example
  /// ```dart
  /// final list = [1, 2, 3];
  /// final clazz = LangUtils.obtainClass(list);
  /// print(clazz.getName()); // → "List<int>"
  /// ```
  static Class<Object> obtainClass(Object object, {ProtectionDomain? pd, String? package, LinkDeclaration? link}) {
    final Object self = object;

    if (ReflectionUtils.isThisAFunction(self)) {
      //
    }

    if (ReflectionUtils.isThisARecord(self)) {
      //
    }

    try {
      if (self is Iterable<Object?>) {
        Class<Object?> Function<E>() f = switch (self) {
          List<Object?>() => <E>() => Class<List<E>>(null, null),
          Set<Object?>() => <E>() => Class<Set<E>>(null, null),
          _ => <E>() => Class<Iterable<E>>(null, null),
        };
        return extractIterableTypeArgument(self, f) as Class<Object>;
      }

      if (self is Iterable) {
        Class Function<E>() f = switch (self) {
          List() => <E>() => Class<List<E>>(null, null),
          Set() => <E>() => Class<Set<E>>(null, null),
          _ => <E>() => Class<Iterable<E>>(null, null),
        };
        return extractIterableTypeArgument(self, f) as Class<Object>;
      }

      if (self is Map<Object?, Object?>) {
        Class<Object?> Function<E, F>() f = switch (self) {
          Map<Object?, Object?>() => <E, F>() => Class<Map<E, F>>(null, null),
        };
        return extractMapTypeArguments(self, f) as Class<Object>;
      }

      if (self is Map) {
        Class Function<E, F>() f = switch (self) {
          Map() => <E, F>() => Class<Map<E, F>>(null, null),
        };
        return extractMapTypeArguments(self, f) as Class<Object>;
      }
      
      if(self.runtimeType.toString().notEqualsIgnoreCase("type") || self.runtimeType.toString().notEqualsIgnoreCase("dynamic")) {
        return Class.fromQualifiedName(ReflectionUtils.findQualifiedNameFromType(self.runtimeType), pd ?? ProtectionDomain.system(), link);
      }

      return Class.fromQualifiedName(ReflectionUtils.findQualifiedName(self), pd ?? ProtectionDomain.system(), link);
    } on ClassNotFoundException catch (_) {
      if(self.runtimeType.toString().notEqualsIgnoreCase("type")) {
        return Class.forName<Object>(self.runtimeType.toString(), pd ?? ProtectionDomain.current(), package, link);
      }

      return Class.forName<Object>(self.toString(), pd ?? ProtectionDomain.current(), package, link);
    }
  }

  /// Resolves a [Class] instance from a [LinkDeclaration].
  ///
  /// {@template class_from_link}
  /// This utility converts a build-time [LinkDeclaration] into a runtime
  /// [Class] object, handling Dart function types, dynamic types, void types,
  /// unresolved types, and fallback cases.
  ///
  /// The resolution process prioritizes:
  /// 1. **Function declarations**  
  ///    For [FunctionLinkDeclaration], the method resolves the **return type**
  ///    instead of treating the function itself as the class.
  ///
  /// 2. **Dynamic and void shortcuts**  
  ///    If the declaration represents `dynamic` or `void`, the corresponding
  ///    singleton ([DYNAMIC_CLASS] or [VOID_CLASS]) is returned immediately.
  ///
  /// 3. **Pointer-based type resolution**  
  ///    The system first attempts to resolve using the pointer type’s `Type`
  ///    object. If unavailable, it falls back to resolution by qualified name.
  ///
  /// 4. **Graceful degradation**  
  ///    If type resolution fails, the method falls back to:
  ///    - returning predefined dynamic/void classes,
  ///    - or resolving using the declaration's raw Dart `Type`.
  ///
  /// ## Parameters
  /// - `declaration`: The link-time declaration describing the type.
  /// - `[pd]`: Optional [ProtectionDomain] to enforce security constraints
  ///   during reflective resolution.
  ///
  /// ## Returns
  /// A fully resolved [Class] instance representing the declaration's type.
  ///
  /// ## Behavior Summary
  /// - Function declaration → resolve return type  
  /// - `dynamic` → [DYNAMIC_CLASS]  
  /// - `void` → [VOID_CLASS]  
  /// - Fallback: `Class.fromQualifiedName`  
  /// - Final fallback on failure: `Class.forType(declaration.getType())`
  ///
  /// ## Example
  /// ```dart
  /// final link = parameter.getLinkDeclaration();
  /// final clazz = Class.getClassFromLink(link);
  ///
  /// print(clazz.getName());      // e.g., "String"
  /// print(clazz.getQualifiedName()); // e.g., "dart:core.String"
  /// ```
  ///
  /// ## Notes
  /// - This method is used extensively in reflection, parameter resolution,
  ///   annotation analysis, and invocation metadata.
  /// - It ensures that different forms of type declarations (pointer types,
  ///   qualified names, raw `Type` objects) resolve consistently.
  /// - It intentionally aligns dynamic and void resolution across both the
  ///   link-time and runtime reflection layers.
  /// {@endtemplate}
  static Class<Object> obtainClassFromLink(LinkDeclaration declaration, [ProtectionDomain? pd]) {
    try {
      if (declaration is FunctionLinkDeclaration) {
        return FunctionClass.linked(declaration, pd);
      }

      if (declaration is RecordLinkDeclaration) {
        return RecordClass.linked(declaration, pd);
      }

      if (declaration.getType() == Dynamic || declaration.getPointerQualifiedName() == Dynamic.getQualifiedName()) {
        return DYNAMIC_CLASS;
      }

      if (declaration.getType() == dynamic || declaration.getPointerQualifiedName() == Dynamic.getQualifiedName()) {
        return DYNAMIC_CLASS;
      }

      if (declaration.getType() == Void || declaration.getPointerQualifiedName() == Void.getQualifiedName()) {
        return VOID_CLASS;
      }

      return Class.fromQualifiedName(declaration.getPointerQualifiedName(), pd, declaration);
    } on ClassNotFoundException catch (e) {
      if (e.className == "dart:core.Object") {
        return VOID_CLASS;
      }

      if (e.className == "dart:core.dynamic") {
        return DYNAMIC_CLASS;
      }

      return Class.forType(declaration.getType(), pd, null, declaration);
    }
  }
}