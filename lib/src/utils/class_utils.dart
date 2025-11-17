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

// ignore_for_file: unused_field

import 'dart:async';

import 'package:jetleaf_build/jetleaf_build.dart';

import '../extensions/primitives/string.dart';
import '../collections/hash_set.dart';
import '../commons/optional.dart';
import '../extensions/primitives/map.dart';
import '../math/big_integer.dart';
import '../meta/class/class_gettable.dart';
import '../meta/class/class_type.dart';
import '../meta/protection_domain/protection_domain.dart';
import '../primitives/boolean.dart';
import '../primitives/character.dart';
import '../primitives/double.dart';
import '../primitives/float.dart';
import '../primitives/integer.dart';
import '../meta/method/method.dart';
import '../meta/class/class.dart';

bool _initialized = false;

// ========================================================================
// Constants and Static Fields
// ========================================================================

/// Map with primitive wrapper type as key and corresponding primitive
/// type as value, for example: `Class<Integer>() -> Class<int>()`.
final Map<Class, Class> _primitiveWrapperTypeMap = {};

/// Map with primitive type as key and corresponding wrapper
/// type as value, for example: `Class<int>() -> Class<Integer>()`.
final Map<Class, Class> _primitiveTypeToWrapperMap = {};

/// Map with primitive type name as key and corresponding primitive
/// type as value, for example: `'int' -> Class<int>()`.
final Map<String, Class> _primitiveTypeNameMap = {};

/// Map with common Dart language class name as key and corresponding Class as value.
/// Primarily for efficient deserialization of remote invocations.
final Map<String, Class> _commonClassCache = {};

/// Cachec for class hierarchies within a class.
/// 
/// A `null` value signals that no class hierarchy was found for the key.
final Map<Class, List<Class>> _classHierarchy = {};

/// Cache for class declarations within the JetLeaf framework.
/// 
/// This list is populated with all class declarations discovered during
/// the initial reflection scan, ensuring efficient access to class metadata
/// throughout the framework.
List<ClassDeclaration> _classDeclarations = [];

/// {@template class_utils}
/// A utility class that provides static methods for working with class hierarchies
/// and type relationships in Dart's reflection system.
/// 
/// This class offers functionality to traverse and analyze class inheritance
/// structures, including superclasses, interfaces, and special handling for
/// arrays and enums.
/// 
/// ## Usage
/// 
/// ```dart
/// // Get the complete class hierarchy for a type
/// final hierarchy = ClassUtils.getClassHierarchy(Class.of<String>());
/// 
/// // The hierarchy will include:
/// // - The original class (String)
/// // - All superclasses up to Object
/// // - All implemented interfaces
/// // - Special handling for arrays and enums
/// 
/// print('Class hierarchy for String:');
/// for (final clazz in hierarchy) {
///   print('  ${clazz.getName()}');
/// }
/// ```
/// 
/// ## Features
/// 
/// - **Complete hierarchy traversal**: Walks up the entire inheritance chain
/// - **Interface inclusion**: Includes all implemented interfaces at each level
/// - **Array support**: Special handling for array component types
/// - **Enum support**: Proper enum hierarchy with Enum base class
/// - **Duplicate prevention**: Ensures no duplicate classes in the hierarchy
/// - **Ordered results**: Returns hierarchy in a logical traversal order
/// {@endtemplate}
final class ClassUtils {
  ClassUtils._() {
    _ensureInitialized();
  }

