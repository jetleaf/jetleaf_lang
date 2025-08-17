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

import '../../extensions/primitives/string.dart';
import '../../collections/hash_set.dart';
import '../../commons/optional.dart';
import '../../extensions/primitives/map.dart';
import '../../math/big_integer.dart';
import '../../primitives/boolean.dart';
import '../../primitives/character.dart';
import '../../primitives/double.dart';
import '../../primitives/float.dart';
import '../../primitives/integer.dart';
import '../../throwable.dart';
import '../constructor/constructor.dart';
import '../method/method.dart';
import 'class.dart';

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
  // ========================================================================
  // Constants and Static Fields
  // ========================================================================
  
  /// Suffix for array class names: "[]"
  static const String arrayTypeSuffix = '[]';
  
  /// The package separator character: '.'
  static const String packageSeparator = '.';
  
  /// The nested class separator character: '\$'
  static const String nestedClassSeparator = '\$';

  /// Map with primitive wrapper type as key and corresponding primitive
  /// type as value, for example: `Class<Integer>() -> Class<int>()`.
  static final Map<Class, Class> _primitiveWrapperTypeMap = {};

  /// Map with primitive type as key and corresponding wrapper
  /// type as value, for example: `Class<int>() -> Class<Integer>()`.
  static final Map<Class, Class> _primitiveTypeToWrapperMap = {};

  /// Map with primitive type name as key and corresponding primitive
  /// type as value, for example: `'int' -> Class<int>()`.
  static final Map<String, Class> _primitiveTypeNameMap = {};

  /// Map with common Dart language class name as key and corresponding Class as value.
  /// Primarily for efficient deserialization of remote invocations.
  static final Map<String, Class> _commonClassCache = {};

  /// Common Dart language interfaces which are supposed to be ignored
  /// when searching for 'primary' user-level interfaces.
  static Set<Class> _dartLanguageInterfaces = {};

  /// Cache for equivalent methods on a interface implemented by the declaring class.
  /// A `null` value signals that no interface method was found for the key.
  static final Map<Method, Method> _interfaceMethodCache = {};

  /// Cache for equivalent methods on a public interface implemented by the declaring class.
  /// A `null` value signals that no public interface method was found for the key.
  static final Map<Method, Method> _publicInterfaceMethodCache = {};

  /// Cache for equivalent public methods in a public declaring type within the type hierarchy
  /// of the method's declaring class.
  /// A `null` value signals that no publicly accessible method was found for the key.
  static final Map<Method, Method> _publiclyAccessibleMethodCache = {};

  /// Cachec for class hierarchies within a class.
  /// 
  /// A `null` value signals that no class hierarchy was found for the key.
  static final Map<Class, List<Class>> _classHierarchy = {};

  ClassUtils._() {
    print("[ClassUtils] Initializing");
    _primitiveWrapperTypeMap.put(Class<Boolean>(), Class<bool>());
		_primitiveWrapperTypeMap.put(Class<Double>(), Class<double>());
		_primitiveWrapperTypeMap.put(Class<Integer>(), Class<int>());
		_primitiveWrapperTypeMap.put(Class<BigInteger>(), Class<BigInt>());
		_primitiveWrapperTypeMap.put(Class<Float>(), Class<num>());

    print("[ClassUtils] Initialized with primitive wrapper type map: ${_primitiveWrapperTypeMap.keys}");

    // Map entry iteration is less expensive to initialize than forEach with lambdas
		for (MapEntry<Class, Class> entry in _primitiveWrapperTypeMap.entries) {
			_primitiveTypeToWrapperMap.put(entry.value, entry.key);
			_registerCommonClasses([entry.key]);
		}

    print("[ClassUtils] Initialized with primitive type to wrapper map: ${_primitiveTypeToWrapperMap.keys}");

    Set<Class> primitiveTypes = {};
		primitiveTypes.addAll(_primitiveWrapperTypeMap.values);
    primitiveTypes.addAll([Class<bool>(), Class<double>(), Class<int>(), Class<BigInt>(), Class<num>()]);
		for (Class primitiveType in primitiveTypes) {
			_primitiveTypeNameMap.put(primitiveType.getName(), primitiveType);
		}

    print("[ClassUtils] Initialized with primitive type name map: ${_primitiveTypeNameMap.keys}");

		_registerCommonClasses([Class<List<Boolean>>(), Class<List<double>>(), Class<List<int>>(), Class<List<BigInt>>(), Class<List<num>>()]);
		_registerCommonClasses([Class<List<String>>(), Class<List<Character>>(), Class<List<Class>>(), Class<List<Object>>()]);
		_registerCommonClasses([Class<Throwable>(), Class<Exception>(), Class<Error>(), Class<RuntimeException>(), Class<StackTrace>()]);
		_registerCommonClasses([Class<Enum>(), Class<Iterable>(), Class<Iterator>(), Class<List>(), Class<Set>(), Class<Map>(), Class<MapEntry>(), Class<Optional>()]);

    print("[ClassUtils] Initialized with common classes: ${_commonClassCache.keys}");

		Set<Class> dartLanguageInterfaceArray = {Class<Type>(), Class<Comparable>()};
		_registerCommonClasses(dartLanguageInterfaceArray.toList());
		_dartLanguageInterfaces = Set.unmodifiable(dartLanguageInterfaceArray);

    print("[ClassUtils] Initialized with common classes: ${_commonClassCache.keys}");
  }

  /// Register the given common classes with the ClassUtils cache.
  static void _registerCommonClasses(List<Class> classes) {
    for(var cls in classes) {
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

  static Method? getStaticMethod(Class target, String methodName) {
    Method? method = target.getMethod(methodName);
    if (method != null && method.isStatic()) {
      return method;
    }
    return null;
  }

  static Method? getMethodIfAvailable(Class clazz, String methodName, [List<Class>? paramTypes]) {
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

  static Method? getMethodOrNull(Class clazz, String methodName, List<Class> paramTypes) {
    return clazz.getMethodBySignature(methodName, paramTypes);
  }

  static Set<Method> findMethodCandidatesByName(Class clazz, String methodName) {
    Set<Method> candidates = HashSet();
		final methods = clazz.getMethods();
		for (Method method in methods) {
			if (methodName.equals(method.getName())) {
				candidates.add(method);
			}
		}
		return candidates;
  }

  static Constructor? getConstructorIfAvailable(Class targetClass, List<Class> paramTypes) {
    return targetClass.getConstructorBySignature(paramTypes);
  }
}