  /// {@template jet_class_utils_ensure_initialized}
  /// Ensures that JetLeaf's primitive and common reflective type caches are
  /// initialized before any type resolution, assignability check, or reflective
  /// lookup occurs.
  ///
  /// This method performs **lazy, one-time initialization** of the internal
  /// type maps and caches used by JetLeaf’s reflection system. It establishes
  /// consistent mappings between **Dart primitive types** and **JetLeaf
  /// language wrapper types**, while also caching common runtime classes to
  /// accelerate reflection and reduce overhead.
  ///
  /// ### Initialization Responsibilities
  ///
  /// 1. **Primitive ↔ Wrapper Bidirectional Mapping**
  ///    - Populates `_primitiveWrapperTypeMap` with JetLeaf → Dart mappings:
  ///      - `Boolean → bool`
  ///      - `Double → double`
  ///      - `Integer → int`
  ///      - `BigInteger → BigInt`
  ///      - `Float → num`
  ///    - Builds the inverse `_primitiveTypeToWrapperMap` for Dart → JetLeaf.
  ///
  /// 2. **Primitive Name Cache**
  ///    - Adds Dart primitive type names to `_primitiveTypeNameMap`
  ///      for fast lookup during deserialization or runtime analysis.
  ///
  /// 3. **Common Class Registration**
  ///    Registers frequently used classes into `_commonClassCache`
  ///    to avoid redundant reflective resolution at runtime.
  ///
  ///    These include:
  ///    - **List and Collection Types:** `List<T>`, `Set<T>`, `Map<K,V>`,
  ///      `Iterable`, `Iterator`, `MapEntry`
  ///    - **Error and Exception Hierarchy:** `Throwable`, `Exception`,
  ///      `Error`, `RuntimeException`, `StackTrace`
  ///    - **Meta and Utility Types:** `Enum`, `Optional`, `Class`, `Object`
  ///
  /// ### Performance Notes
  /// - This method is guarded by the `_initialized` flag, ensuring
  ///   it executes **only once per runtime session**.
  /// - Uses explicit `for` loops instead of higher-order functions
  ///   (e.g., `forEach`) for micro-performance optimization.
  ///
  /// ### Example
  /// ```dart
  /// ClassUtils._ensureInitialized();
  ///
  /// final boolClass = Class<bool>(null, PackageNames.DART);
  /// print(ClassUtils.getWrapperType(boolClass));
  /// // Output: Class<Boolean>(null, PackageNames.LANG)
  /// ```
  ///
  /// ### Returns
  /// Nothing. Once called, JetLeaf’s type reflection maps are guaranteed
  /// to be initialized for all subsequent lookups.
  ///
  /// ### See also
  /// - [_registerCommonClasses]
  /// - [Class.isAssignableFrom]
  /// - [PackageNames]
  /// {@endtemplate}
  static void _ensureInitialized() {
    if (_initialized) return;

    _classDeclarations = Runtime.getAllClasses();

    // 1. Primitive wrapper type mappings (JetLeaf → Dart)
    _primitiveWrapperTypeMap.put(Class<Boolean>(null, PackageNames.LANG), Class<bool>(null, PackageNames.DART));
    _primitiveWrapperTypeMap.put(Class<Double>(null, PackageNames.LANG), Class<double>(null, PackageNames.DART));
    _primitiveWrapperTypeMap.put(Class<Integer>(null, PackageNames.LANG), Class<int>(null, PackageNames.DART));
    _primitiveWrapperTypeMap.put(Class<BigInteger>(null, PackageNames.LANG), Class<BigInt>(null, PackageNames.DART));
    _primitiveWrapperTypeMap.put(Class<Float>(null, PackageNames.LANG), Class<num>(null, PackageNames.DART));

    // 2. Inverse mapping (Dart → JetLeaf)
    for (MapEntry<Class, Class> entry in _primitiveWrapperTypeMap.entries) {
      _primitiveTypeToWrapperMap.put(entry.value, entry.key);
      _registerCommonClasses([entry.key]);
    }

    // 3. Populate primitive type name map for quick lookup
    Set<Class> primitiveTypes = {};
    primitiveTypes.addAll(_primitiveWrapperTypeMap.values);
    primitiveTypes.addAll([
      Class<bool>(null, PackageNames.DART),
      Class<double>(null, PackageNames.DART),
      Class<int>(null, PackageNames.DART),
      Class<BigInt>(null, PackageNames.DART),
      Class<num>(null, PackageNames.DART),
    ]);

    for (Class primitiveType in primitiveTypes) {
      _primitiveTypeNameMap.put(primitiveType.getName(), primitiveType);
    }

    // 4. Register commonly used collection and object classes
    _registerCommonClasses([
      Class<List<Boolean>>(null, PackageNames.LANG),
      Class<List<double>>(null, PackageNames.DART),
      Class<List<int>>(null, PackageNames.DART),
      Class<List<BigInt>>(null, PackageNames.DART),
      Class<List<num>>(null, PackageNames.DART),
    ]);

    _registerCommonClasses([
      Class<List<String>>(null, PackageNames.DART),
      Class<List<Character>>(null, PackageNames.LANG),
      Class<List<Class>>(null, PackageNames.LANG),
      Class<List<Object>>(null, PackageNames.DART),
    ]);

    _registerCommonClasses([
      Class<Throwable>(null, PackageNames.LANG),
      Class<Exception>(null, PackageNames.DART),
      Class<Error>(null, PackageNames.DART),
      Class<RuntimeException>(null, PackageNames.LANG),
      Class<StackTrace>(null, PackageNames.DART),
    ]);

    _registerCommonClasses([
      Class<Enum>(null, PackageNames.DART),
      Class<Iterable>(null, PackageNames.DART),
      Class<Iterator>(null, PackageNames.DART),
      Class<List>(null, PackageNames.DART),
      Class<Set>(null, PackageNames.DART),
      Class<Map>(null, PackageNames.DART),
      Class<MapEntry>(null, PackageNames.DART),
      Class<Optional>(null, PackageNames.LANG),
    ]);

    _initialized = true;
  }

  /// {@template jet_class_utils_register_common_classes}
  /// Registers the given list of [classes] into JetLeaf’s internal
  /// `_commonClassCache`, making them accessible for rapid reflective lookup.
  ///
  /// This method is typically invoked during static initialization within
  /// [_ensureInitialized], but may also be used by extension modules to
  /// preload additional class references (e.g., domain-specific entities
  /// or framework abstractions).
  ///
  /// ### Example
  /// ```dart
  /// ClassUtils._registerCommonClasses([
  ///   Class<MyCustomAnnotation>(),
  ///   Class<MyService>(),
  /// ]);
  /// ```
  ///
  /// ### Parameters
  /// - `classes`: A list of [Class] instances to register.
  ///
  /// ### Behavior
  /// - Each class name is cached by its qualified name for constant-time
  ///   retrieval.
  ///
  /// ### See also
  /// - [_ensureInitialized]
  /// - [Class.getName]
  /// {@endtemplate}
  static void _registerCommonClasses(List<Class> classes) {
    for (var cls in classes) {
      _commonClassCache.put(cls.getName(), cls);
    }
  }
  
  // ========================================================================
  // Class Hierarchy and Type Analysis
  // ========================================================================

  /// {@template get_class_hierarchy}
  /// Retrieves the complete class hierarchy for the specified type, including
  /// all superclasses, interfaces, and special type relationships.
  /// 
  /// This method performs a comprehensive traversal of the type system to build
  /// a complete hierarchy that includes:
  /// - The original class
  /// - All superclasses (excluding Object initially, added at the end)
  /// - All interfaces implemented by each class in the hierarchy
  /// - Component types for arrays
  /// - Special handling for enums (adds Enum base class)
  /// - Object class as the root (added last if not already present)
  /// 
  /// ## Parameters
  /// 
  /// - `type`: The [Class] to analyze for hierarchy information
  /// 
  /// ## Returns
  /// 
  /// A [List<Class>] containing all classes in the hierarchy, ordered by
  /// traversal sequence. The list maintains insertion order and prevents
  /// duplicates.
  /// 
  /// ## Algorithm
  /// 
  /// 1. **Initial Setup**: Creates empty hierarchy list and visited set
  /// 2. **Breadth-First Traversal**: Processes each class level by level
  /// 3. **Superclass Addition**: Adds direct superclass (if not Object or enum)
  /// 4. **Interface Addition**: Adds all interfaces implemented by current class
  /// 5. **Array Handling**: For arrays, processes component type separately
  /// 6. **Enum Handling**: Adds Enum base class for enum types
  /// 7. **Object Addition**: Ensures Object is included as root class
  /// 
  /// ## Examples
  /// 
  /// ### Basic Class Hierarchy
  /// ```dart
  /// class Animal {}
  /// class Mammal extends Animal {}
  /// class Dog extends Mammal implements Comparable<Dog> {}
  /// 
  /// final hierarchy = ClassUtils.getClassHierarchy(Class.of<Dog>());
  /// // Result: [Dog, Mammal, Animal, Comparable<Dog>, Object]
  /// ```
  /// 
  /// ### Array Type Hierarchy
  /// ```dart
  /// final hierarchy = ClassUtils.getClassHierarchy(Class.of<List<String>>());
  /// // Includes both List<String> and String component relationships
  /// ```
  /// 
  /// ### Enum Type Hierarchy
  /// ```dart
  /// enum Color { red, green, blue }
  /// 
  /// final hierarchy = ClassUtils.getClassHierarchy(Class.of<Color>());
  /// // Result: [Color, Enum, Object] plus any interfaces
  /// ```
  /// 
  /// ## Performance Considerations
  /// 
  /// - Uses visited set to prevent infinite loops in complex hierarchies
  /// - Processes interfaces efficiently without redundant traversal
  /// - Handles deep inheritance chains without stack overflow
  /// {@endtemplate}
  static List<Class> getClassHierarchy(Class type) {
    _ensureInitialized();

    final result = _classHierarchy[type];
    if(result != null) {
      return result;
    }

    final hierarchy = <Class>[];
    final visited = <Type>{};
    final toProcess = <Class>[];

    _addToClassHierarchyEnd(type, hierarchy, visited);
    toProcess.add(type);

    while (toProcess.isNotEmpty) {
      final candidate = toProcess.removeAt(0);

      // Always get superclass from the actual candidate
      final superclass = candidate.getSuperClass();
      if (superclass != null && superclass.getType() != Object && !superclass.isEnum()) {
        if (_addToClassHierarchyEnd(superclass, hierarchy, visited)) {
          toProcess.add(superclass);
        }
      }

      // Always get interfaces from the actual candidate
      final interfaces = candidate.getAllInterfaces();
      for (final interface in interfaces) {
        if (_addToClassHierarchyEnd(interface, hierarchy, visited)) {
          toProcess.add(interface);
        }
      }

      // For arrays, also explore the component type separately
      if (candidate.isArray()) {
        final component = candidate.componentType()!;
        if (_addToClassHierarchyEnd(component, hierarchy, visited)) {
          toProcess.add(component);
        }
      }
    }

    if (type.isEnum()) {
      _addToClassHierarchyEnd(Class.of<Enum>(), hierarchy, visited);
      final enumInterfaces = Class.of<Enum>().getAllInterfaces();
      for (final interface in enumInterfaces) {
        _addToClassHierarchyEnd(interface, hierarchy, visited);
      }
    }

    // Only add Object if not already present
    if (!visited.contains(Object)) {
      hierarchy.add(Class.of<Object>());
    }

    _classHierarchy[type] = hierarchy;

    return hierarchy;
  }

  /// Helper method that adds a class to the end of the hierarchy list
  /// to prevent disruption of the traversal loop index.
  /// Modified to return boolean indicating if class was actually added
  /// 
  /// - Parameters
  /// type: the class to add to the hierarchy
  /// hierarchy: the list being built containing the class hierarchy
  /// visited: set tracking already processed classes to prevent duplicates
  /// 
  /// - Returns
  /// `true` if the class was added to the hierarchy; otherwise, `false`.
  static bool _addToClassHierarchyEnd(Class type, List<Class> hierarchy, Set<Type> visited) {
    if (visited.add(type.getType())) {
      hierarchy.add(type);
      return true;
    }
    return false;
  }

  /// {@template get_qualified_name}
  /// Returns the **fully qualified JetLeaf name** of the given [object].
  ///
  /// This utility is commonly used within the **JetLeaf reflection system**
  /// to obtain the canonical identifier of classes, components.
  /// The qualified name typically includes the full package or module
  /// prefix, ensuring uniqueness across the application context.
  ///
  /// ### Behavior
  /// - If [object] is a JetLeaf [Class] instance, the method simply calls
  ///   [Class.getQualifiedName] directly.
  /// - Otherwise, it retrieves the object's reflective class using
  ///   [Object.getClass] and delegates to that class’s qualified name.
  ///
  /// ### Example
  /// ```dart
  /// final myClass = Class<MyService>();
  /// print(getQualifiedName(myClass));
  /// // Output: package:example/example.dart.MyService
  ///
  /// final instance = MyService();
  /// print(getQualifiedName(instance));
  /// // Output: package:example/example.dart.MyService
  /// ```
  ///
  /// ### JetLeaf Context
  /// Qualified names are fundamental in JetLeaf’s reflection model and are used
  /// for:
  /// - Component registration and resolution within the JetLeaf container.
  /// - Identifying pointcut and proxy relationships in AOP.
  /// - Resolving dependencies across packages or pods.
  ///
  /// {@endtemplate}
  static String getQualifiedName(Object object) {
    _ensureInitialized();

    if (object is Class) {
      return object.getQualifiedName();
    }

    return object.getClass().getQualifiedName();
  }

  /// {@template get_package}
  /// Returns the **JetLeaf package** associated with the given [object].
  ///
  /// This method provides reflective access to the [Package] metadata of an
  /// object or class. It supports both direct [Class] instances and regular
  /// Dart objects, delegating to JetLeaf’s reflection API.
  ///
  /// ### Behavior
  /// - If [object] is a [Class], this method calls [Class.getPackage].
  /// - Otherwise, it retrieves the object's reflective class via
  ///   [Object.getClass] and returns its package.
  ///
  /// ### Example
  /// ```dart
  /// final classType = Class<MyService>();
  /// final pkg = ClassUtils.getPackage(classType);
  /// print(pkg?.getName()); // e.g., "jetleaf"
  ///
  /// final instance = MyService();
  /// print(ClassUtils.getPackage(instance)?.getName());
  /// // e.g., "jetleaf"
  /// ```
  ///
  /// ### JetLeaf Context
  /// Packages are used throughout JetLeaf for:
  /// - Component scanning and registration
  /// - Dependency resolution within pods
  /// - Managing AOP pointcut scoping
  ///
  /// {@endtemplate}
  static Package? getPackage(Object object) {
    _ensureInitialized();

    if (object is Class) {
      return object.getPackage();
    }

    return object.getClass().getPackage();
  }

  /// {@template get_package_name}
  /// Returns the **qualified package name** of the given [object].
  ///
  /// This method provides a convenient shorthand for obtaining a package’s
  /// name string without directly accessing the [Package] instance.
  ///
  /// ### Behavior
  /// - If [object] is a [Class], returns [Class.getPackage]?.getName().
  /// - Otherwise, retrieves the object’s reflective class via
  ///   [Object.getClass] and returns its package name.
  ///
  /// ### Example
  /// ```dart
  /// final classType = Class<MyService>();
  /// print(ClassUtils.getPackageName(classType));
  /// // Output: "jetleaf"
  ///
  /// final instance = MyService();
  /// print(ClassUtils.getPackageName(instance));
  /// // Output: "jetleaf"
  /// ```
  ///
  /// ### JetLeaf Context
  /// Useful for logging, diagnostic utilities, and AOP framework integration
  /// when you need a quick textual representation of a component’s package.
  ///
  /// {@endtemplate}
  static String? getPackageName(Object object) {
    _ensureInitialized();
    
    if (object is Class) {
      return object.getPackage()?.getName();
    }

    return object.getClass().getPackage()?.getName();
  }

  /// {@template getClassesAssignableTo}
  /// Retrieves all classes in the current runtime that are assignable to the specified type.
  /// 
  /// This method scans all available class declarations in the runtime and returns
  /// those that are assignable to (subtypes of) the given type. It performs deduplication
  /// to ensure each class is only returned once, even if multiple class loaders
  /// might provide different instances for the same class.
  /// 
  /// ## Type Assignment Rules
  /// 
  /// A class is considered assignable to the target type if:
  /// - It is the same class as the target type
  /// - It is a subclass of the target type
  /// - It implements the target type (if the target is an interface)
  /// - It is in the same type hierarchy as the target type
  /// 
  /// ## Performance Characteristics
  /// 
  /// - **Time Complexity**: O(n) where n is number of class declarations
  /// - **Space Complexity**: O(m) where m is number of matching classes
  /// - **Initialization**: Requires reflection system initialization
  /// - **Deduplication**: Eliminates duplicate class instances by qualified name
  /// 
  /// Example:
  /// ```dart
  /// // Find all classes that implement Service interface
  /// final serviceClasses = getClassesAssignableTo(Class<Service>());
  /// for (final serviceClass in serviceClasses) {
  ///   print('Found service: ${serviceClass.getQualifiedName()}');
  /// }
  /// 
  /// // Find all subclasses of AbstractRepository
  /// final repoClasses = getClassesAssignableTo(Class<AbstractRepository>());
  /// for (final repoClass in repoClasses) {
  ///   print('Found repository: ${repoClass.getQualifiedName()}');
  /// }
  /// 
  /// // Find all classes in a specific type hierarchy
  /// final componentClasses = getClassesAssignableTo(Class<Component>());
  /// print('Found ${componentClasses.length} component classes');
  /// ```
  /// 
  /// ## Use Cases
  /// 
  /// - **Plugin Discovery**: Find all classes implementing a plugin interface
  /// - **Aspect Scanning**: Locate all classes that can be advised by aspects
  /// - **Configuration Detection**: Discover configuration classes automatically
  /// - **Service Registration**: Find service implementations for auto-registration
  /// - **Testing Utilities**: Locate test classes or test utilities
  /// 
  /// ## Deduplication Strategy
  /// 
  /// The method uses qualified class names for deduplication to handle cases where:
  /// - Multiple class loaders load the same class
  /// - Different protection domains provide separate class instances
  /// - Runtime environments with complex class loading scenarios
  /// 
  /// ## Error Handling
  /// 
  /// - Silently continues if a class cannot be accessed (protection domain issues)
  /// - Handles malformed class declarations gracefully
  /// - Returns empty list if no matching classes found
  /// - Throws if reflection system is not properly initialized
  /// 
  /// ## Platform Considerations
  /// 
  /// Behavior may vary across platforms:
  /// - **DVM**: Full reflection support with all class declarations
  /// - **Native**: Limited to compiled-in classes and their dependencies
  /// - **Web**: Restricted by browser security and tree shaking
  /// 
  /// {@endtemplate}
  static List<Class> getClassesAssignableTo(Class type) {
    _ensureInitialized();

    final result = <Class>[];
    for (final declaration in _classDeclarations) {
      final clazz = Class.declared(declaration, ProtectionDomain.current());

      if (isAssignable(type, clazz)) {
        result.add(clazz);
      }
    }

    return _deduplicateByIdentity(result).toList();
  }

  /// {@template _deduplicateByIdentity}
  /// Removes duplicate class instances based on their qualified names.
  /// 
  /// This internal method ensures that each unique class (by qualified name)
  /// is only represented once in the result, even if multiple class instances
  /// exist for the same class due to different class loaders or protection domains.
  /// 
  /// ## Deduplication Strategy
  /// 
  /// The method uses qualified class names as the deduplication key because:
  /// - Qualified names are unique within a runtime environment
  /// - They remain consistent across different class loader instances
  /// - They provide a stable identifier regardless of loading context
  /// - They align with Java's class identity semantics
  /// 
  /// ## Error Resilience
  /// 
  /// The method gracefully handles cases where:
  /// - A class cannot provide its qualified name (access restrictions)
  /// - Class instances are in an invalid state
  /// - Reflection operations fail unexpectedly
  /// 
  /// In such cases, the problematic class is silently skipped to ensure
  /// the overall operation completes successfully.
  /// 
  /// Example internal behavior:
  /// ```dart
  /// final classes = [
  ///   ClassA, // package:example/example.dart.ClassA
  ///   ClassA, // package:example/example.dart.ClassA (duplicate from different loader)
  ///   ClassB, // package:example/example.dart.ClassB
  ///   ClassC, // package:example/example.dart.ClassC (fails to get qualified name)
  /// ];
  /// 
  /// final deduplicated = _deduplicateByIdentity(classes);
  /// // Result: [ClassA, ClassB] - ClassC is skipped due to error
  /// ```
  /// 
  /// ## Performance Characteristics
  /// 
  /// - **Time Complexity**: O(n) where n is number of input classes
  /// - **Space Complexity**: O(n) for the seen set and result list
  /// - **Hash Operations**: O(1) for qualified name lookups
  /// - **Exception Handling**: Minimal overhead for error cases
  /// 
  /// {@endtemplate}
  static Iterable<Class> _deduplicateByIdentity(Iterable<Class> classes) {
    final seen = <String>{};
    final result = <Class>[];

    for (final cls in classes) {
      try {
        if (seen.add(cls.getQualifiedName())) {
          result.add(cls);
        }
      } catch (_) {
        continue;
      }
    }

    return result;
  }

  /// Finds all classes annotated with the specified annotation type.
  /// 
  /// - Parameters
  /// annotation: the annotation type to search for
  /// includeMeta: whether to include meta-annotations (annotations on annotations)
  /// 
  /// - Returns
  /// a list of classes annotated with the specified annotation type
  /// 
  /// - Throws
  /// PodDefinitionValidationException if the reflection system is not initialized
  /// 
  /// - Example
  /// ```dart
  /// final serviceClasses = ClassUtils.findClassesAnnotatedWith<Service>();
  /// for (final serviceClass in serviceClasses) {
  ///   print('Found service: ${serviceClass.getQualifiedName()}');
  /// }
  /// ```
  static List<Class> findClassesAnnotatedWith<A>(Class<A> annotation, [bool includeMeta = false]) {
    _ensureInitialized();

    final result = <Class>[];
    for (final declaration in _classDeclarations) {
      final clazz = Class.declared(declaration, ProtectionDomain.current());

      if (includeMeta) {
        if (clazz.hasAnnotation<A>() || clazz.getAllAnnotations().any((ann) => ann.getType() == annotation.getType())) {
          result.add(clazz);
        }
      } else {
        if (clazz.hasDirectAnnotation<A>() || clazz.getAllDirectAnnotations().any((ann) => ann.getType() == annotation.getType())) {
          result.add(clazz);
        }
      }
    }

    return _deduplicateByIdentity(result).toList();
  }

  /// Check if the right-hand side type may be assigned to the left-hand side type.
  /// 
  /// Considers primitive wrapper classes as assignable to the corresponding primitive types.
  /// 
  /// - Parameters
  /// left: the target type (left-hand side (LHS) type)
  /// right: the source type (right-hand side (RHS) type)
  /// 
  /// - Returns
  /// `true` if the right-hand side type may be assigned to the left-hand side type; otherwise, `false`.
  static bool isAssignable(Class left, Class right) {
    _ensureInitialized();

    if (left.isAssignableFrom(right)) {
			return true;
		}

    if (left.isPrimitive()) {
			Class? resolvedPrimitive = _primitiveWrapperTypeMap.get(right);
			return (left == resolvedPrimitive);
		}
		else if (right.isPrimitive()) {
			Class? resolvedWrapper = _primitiveTypeToWrapperMap.get(right);
			return (resolvedWrapper != null && left.isAssignableFrom(resolvedWrapper));
		}
		return false;
  }

  /// {@template get_static_method}
  /// Retrieves the static method with the specified name from the given class.
  /// 
  /// - Parameters
  /// target: the class to analyze for static method
  /// methodName: the name of the static method to retrieve
  /// 
  /// - Returns
  /// The static method with the specified name from the given class.
  /// 
  /// - Throws
  /// PodDefinitionValidationException if the specified static method is not found in the given class.
  /// 
  /// - Example
  /// ```dart
  /// final method = ClassUtils.getStaticMethod(Class.of<UserService>(), 'configure');
  /// ```
  /// {@endtemplate}
  static Method? getStaticMethod(Class target, String methodName) {
    _ensureInitialized();

    Method? method = target.getMethod(methodName);
    if (method != null && method.isStatic()) {
      return method;
    }
    return null;
  }

  /// {@template get_method_if_available}
  /// Retrieves the method with the specified name and parameter types from the given class.
  /// 
  /// - Parameters
  /// clazz: the class to analyze for method
  /// methodName: the name of the method to retrieve
  /// paramTypes: the parameter types of the method to retrieve
  /// 
  /// - Returns
  /// The method with the specified name and parameter types from the given class.
  /// 
  /// - Throws
  /// PodDefinitionValidationException if the specified method is not found in the given class.
  /// 
  /// - Example
  /// ```dart
  /// final method = ClassUtils.getMethodIfAvailable(Class.of<UserService>(), 'configure', [Class.of<String>()]);
  /// ```
  /// {@endtemplate}
  static Method? getMethodIfAvailable(Class clazz, String methodName, [List<Class>? paramTypes]) {
    _ensureInitialized();

    if (paramTypes != null) {
			return getMethodOrNull(clazz, methodName, paramTypes);
		} else {
			Set<Method> candidates = findMethodCandidatesByName(clazz, methodName);
			if (candidates.length == 1) {
				return candidates.iterator.moveNext() ? candidates.iterator.current : candidates.single;
			}
			return null;
		}
  }

  /// {@template get_method_or_null}
  /// Retrieves the method with the specified name and parameter types from the given class.
  /// 
  /// - Parameters
  /// clazz: the class to analyze for method
  /// methodName: the name of the method to retrieve
  /// paramTypes: the parameter types of the method to retrieve
  /// 
  /// - Returns
  /// The method with the specified name and parameter types from the given class.
  /// 
  /// - Throws
  /// PodDefinitionValidationException if the specified method is not found in the given class.
  /// 
  /// - Example
  /// ```dart
  /// final method = ClassUtils.getMethodOrNull(Class.of<UserService>(), 'configure', [Class.of<String>()]);
  /// ```
  /// {@endtemplate}
  static Method? getMethodOrNull(Class clazz, String methodName, List<Class> paramTypes) {
    _ensureInitialized();

    return clazz.getMethodBySignature(methodName, paramTypes);
  }

  /// {@template find_method_candidates_by_name}
  /// Retrieves the set of methods with the specified name from the given class.
  /// 
  /// - Parameters
  /// clazz: the class to analyze for methods
  /// methodName: the name of the methods to retrieve
  /// 
  /// - Returns
  /// The set of methods with the specified name from the given class.
  /// 
  /// - Throws
  /// PodDefinitionValidationException if the specified method name is not found in the given class.
  /// 
  /// - Example
  /// ```dart
  /// final methods = ClassUtils.findMethodCandidatesByName(Class.of<UserService>(), 'configure');
  /// ```
  /// {@endtemplate}
  static Set<Method> findMethodCandidatesByName(Class clazz, String methodName) {
    _ensureInitialized();

    Set<Method> candidates = HashSet();
		final methods = clazz.getMethods();
		for (Method method in methods) {
			if (methodName.equals(method.getName())) {
				candidates.add(method);
			}
		}

		return candidates;
  }

  /// {@template jet_method_utils_is_assignable_to_error}
  /// Determines whether the given [object] represents or is assignable to a
  /// Dart error type within the JetLeaf runtime type system.
  ///
  /// This method supports both [Class] metadata representations and concrete
  /// runtime instances. It leverages JetLeaf’s reflective [Class] API to
  /// perform safe type compatibility checks against [Throwable],
  /// [Exception], and [Error] — ensuring consistency across Dart’s core
  /// error hierarchy and JetLeaf’s extended reflective model.
  ///
  /// ### Behavior
  /// - If [object] is a [Class], the method directly checks assignability
  ///   using `isAssignableFrom` across the core error types.
  /// - If [object] is an instance, the method retrieves its reflective
  ///   class via `object.getClass()` and recursively re-evaluates assignability.
  ///
  /// This is used internally by JetLeaf’s reflective invocation system
  /// to determine if a method parameter can safely accept a throwable type
  /// (for example, during lifecycle event dispatch or error propagation).
  ///
  /// ### Example
  /// ```dart
  /// final clazz = Class<Exception>(null, PackageNames.DART);
  /// final result = ClassUtils.isAssignableToError(clazz);
  ///
  /// print(result); // true
  /// ```
  ///
  /// In this example, the [Exception] class is recognized as a valid
  /// throwable type by JetLeaf.
  ///
  /// ### Returns
  /// `true` if the provided object (or its reflective class) is assignable to
  /// [Throwable], [Exception], or [Error]; otherwise, `false`.
  ///
  /// ### See also
  /// - [Throwable]
  /// - [Exception]
  /// - [Error]
  /// - [Class.isAssignableFrom]
  /// {@endtemplate}
  static bool isAssignableToError(Object object) {
    _ensureInitialized();

    if (object is Class) {
      return Class<Throwable>(null, PackageNames.LANG).isAssignableFrom(object) ||
          Class<Exception>(null, PackageNames.DART).isAssignableFrom(object) ||
          Class<Error>(null, PackageNames.DART).isAssignableFrom(object);
    }

    final clazz = object.getClass();
    return isAssignableToError(clazz);
  }

  /// {@template jet_method_utils_is_future}
  /// Determines whether the given [object] represents or is assignable to a
  /// Dart [Future] or [FutureOr] type within JetLeaf’s reflective runtime.
  ///
  /// This method provides a unified way to test for asynchronous types across
  /// both reflective [Class] metadata and runtime instances. It is commonly
  /// used within JetLeaf’s task scheduling, dependency injection, and
  /// asynchronous pipeline orchestration subsystems to determine whether a
  /// method or result type requires asynchronous handling.
  ///
  /// ### Behavior
  /// - If [object] is a [Class], it checks assignability against both
  ///   [Future] and [FutureOr].
  /// - If [object] is an instance, it retrieves the reflective class from
  ///   `object.getClass()` and reuses the same check recursively.
  ///
  /// ### Example
  /// ```dart
  /// final asyncClass = Class<Future>(null, PackageNames.DART);
  /// final result = ClassUtils.isAsync(asyncClass);
  ///
  /// print(result); // true
  /// ```
  ///
  /// ### Usage in JetLeaf
  /// This method allows JetLeaf to:
  /// - Detect asynchronous method return types during runtime analysis.
  /// - Manage async tasks in lifecycle methods and scheduling components.
  /// - Correctly unwrap `FutureOr<T>` in reactive pipelines.
  ///
  /// ### Returns
  /// `true` if the provided object (or its reflective class) represents
  /// [Future] or [FutureOr]; otherwise, `false`.
  ///
  /// ### See also
  /// - [Future]
  /// - [FutureOr]
  /// - [Class.isAssignableFrom]
  /// - [isAssignableToError]
  /// {@endtemplate}
  static bool isAsync(Object object) {
    _ensureInitialized();

    if (object is Class) {
      return Class<Future>().isAssignableFrom(object) ||
          Class<FutureOr>(null, PackageNames.DART).isAssignableFrom(object);
    }

    final clazz = object.getClass();
    return isAsync(clazz);
  }

  /// Checks whether the given [type] represents a generated proxy class.
  ///
  /// A proxy class in JetLeaf is identified by its name starting with
  /// the constant prefix defined in [Constant.PROXY_IDENTIFIER].
  ///
  /// - [type]: The [Class] object representing the type to check.
  /// 
  /// Returns `true` if the type's name starts with the proxy prefix,
  /// otherwise returns `false`.
  static bool isProxyClass(Class type) => type.getName().startsWith(Constant.PROXY_IDENTIFIER);

  /// Retrieves the original (non-proxied) [Class] representation for a given proxy type
  /// or instance within the JetLeaf runtime.
  ///
  /// This method is used to resolve the *real* class behind a generated proxy. It ensures
  /// that even when dealing with a proxied instance or type, JetLeaf can correctly
  /// identify and access the underlying class metadata for reflection, interception,
  /// and validation.
  ///
  /// The resolution logic follows this order:
  /// 1. **Instance check** – If [instance] is provided:
  ///    - If the instance is itself a proxy (`runtimeType` starts with
  ///      [Constant.PROXY_IDENTIFIER]) and implements [ClassGettable],
  ///      it directly returns `instance.toClass()`.
  ///    - Otherwise, if it’s a normal runtime object (not `"Type"` and not a proxy),
  ///      it resolves the class using its qualified name derived from
  ///      [ReflectionUtils.findQualifiedNameFromType].
  ///
  /// 2. **Static method check** – If no instance or proxy mapping is found,
  ///    it attempts to invoke the proxy’s static
  ///    [Constant.STATIC_REAL_CLASS_METHOD_NAME] (i.e., `getRealClass`)
  ///    to retrieve the original class reference.
  ///
  /// 3. **Fallback** – If neither of the above applies, it returns
  ///    the declared interface of [proxyClass] (if available), otherwise the
  ///    [proxyClass] itself.
  ///
  /// This method guarantees that JetLeaf always operates on the actual logical
  /// class definition, even when proxies are introduced for interception or lifecycle
  /// management.
  ///
  /// Example:
  /// ```dart
  /// final realClass = ClassUtils.getProxiedClass(proxyClass, instance);
  /// print('Resolved class: ${realClass.getName()}');
  /// ```
  static Class getProxiedClass(Class proxyClass, [Object? instance]) {
    _ensureInitialized();

    if (instance != null) {
      final string = instance.runtimeType.toString();

      if (string.startsWith(Constant.PROXY_IDENTIFIER) && instance is ClassGettable) {
        return instance.toClass();
      }

      if (string.notEqualsIgnoreCase("type") && !string.startsWith(Constant.PROXY_IDENTIFIER)) {
        return Class.fromQualifiedName(ReflectionUtils.findQualifiedNameFromType(instance.runtimeType));
      }
    }

    final method = proxyClass.getMethod(Constant.STATIC_REAL_CLASS_METHOD_NAME);
    if (method != null) {
      return method.invoke(null);
    }

    return proxyClass.getDeclaredInterface() ?? proxyClass;
  }

  /// Checks whether a class with the given [name] exists and can be loaded.
  ///
  /// This attempts to resolve the class using `Class.fromQualifiedName(name)`.
  /// If the class is found, returns `true`. If any exception occurs (class not found,
  /// invalid name, etc.), returns `false`.
  ///
  /// Example:
  /// ```dart
  /// bool exists = Utils.isClass('dart.core.String'); // true
  /// bool missing = Utils.isClass('non.existent.Class'); // false
  /// ```
  static bool isClass(String name) {
    _ensureInitialized();

    try {
      Class.fromQualifiedName(name);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns a [Class] representation of the given [type].
  ///
  /// This method performs runtime reflection to resolve the fully qualified
  /// name of the type and returns a [Class] instance representing it.
  /// It allows inspecting metadata, annotations, and other class-level
  /// information at runtime.
  ///
  /// Example:
  /// ```dart
  /// final clazz = ClassUtils.getClass(User);
  /// print(clazz.name); // Output: 'User'
  /// print(clazz.qualifiedName); // Output: 'package:example/example/src/user.dart.User'
  /// ```
  ///
  /// [type] – The Dart [Type] to resolve into a [Class] representation.
  ///
  /// Returns a [Class] instance corresponding to the provided type.
  static Class getClass(Type type) {
    _ensureInitialized();
    return Class.fromQualifiedName(ReflectionUtils.findQualifiedNameFromType(type));
  }

  /// Attempts to resolve and load a [`Class`] instance from a given [object].
  ///
  /// This utility provides a unified way to dynamically convert different forms
  /// of class references — such as [`ClassType`], Dart [`Type`], or a qualified
  /// class name [`String`] — into a reflectable [`Class`] representation used
  /// within JetLeaf's type system.
  ///
  /// ### Resolution Rules
  ///
  /// The method evaluates the runtime type of [object] in the following order:
  ///
  /// 1. **[`ClassType`]** → Converts directly using [`ClassType.toClass()`].
  /// 2. **[`Type`]** → Resolved reflectively using [`ClassUtils.getClass()`].
  /// 3. **[`String`]** → If recognized as a qualified class name (via
  ///    [`ClassUtils.isClass()`]), it is converted using
  ///    [`Class.fromQualifiedName()`].
  ///
  /// If [object] does not match any of these recognized types, or if the string
  /// is not a valid qualified class name, the method returns `null`.
  ///
  /// ### Example
  /// ```dart
  /// final c1 = ClassUtils.loadClass(ClassType<UserService>());
  /// final c2 = ClassUtils.loadClass(UserService);
  /// final c3 = ClassUtils.loadClass('package:app/services.dart.UserService');
  ///
  /// // All of the above yield equivalent Class representations.
  /// final c4 = ClassUtils.loadClass('userService'); // → null (not a class name)
  /// ```
  ///
  /// ### Returns
  /// A [`Class`] instance if successfully resolved, otherwise `null`.
  ///
  /// ### See Also
  /// - [`ClassUtils.getClass`] — Resolves from a Dart [Type].
  /// - [`ClassType`] — Type-safe wrapper used in annotation-based metadata.
  /// - [`Class.fromQualifiedName`] — Builds a [`Class`] from a qualified name.
  static Class? loadClass(Object object) {
    try {
      if (object is ClassType) {
        return object.toClass();
      } else if (object is Type) {
        return ClassUtils.getClass(object);
      } else if (object is String && ClassUtils.isClass(object)) {
        return Class.fromQualifiedName(object);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  /// Checks whether the given [object] is of type `void`.
  ///
  /// This is useful when dealing with reflective method return types,
  /// to determine if a method returns `void` (i.e., does not return a value).
  ///
  /// ### Parameters
  /// - [object]: The object to inspect. Can be any value or `null`.
  ///
  /// ### Returns
  /// - `true` if the object represents a `void` return type (no value).
  /// - `false` otherwise.
  ///
  /// ### Example
  /// ```dart
  /// void doSomething() {}
  /// int sum(int a, int b) => a + b;
  ///
  /// print(ClassUtils.isVoid(doSomething())); // true
  /// print(ClassUtils.isVoid(sum(1, 2))); // false
  /// ```
  static bool isVoid(dynamic object) {
    try {
      Class.forObject(object);
      return false;
    } catch (_) {
      return true;
    }
  }
}