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

import '../declaration/declaration.dart';
import 'class.dart';
import '../runtime/type_discovery.dart';
import 'protection_domain.dart';

/// {@template resolvable_type}
/// A comprehensive type resolution system for Dart that provides advanced type introspection,
/// generic type handling, and assignability checking capabilities.
/// 
/// ResolvableType wraps Dart's Type system to provide enhanced functionality for:
/// - Generic type resolution and manipulation
/// - Type assignability checking with inheritance support
/// - Array and collection type handling
/// - Type variable resolution and bounds checking
/// - Integration with reflection and dependency injection systems
/// 
/// This class is particularly useful for frameworks that need to perform complex
/// type operations at runtime, such as serialization libraries, dependency
/// injection containers, and validation frameworks.
/// 
/// Basic Usage:
/// ```dart
/// // Create ResolvableType for simple types
/// final stringType = ResolvableType.forClass(String);
/// final intType = ResolvableType.forClass(int);
/// 
/// // Work with generic types
/// final listType = ResolvableType.forClass(List<String>);
/// print(listType.hasGenerics()); // true
/// print(listType.getGeneric().resolve()?.getType()); // String
/// 
/// // Check type assignability
/// final objectType = ResolvableType.forClass(Object);
/// print(objectType.isAssignableFromType(String)); // true
/// 
/// // Handle arrays and collections
/// final arrayType = ResolvableType.forClass(List<int>);
/// print(arrayType.isArray()); // true
/// print(arrayType.getComponentType().resolve()?.getType()); // int
/// ```
/// 
/// Advanced Usage:
/// ```dart
/// // Create complex generic types
/// final mapType = ResolvableType.forClassWithGenerics(
///   Map, 
///   [String, List<int>]
/// );
/// 
/// // Resolve nested generics
/// final nestedType = mapType.getGeneric([1]); // List<int>
/// final componentType = nestedType.getComponentType(); // int
/// 
/// // Type conversion and casting
/// final collectionType = listType.asCollection();
/// final mapAsCollection = mapType.asCollection();
/// 
/// // Instance checking
/// final myList = <String>['hello', 'world'];
/// print(listType.isInstance(myList)); // true
/// ```
/// {@endtemplate}
class ResolvableType {
  /// {@template resolvable_type_none}
  /// A special ResolvableType instance representing an unresolvable or empty type.
  /// 
  /// This constant is returned when type resolution fails or when no type
  /// information is available. It serves as a null object pattern to avoid
  /// null pointer exceptions in type resolution chains.
  /// 
  /// Example:
  /// ```dart
  /// final unknownType = ResolvableType.NONE;
  /// print(unknownType.resolve()); // null
  /// print(unknownType.hasGenerics()); // false
  /// print(unknownType.isArray()); // false
  /// ```
  /// {@endtemplate}
  static final ResolvableType NONE = ResolvableType._empty();
  
  static final List<ResolvableType> _EMPTY_TYPES_ARRAY = [];
  static final Map<ResolvableType, ResolvableType> _cache = {};

  /// The underlying Dart type being managed
  final Type _type;
  
  /// The component type for an array or null if the type should be deduced
  final ResolvableType? _componentType;
  
  /// Optional provider for the type
  final TypeProvider? _typeProvider;
  
  /// The VariableResolver to use or null if no resolver is available
  final VariableResolver? _variableResolver;
  
  final int? _hash;
  Class? _resolved;
  ResolvableType? _superType;
  List<ResolvableType>? _interfaces;
  List<ResolvableType>? _generics;
  bool? _unresolvableGenerics;

  /// Private constructor used to create a new ResolvableType for cache key purposes
  ResolvableType._(
    this._type, 
    this._typeProvider, 
    this._variableResolver, {
    ResolvableType? componentType,
    int? hash,
  }) : _componentType = componentType,
       _hash = hash,
       _resolved = null;

  /// Private constructor for NONE
  ResolvableType._empty() 
    : _type = _EmptyType._instance,
      _componentType = null,
      _typeProvider = null,
      _variableResolver = null,
      _hash = null,
      _resolved = null;

  /// Private constructor used to create a new ResolvableType on a Class basis
  ResolvableType._forClass(Class? clazz) 
    : _resolved = clazz ?? Class.forType(Object),
      _type = (clazz ?? Class.forType(Object)).getType(),
      _componentType = null,
      _typeProvider = null,
      _variableResolver = null,
      _hash = null;

  /// {@macro resolvable_type_get_type}
  Type getType() => _type;

  /// {@macro resolvable_type_get_raw_class}
  Class? getRawClass() {
    if (_type == _resolved?.getType()) {
      return _resolved;
    }
    
    // Try to resolve from type discovery
    final declaration = TypeDiscovery.findByType(_type);
    if (declaration != null) {
      return Class.declared(declaration, ProtectionDomain.system());
    }
    
    return null;
  }

  /// {@macro resolvable_type_get_source}
  Object getSource() => _typeProvider?.getSource() ?? _type;

  /// {@macro resolvable_type_to_class}
  Class? toClass() => resolve(Class.forType(Object));

  /// {@macro resolvable_type_is_instance}
  bool isInstance(Object? obj) {
    if (obj == null) return false;
    final resolved = resolve();
    return resolved?.isInstance(obj) ?? false;
  }

  /// {@template resolvable_type_is_assignable_from_type}
  /// Determines whether this ResolvableType is assignable from the specified Type.
  /// 
  /// This method checks if a value of the specified Type can be assigned to
  /// a variable of this ResolvableType. It considers inheritance hierarchies
  /// and interface implementations.
  /// 
  /// Parameters:
  /// - [other]: The Type to check assignability from
  /// 
  /// Returns:
  /// - true if this type is assignable from the other type
  /// - false if assignment would not be valid
  /// 
  /// Example:
  /// ```dart
  /// final objectType = ResolvableType.forClass(Object);
  /// final stringType = ResolvableType.forClass(String);
  /// final intType = ResolvableType.forClass(int);
  /// 
  /// print(objectType.isAssignableFromType(String)); // true - Object can hold String
  /// print(stringType.isAssignableFromType(Object)); // false - String cannot hold Object
  /// print(objectType.isAssignableFromType(int)); // true - Object can hold int
  /// 
  /// // Useful for type checking in generic contexts
  /// bool canAssign<T>(Type sourceType, Type targetType) {
  ///   final target = ResolvableType.forClass(targetType);
  ///   return target.isAssignableFromType(sourceType);
  /// }
  /// ```
  /// {@endtemplate}
  bool isAssignableFromType(Type other) {
    final resolved = resolve();
    if (resolved == null) return false;
    
    final otherClass = Class.forType(other);
    return resolved.isAssignableFrom(otherClass);
  }

  /// {@template resolvable_type_is_assignable_from_resolvable}
  /// Determines whether this ResolvableType is assignable from another ResolvableType.
  /// 
  /// This method performs comprehensive assignability checking between two
  /// ResolvableType instances, considering generic types, inheritance, and
  /// interface implementations.
  /// 
  /// Parameters:
  /// - [other]: The ResolvableType to check assignability from
  /// 
  /// Returns:
  /// - true if this type is assignable from the other ResolvableType
  /// - false if assignment would not be valid
  /// 
  /// Example:
  /// ```dart
  /// final listType = ResolvableType.forClass(List<Object>);
  /// final stringListType = ResolvableType.forClass(List<String>);
  /// final iterableType = ResolvableType.forClass(Iterable<String>);
  /// 
  /// print(listType.isAssignableFromResolvable(stringListType)); // depends on variance
  /// print(iterableType.isAssignableFromResolvable(stringListType)); // true - List implements Iterable
  /// 
  /// // Useful for generic type validation
  /// bool validateGenericAssignment(ResolvableType target, ResolvableType source) {
  ///   return target.isAssignableFromResolvable(source);
  /// }
  /// ```
  /// {@endtemplate}
  bool isAssignableFromResolvable(ResolvableType other) {
    return isAssignableFrom(other, false, null, false);
  }

  /// {@template resolvable_type_is_assignable_from_resolved_part}
  /// Determines assignability from another ResolvableType up to unresolvable parts.
  /// 
  /// This method performs assignability checking but stops at unresolvable
  /// type variables or dynamic types, treating them as compatible. This is
  /// useful for partial type checking scenarios.
  /// 
  /// Parameters:
  /// - [other]: The ResolvableType to check assignability from
  /// 
  /// Returns:
  /// - true if assignable up to unresolvable parts
  /// - false if definitely not assignable
  /// 
  /// Example:
  /// ```dart
  /// final genericType = ResolvableType.forClass(List); // List<T> where T is unresolved
  /// final stringListType = ResolvableType.forClass(List<String>);
  /// 
  /// // This might return true even if full resolution would fail
  /// print(genericType.isAssignableFromResolvedPart(stringListType));
  /// ```
  /// {@endtemplate}
  bool isAssignableFromResolvedPart(ResolvableType other) {
    return isAssignableFrom(other, false, null, true);
  }

  bool isAssignableFrom(ResolvableType other, bool strict, Map<Type, Type>? matchedBefore, bool upUntilUnresolvable) {
    // If we cannot resolve types, we are not assignable
    if (this == NONE || other == NONE) {
      return false;
    }

    if (matchedBefore != null && matchedBefore[_type] == other._type) {
      return true;
    }

    if (upUntilUnresolvable && (other._isUnresolvableTypeVariable() || other._isDynamicType())) {
      return true;
    }

    // Deal with array by delegating to the component type
    if (isArray()) {
      return other.isArray() && 
             getComponentType().isAssignableFrom(other.getComponentType(), true, matchedBefore, upUntilUnresolvable);
    }

    // Main assignability check
    final ourResolved = resolve();
    final otherResolved = other.resolve();
    
    if (ourResolved == null || otherResolved == null) {
      return false;
    }

    if (strict) {
      return ourResolved.getType() == otherResolved.getType();
    } else {
      return ourResolved.isAssignableFrom(otherResolved);
    }
  }

  /// {@template resolvable_type_is_array}
  /// Determines whether this ResolvableType represents an array or list type.
  /// 
  /// In Dart, this method checks if the type represents a List or other
  /// array-like collection that has a component type.
  /// 
  /// Returns:
  /// - true if this type represents an array/list
  /// - false if this is not an array type
  /// 
  /// Example:
  /// ```dart
  /// final listType = ResolvableType.forClass(List<String>);
  /// final stringType = ResolvableType.forClass(String);
  /// final setType = ResolvableType.forClass(Set<int>);
  /// 
  /// print(listType.isArray()); // true
  /// print(stringType.isArray()); // false
  /// print(setType.isArray()); // false (Set is not considered an array)
  /// 
  /// // Use in type processing
  /// void processType(ResolvableType type) {
  ///   if (type.isArray()) {
  ///     final componentType = type.getComponentType();
  ///     print("Processing array of ${componentType.resolve()?.getType()}");
  ///   } else {
  ///     print("Processing single value of ${type.resolve()?.getType()}");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  bool isArray() {
    if (this == NONE) return false;
    
    final resolved = resolve();
    if (resolved != null) {
      return resolved.isArray();
    }
    
    return _type.toString().contains('List<') || _type == List;
  }

  /// {@template resolvable_type_get_component_type}
  /// Returns the component type of an array or list type.
  /// 
  /// For array/list types, this method returns a ResolvableType representing
  /// the type of elements contained in the array. For non-array types,
  /// this returns ResolvableType.NONE.
  /// 
  /// Returns:
  /// - ResolvableType representing the component/element type
  /// - ResolvableType.NONE if this is not an array type
  /// 
  /// Example:
  /// ```dart
  /// final stringListType = ResolvableType.forClass(List<String>);
  /// final intListType = ResolvableType.forClass(List<int>);
  /// final nestedListType = ResolvableType.forClass(List<List<String>>);
  /// 
  /// final stringComponent = stringListType.getComponentType();
  /// print(stringComponent.resolve()?.getType()); // String
  /// 
  /// final intComponent = intListType.getComponentType();
  /// print(intComponent.resolve()?.getType()); // int
  /// 
  /// final nestedComponent = nestedListType.getComponentType();
  /// print(nestedComponent.resolve()?.getType()); // List<String>
  /// print(nestedComponent.isArray()); // true
  /// 
  /// // Useful for recursive type processing
  /// void processArrayType(ResolvableType type) {
  ///   if (type.isArray()) {
  ///     final componentType = type.getComponentType();
  ///     if (componentType.isArray()) {
  ///       print("Multi-dimensional array");
  ///       processArrayType(componentType); // Recursive processing
  ///     } else {
  ///       print("Array of ${componentType.resolve()?.getType()}");
  ///     }
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType getComponentType() {
    if (this == NONE) return NONE;
    
    if (_componentType != null) {
      return _componentType;
    }

    final resolved = resolve();

    if (resolved != null) {
      final componentClass = resolved.componentType();
      if (componentClass != null) {
        return forType(componentClass.getType(), this);
      }
    }

    return resolveType().getComponentType();
  }

  /// {@template resolvable_type_get_key_type}
  /// Returns the key type for Map-like types.
  /// 
  /// For Map types, this method returns a ResolvableType representing the
  /// key type (the first generic parameter). For non-Map types, this
  /// returns ResolvableType.NONE.
  /// 
  /// Returns:
  /// - ResolvableType representing the key type for Maps
  /// - ResolvableType.NONE if this is not a Map type
  /// 
  /// Example:
  /// ```dart
  /// final stringIntMapType = ResolvableType.forClass(Map<String, int>);
  /// final intStringMapType = ResolvableType.forClass(Map<int, String>);
  /// final listType = ResolvableType.forClass(List<String>);
  /// 
  /// final stringKeyType = stringIntMapType.getKeyType();
  /// print(stringKeyType.resolve()?.getType()); // String
  /// 
  /// final intKeyType = intStringMapType.getKeyType();
  /// print(intKeyType.resolve()?.getType()); // int
  /// 
  /// final noKeyType = listType.getKeyType();
  /// print(noKeyType == ResolvableType.NONE); // true
  /// 
  /// // Useful for Map processing
  /// void processMapType(ResolvableType type) {
  ///   final keyType = type.getKeyType();
  ///   if (keyType != ResolvableType.NONE) {
  ///     final valueType = type.getGeneric([1]); // Second generic parameter
  ///     print("Map with keys: ${keyType.resolve()?.getType()}");
  ///     print("Map with values: ${valueType.resolve()?.getType()}");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType getKeyType() {
    if (this == NONE) return NONE;
    
    final resolved = resolve();
    if (resolved != null) {
      final clazz = Class.forType(resolved.getType());
      if (clazz.isAssignableTo(Class.forType(Map))) {
        final generics = getGenerics();
        if (generics.isNotEmpty) {
          return generics[0];
        }
      }
      
      final keyClass = resolved.keyType();
      if (keyClass != null) {
        return forType(keyClass.getType(), this);
      }
    }
    
    return NONE;
  }

  /// {@template resolvable_type_as_collection}
  /// Returns this type as a resolvable Iterable type.
  /// 
  /// This convenience method attempts to view this ResolvableType as an
  /// Iterable. If this type implements or extends Iterable, it returns
  /// the appropriate ResolvableType. Otherwise, it returns ResolvableType.NONE.
  /// 
  /// Returns:
  /// - ResolvableType representing this type as an Iterable
  /// - ResolvableType.NONE if this type is not iterable
  /// 
  /// Example:
  /// ```dart
  /// final listType = ResolvableType.forClass(List<String>);
  /// final setType = ResolvableType.forClass(Set<int>);
  /// final stringType = ResolvableType.forClass(String);
  /// 
  /// final listAsCollection = listType.asCollection();
  /// print(listAsCollection != ResolvableType.NONE); // true
  /// 
  /// final setAsCollection = setType.asCollection();
  /// print(setAsCollection != ResolvableType.NONE); // true
  /// 
  /// final stringAsCollection = stringType.asCollection();
  /// print(stringAsCollection == ResolvableType.NONE); // true
  /// 
  /// // Useful for generic collection processing
  /// void processIfIterable(ResolvableType type) {
  ///   final asCollection = type.asCollection();
  ///   if (asCollection != ResolvableType.NONE) {
  ///     print("Can iterate over this type");
  ///     // Process as iterable
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType asCollection() => as(Iterable);

  /// {@template resolvable_type_as_map}
  /// Returns this type as a resolvable Map type.
  /// 
  /// This convenience method attempts to view this ResolvableType as a Map.
  /// If this type implements or extends Map, it returns the appropriate
  /// ResolvableType. Otherwise, it returns ResolvableType.NONE.
  /// 
  /// Returns:
  /// - ResolvableType representing this type as a Map
  /// - ResolvableType.NONE if this type is not a Map
  /// 
  /// Example:
  /// ```dart
  /// final mapType = ResolvableType.forClass(Map<String, int>);
  /// final listType = ResolvableType.forClass(List<String>);
  /// 
  /// final mapAsMap = mapType.asMap();
  /// print(mapAsMap != ResolvableType.NONE); // true
  /// 
  /// final listAsMap = listType.asMap();
  /// print(listAsMap == ResolvableType.NONE); // true
  /// 
  /// // Useful for Map-specific processing
  /// void processIfMap(ResolvableType type) {
  ///   final asMap = type.asMap();
  ///   if (asMap != ResolvableType.NONE) {
  ///     final keyType = asMap.getKeyType();
  ///     final valueType = asMap.getGeneric([1]);
  ///     print("Map with keys: ${keyType.resolve()?.getType()}");
  ///     print("Map with values: ${valueType.resolve()?.getType()}");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType asMap() => as(Map);

  /// {@template resolvable_type_as}
  /// Returns this type as a ResolvableType of the specified target type.
  /// 
  /// This method attempts to view this ResolvableType as an instance of the
  /// specified target type. It checks inheritance hierarchies and interface
  /// implementations to determine if this type can be viewed as the target type.
  /// 
  /// Parameters:
  /// - [type]: The target Type to view this ResolvableType as
  /// 
  /// Returns:
  /// - ResolvableType representing this type as the target type
  /// - ResolvableType.NONE if this type cannot be viewed as the target type
  /// 
  /// Example:
  /// ```dart
  /// final listType = ResolvableType.forClass(List<String>);
  /// final stringType = ResolvableType.forClass(String);
  /// 
  /// final listAsIterable = listType.as(Iterable);
  /// print(listAsIterable != ResolvableType.NONE); // true - List implements Iterable
  /// 
  /// final listAsObject = listType.as(Object);
  /// print(listAsObject != ResolvableType.NONE); // true - List extends Object
  /// 
  /// final stringAsIterable = stringType.as(Iterable);
  /// print(stringAsIterable == ResolvableType.NONE); // true - String is not Iterable
  /// 
  /// // Useful for type casting and validation
  /// T? castIfPossible<T>(ResolvableType type, Object instance) {
  ///   final asTargetType = type.as(T);
  ///   if (asTargetType != ResolvableType.NONE && asTargetType.isInstance(instance)) {
  ///     return instance as T;
  ///   }
  ///   return null;
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType as(Type type) {
    if (this == NONE) return NONE;
    
    final resolved = resolve();
    if (resolved == null) return NONE;
    
    if (resolved.getType() == type) {
      return this;
    }

    // Check if this type is assignable to the target type
    final targetClass = Class.forType(type);
    if (targetClass.isAssignableFrom(resolved)) {
      return this; // Return current type, not new type for target
    }

    // Check interfaces
    for (final interfaceType in getInterfaces()) {
      final interfaceAsType = interfaceType.as(type);
      if (interfaceAsType != NONE) {
        return interfaceAsType;
      }
    }

    return getSuperType().as(type);
  }

  /// {@template resolvable_type_get_super_type}
  /// Returns a ResolvableType representing the direct supertype of this type.
  /// 
  /// This method returns the immediate parent class of this type in the
  /// inheritance hierarchy. For Object or interface types, this may return
  /// ResolvableType.NONE.
  /// 
  /// Returns:
  /// - ResolvableType representing the direct supertype
  /// - ResolvableType.NONE if no supertype exists
  /// 
  /// Example:
  /// ```dart
  /// final stringType = ResolvableType.forClass(String);
  /// final listType = ResolvableType.forClass(List<int>);
  /// final objectType = ResolvableType.forClass(Object);
  /// 
  /// final stringSuperType = stringType.getSuperType();
  /// print(stringSuperType.resolve()?.getType()); // Object
  /// 
  /// final listSuperType = listType.getSuperType();
  /// print(listSuperType.resolve()?.getType()); // Object (in Dart)
  /// 
  /// final objectSuperType = objectType.getSuperType();
  /// print(objectSuperType == ResolvableType.NONE); // true
  /// 
  /// // Useful for inheritance traversal
  /// void printInheritanceChain(ResolvableType type) {
  ///   ResolvableType current = type;
  ///   while (current != ResolvableType.NONE) {
  ///     print(current.resolve()?.getType());
  ///     current = current.getSuperType();
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType getSuperType() {
    final resolved = resolve();
    if (resolved == null) return NONE;

    try {
      final superClass = resolved.getSuperClass();
      if (superClass == null) return NONE;

      ResolvableType? superType = _superType;
      if (superType == null) {
        superType = forType(superClass.getType(), this);
        _superType = superType;
      }
      return superType;
    } catch (e) {
      return NONE;
    }
  }

  /// {@template resolvable_type_get_interfaces}
  /// Returns an array of ResolvableTypes representing the direct interfaces implemented by this type.
  /// 
  /// This method returns all interfaces that this type directly implements,
  /// not including inherited interfaces from supertypes.
  /// 
  /// Returns:
  /// - List of ResolvableType instances representing implemented interfaces
  /// - Empty list if no interfaces are implemented
  /// 
  /// Example:
  /// ```dart
  /// // Assuming a class that implements multiple interfaces
  /// class MyList<T> implements List<T>, Comparable<MyList<T>> {
  ///   // Implementation
  /// }
  /// 
  /// final myListType = ResolvableType.forClass(MyList<String>);
  /// final interfaces = myListType.getInterfaces();
  /// 
  /// for (final interface in interfaces) {
  ///   print(interface.resolve()?.getType());
  /// }
  /// // Output: List<String>, Comparable<MyList<String>>
  /// 
  /// // Useful for interface analysis
  /// bool implementsInterface(ResolvableType type, Type interfaceType) {
  ///   final interfaces = type.getInterfaces();
  ///   return interfaces.any((iface) => 
  ///     iface.resolve()?.getType() == interfaceType ||
  ///     iface.as(interfaceType) != ResolvableType.NONE
  ///   );
  /// }
  /// ```
  /// {@endtemplate}
  List<ResolvableType> getInterfaces() {
    final resolved = resolve();
    if (resolved == null) return _EMPTY_TYPES_ARRAY;

    List<ResolvableType>? interfaces = _interfaces;
    if (interfaces == null) {
      final interfaceClasses = resolved.getAllInterfaces();
      if (interfaceClasses.isNotEmpty) {
        interfaces = interfaceClasses.map((ifc) => forType(ifc.getType(), this)).toList();
      } else {
        interfaces = _EMPTY_TYPES_ARRAY;
      }
      _interfaces = interfaces;
    }
    return interfaces;
  }

  /// {@template resolvable_type_has_generics}
  /// Returns true if this type contains generic parameters.
  /// 
  /// This method checks whether this ResolvableType has any generic type
  /// parameters, such as the T in `List<T>` or the K,V in `Map<K,V>`.
  /// 
  /// Returns:
  /// - true if this type has generic parameters
  /// - false if this type has no generics
  /// 
  /// Example:
  /// ```dart
  /// final stringType = ResolvableType.forClass(String);
  /// final listType = ResolvableType.forClass(List<String>);
  /// final mapType = ResolvableType.forClass(Map<String, int>);
  /// final rawListType = ResolvableType.forClass(List); // Raw type
  /// 
  /// print(stringType.hasGenerics()); // false
  /// print(listType.hasGenerics()); // true
  /// print(mapType.hasGenerics()); // true
  /// print(rawListType.hasGenerics()); // false (raw type)
  /// 
  /// // Useful for generic type processing
  /// void processType(ResolvableType type) {
  ///   if (type.hasGenerics()) {
  ///     print("Generic type with ${type.getGenerics().length} parameters");
  ///     for (int i = 0; i < type.getGenerics().length; i++) {
  ///       final generic = type.getGeneric([i]);
  ///       print("  Parameter $i: ${generic.resolve()?.getType()}");
  ///     }
  ///   } else {
  ///     print("Non-generic type: ${type.resolve()?.getType()}");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  bool hasGenerics() => getGenerics().isNotEmpty;

  /// {@template resolvable_type_has_resolvable_generics}
  /// Returns true if this type contains at least one generic type that can be resolved.
  /// 
  /// This method checks whether this ResolvableType has generic parameters
  /// that can be resolved to concrete types (not type variables or dynamic types).
  /// 
  /// Returns:
  /// - true if this type has at least one resolvable generic parameter
  /// - false if all generics are unresolvable or no generics exist
  /// 
  /// Example:
  /// ```dart
  /// final concreteListType = ResolvableType.forClass(List<String>);
  /// final genericListType = ResolvableType.forClass(List); // List<T> where T is unresolved
  /// 
  /// print(concreteListType.hasResolvableGenerics()); // true - String is resolvable
  /// print(genericListType.hasResolvableGenerics()); // false - T is unresolvable
  /// 
  /// // Useful for determining if generic instantiation is possible
  /// bool canInstantiateGenericType(ResolvableType type) {
  ///   return type.hasResolvableGenerics() || !type.hasGenerics();
  /// }
  /// ```
  /// {@endtemplate}
  bool hasResolvableGenerics() {
    if (this == NONE) return false;
    
    final generics = getGenerics();
    for (final generic in generics) {
      if (!generic._isUnresolvableTypeVariable() && !generic._isDynamicType()) {
        return true;
      }
    }
    return false;
  }

  /// {@template resolvable_type_has_unresolvable_generics}
  /// Determines whether the underlying type has any unresolvable generics.
  /// 
  /// This method performs a deep check to determine if this type or any of
  /// its nested generic parameters contain unresolvable type variables or
  /// dynamic types that cannot be resolved to concrete classes.
  /// 
  /// Returns:
  /// - true if any generic parameters are unresolvable
  /// - false if all generics can be resolved or no generics exist
  /// 
  /// Example:
  /// ```dart
  /// final concreteType = ResolvableType.forClass(List<String>);
  /// final partiallyGenericType = ResolvableType.forClass(Map<String, dynamic>);
  /// 
  /// print(concreteType.hasUnresolvableGenerics()); // false
  /// print(partiallyGenericType.hasUnresolvableGenerics()); // true - dynamic is unresolvable
  /// 
  /// // Useful for validation before type operations
  /// bool isFullyResolvable(ResolvableType type) {
  ///   return !type.hasUnresolvableGenerics();
  /// }
  /// ```
  /// {@endtemplate}
  bool hasUnresolvableGenerics() {
    if (this == NONE) return false;
    return _hasUnresolvableGenerics(null);
  }

  bool _hasUnresolvableGenerics(Set<Type>? alreadySeen) {
    bool? unresolvableGenerics = _unresolvableGenerics;
    if (unresolvableGenerics == null) {
      unresolvableGenerics = _determineUnresolvableGenerics(alreadySeen);
      _unresolvableGenerics = unresolvableGenerics;
    }
    return unresolvableGenerics;
  }

  bool _determineUnresolvableGenerics(Set<Type>? alreadySeen) {
    if (alreadySeen != null && alreadySeen.contains(_type)) {
      return false;
    }

    final generics = getGenerics();
    for (final generic in generics) {
      if (generic._isUnresolvableTypeVariable() || 
          generic._isDynamicType() ||
          generic._hasUnresolvableGenerics(_currentTypeSeen(alreadySeen))) {
        return true;
      }
    }

    final resolved = resolve();
    if (resolved != null) {
      try {
        final interfaces = resolved.getAllInterfaces();
        for (final ifc in interfaces) {
          final declaration = TypeDiscovery.findByQualifiedName(ifc.getQualifiedName());
          if (declaration != null && declaration.getTypeArguments().isNotEmpty) {
            return true;
          }
        }
      } catch (e) {
        // Ignore
      }
      
      final superClass = resolved.getSuperClass();
      if (superClass != null && superClass.getType() != Object) {
        return getSuperType()._hasUnresolvableGenerics(_currentTypeSeen(alreadySeen));
      }
    }
    return false;
  }

  Set<Type> _currentTypeSeen(Set<Type>? alreadySeen) {
    alreadySeen ??= <Type>{};
    alreadySeen.add(_type);
    return alreadySeen;
  }

  bool _isUnresolvableTypeVariable() {
    // In Dart, we don't have explicit TypeVariable, but we can check for unresolved types
    return _type == dynamic || _type.toString() == 'Never';
  }

  bool _isDynamicType() {
    // In Dart, dynamic is our equivalent of wildcard without bounds
    return _type == dynamic;
  }

  /// {@template resolvable_type_get_nested}
  /// Returns a ResolvableType for the specified nesting level.
  /// 
  /// This method navigates through nested generic types or array component
  /// types to reach a specific nesting level. It's useful for working with
  /// complex nested generic structures.
  /// 
  /// Parameters:
  /// - [nestingLevel]: The target nesting level (1-based)
  /// - [typeIndexesPerLevel]: Optional map specifying which generic parameter to follow at each level
  /// 
  /// Returns:
  /// - ResolvableType at the specified nesting level
  /// - ResolvableType.NONE if the nesting level cannot be reached
  /// 
  /// Example:
  /// ```dart
  /// // For List<List<String>>
  /// final nestedListType = ResolvableType.forClass(List<List<String>>);
  /// 
  /// final level1 = nestedListType.getNested(1); // List<List<String>>
  /// final level2 = nestedListType.getNested(2); // List<String>
  /// final level3 = nestedListType.getNested(3); // String
  /// 
  /// print(level1.resolve()?.getType()); // List<List<String>>
  /// print(level2.resolve()?.getType()); // List<String>
  /// print(level3.resolve()?.getType()); // String
  /// 
  /// // For Map<String, List<Integer>>
  /// final complexMapType = ResolvableType.forClass(Map<String, List<int>>);
  /// final valueType = complexMapType.getNested(2, {2: 1}); // Navigate to List<int> (index 1 at level 2)
  /// final elementType = complexMapType.getNested(3, {2: 1}); // Navigate to int
  /// ```
  /// {@endtemplate}
  ResolvableType getNested(int nestingLevel, [Map<int, int>? typeIndexesPerLevel]) {
    ResolvableType result = this;
    for (int i = 2; i <= nestingLevel; i++) {
      if (result.isArray()) {
        result = result.getComponentType();
      } else {
        // Handle derived types
        while (result != NONE && !result.hasGenerics()) {
          result = result.getSuperType();
        }
        int? index = typeIndexesPerLevel?[i];
        index ??= result.getGenerics().length - 1;
        result = result.getGeneric([index]);
      }
    }
    return result;
  }

  /// {@template resolvable_type_get_generic}
  /// Returns a ResolvableType representing the generic parameter for the given indexes.
  /// 
  /// This method retrieves specific generic type parameters from this ResolvableType.
  /// For simple cases, it returns the first generic parameter. For complex nested
  /// generics, it can navigate through multiple levels using the indexes array.
  /// 
  /// Parameters:
  /// - [indexes]: Optional list of indexes to navigate nested generics. If null or empty, returns the first generic parameter.
  /// 
  /// Returns:
  /// - ResolvableType representing the specified generic parameter
  /// - ResolvableType.NONE if the indexes are invalid or no generics exist
  /// 
  /// Example:
  /// ```dart
  /// final listType = ResolvableType.forClass(List<String>);
  /// final mapType = ResolvableType.forClass(Map<String, int>);
  /// final nestedType = ResolvableType.forClass(Map<String, List<int>>);
  /// 
  /// // Simple generic access
  /// final listGeneric = listType.getGeneric(); // String
  /// print(listGeneric.resolve()?.getType()); // String
  /// 
  /// // Multiple generics
  /// final mapKey = mapType.getGeneric([0]); // String (first parameter)
  /// final mapValue = mapType.getGeneric([1]); // int (second parameter)
  /// print(mapKey.resolve()?.getType()); // String
  /// print(mapValue.resolve()?.getType()); // int
  /// 
  /// // Nested generics
  /// final nestedValue = nestedType.getGeneric([1]); // List<int>
  /// final nestedElement = nestedValue.getGeneric([0]); // int
  /// print(nestedValue.resolve()?.getType()); // List<int>
  /// print(nestedElement.resolve()?.getType()); // int
  /// 
  /// // Invalid access
  /// final invalid = listType.getGeneric([5]); // ResolvableType.NONE
  /// print(invalid == ResolvableType.NONE); // true
  /// ```
  /// {@endtemplate}
  ResolvableType getGeneric([List<int>? indexes]) {
    final generics = getGenerics();
    if (indexes == null || indexes.isEmpty) {
      return generics.isEmpty ? NONE : generics[0];
    }
    
    ResolvableType generic = this;
    for (final index in indexes) {
      final currentGenerics = generic.getGenerics();
      if (index < 0 || index >= currentGenerics.length) {
        return NONE;
      }
      generic = currentGenerics[index];
    }
    return generic;
  }

  /// {@template resolvable_type_get_generics}
  /// Returns an array of ResolvableTypes representing the generic parameters of this type.
  /// 
  /// This method returns all generic type parameters for this ResolvableType.
  /// For example, for `Map<String, int>`, this would return [ResolvableType(String), ResolvableType(int)].
  /// 
  /// Returns:
  /// - List of ResolvableType instances representing all generic parameters
  /// - Empty list if this type has no generic parameters
  /// 
  /// Example:
  /// ```dart
  /// final stringType = ResolvableType.forClass(String);
  /// final listType = ResolvableType.forClass(List<String>);
  /// final mapType = ResolvableType.forClass(Map<String, int>);
  /// 
  /// final stringGenerics = stringType.getGenerics();
  /// print(stringGenerics.length); // 0
  /// 
  /// final listGenerics = listType.getGenerics();
  /// print(listGenerics.length); // 1
  /// print(listGenerics[0].resolve()?.getType()); // String
  /// 
  /// final mapGenerics = mapType.getGenerics();
  /// print(mapGenerics.length); // 2
  /// print(mapGenerics[0].resolve()?.getType()); // String
  /// print(mapGenerics[1].resolve()?.getType()); // int
  /// 
  /// // Iterate through all generics
  /// void printGenerics(ResolvableType type) {
  ///   final generics = type.getGenerics();
  ///   for (int i = 0; i < generics.length; i++) {
  ///     print("Generic $i: ${generics[i].resolve()?.getType()}");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  List<ResolvableType> getGenerics() {
    if (this == NONE) return _EMPTY_TYPES_ARRAY;
    
    List<ResolvableType>? generics = _generics;
    if (generics == null) {
      final resolved = resolve();
      if (resolved != null) {
        final declaration = TypeDiscovery.findByQualifiedName(resolved.getQualifiedName());
        if (declaration != null) {
          final typeArgs = declaration.getTypeArguments();
          if (typeArgs.isNotEmpty) {
            generics = typeArgs.map((arg) => forType(arg.getType(), this)).toList();
          } else {
            generics = _EMPTY_TYPES_ARRAY;
          }
        } else {
          generics = _EMPTY_TYPES_ARRAY;
        }
      } else {
        generics = resolveType().getGenerics();
      }
      _generics = generics;
    }
    return generics;
  }

  /// {@template resolvable_type_resolve_generics}
  /// Convenience method that resolves all generic parameters to Class instances.
  /// 
  /// This method gets all generic parameters and resolves each one to a Class,
  /// returning a list of Class instances. Unresolvable generics will be null
  /// in the returned list.
  /// 
  /// Returns:
  /// - List of Class instances representing resolved generic parameters
  /// - List may contain null values for unresolvable generics
  /// 
  /// Example:
  /// ```dart
  /// final mapType = ResolvableType.forClass(Map<String, int>);
  /// final resolvedGenerics = mapType.resolveGenerics();
  /// 
  /// print(resolvedGenerics.length); // 2
  /// print(resolvedGenerics[0]?.getType()); // String
  /// print(resolvedGenerics[1]?.getType()); // int
  /// 
  /// // Handle unresolvable generics
  /// final partialType = ResolvableType.forClass(Map<String, dynamic>);
  /// final partialResolved = partialType.resolveGenerics();
  /// print(partialResolved[0]?.getType()); // String
  /// print(partialResolved[1]); // null (dynamic cannot be resolved)
  /// ```
  /// {@endtemplate}
  List<Class?> resolveGenerics() {
    final generics = getGenerics();
    final resolvedGenerics = <Class?>[];
    for (final generic in generics) {
      resolvedGenerics.add(generic.resolve());
    }
    return resolvedGenerics;
  }

  /// {@template resolvable_type_resolve_generics_with_fallback}
  /// Convenience method that resolves generic parameters with a fallback for unresolvable types.
  /// 
  /// This method gets all generic parameters and resolves each one to a Class,
  /// using the provided fallback Class for any unresolvable generics.
  /// 
  /// Parameters:
  /// - [fallback]: The Class to use when a generic parameter cannot be resolved
  /// 
  /// Returns:
  /// - List of Class instances with no null values (fallback used for unresolvable generics)
  /// 
  /// Example:
  /// ```dart
  /// final mapType = ResolvableType.forClass(Map<String, dynamic>);
  /// final objectFallback = Class.forType(Object);
  /// final resolvedGenerics = mapType.resolveGenericsWithFallback(objectFallback);
  /// 
  /// print(resolvedGenerics.length); // 2
  /// print(resolvedGenerics[0].getType()); // String
  /// print(resolvedGenerics[1].getType()); // Object (fallback for dynamic)
  /// 
  /// // Useful for safe generic instantiation
  /// List<Class> getSafeGenerics(ResolvableType type) {
  ///   final objectClass = Class.forType(Object);
  ///   return type.resolveGenericsWithFallback(objectClass);
  /// }
  /// ```
  /// {@endtemplate}
  List<Class> resolveGenericsWithFallback(Class fallback) {
    final generics = getGenerics();
    final resolvedGenerics = <Class>[];
    for (final generic in generics) {
      final resolved = generic.resolve(fallback);
      if(resolved != null) {
        resolvedGenerics.add(resolved);
      }
    }
    return resolvedGenerics;
  }

  /// {@template resolvable_type_resolve_generic}
  /// Convenience method that resolves a specific generic parameter to a Class.
  /// 
  /// This method gets a specific generic parameter using the provided indexes
  /// and resolves it to a Class instance.
  /// 
  /// Parameters:
  /// - [indexes]: Optional list of indexes to navigate nested generics
  /// 
  /// Returns:
  /// - Class instance representing the resolved generic parameter
  /// - null if the generic parameter cannot be resolved or doesn't exist
  /// 
  /// Example:
  /// ```dart
  /// final mapType = ResolvableType.forClass(Map<String, List<int>>);
  /// 
  /// final keyClass = mapType.resolveGeneric([0]); // String
  /// final valueClass = mapType.resolveGeneric([1]); // List<int>
  /// 
  /// print(keyClass?.getType()); // String
  /// print(valueClass?.getType()); // List<int>
  /// 
  /// // For nested access, you'd need to chain calls
  /// final valueType = mapType.getGeneric([1]); // ResolvableType for List<int>
  /// final elementClass = valueType.resolveGeneric([0]); // int
  /// print(elementClass?.getType()); // int
  /// ```
  /// {@endtemplate}
  Class? resolveGeneric([List<int>? indexes]) {
    return getGeneric(indexes).resolve();
  }

  /// {@template resolvable_type_resolve}
  /// Resolves this ResolvableType to a Class, returning null if the type cannot be resolved.
  /// 
  /// This is the primary method for converting a ResolvableType to a concrete Class
  /// instance that can be used for reflection operations, instantiation, and other
  /// runtime type operations.
  /// 
  /// Parameters:
  /// - [fallback]: Optional Class to return if resolution fails
  /// 
  /// Returns:
  /// - Class instance representing this ResolvableType
  /// - The fallback Class if provided and resolution fails
  /// - null if resolution fails and no fallback is provided
  /// 
  /// Example:
  /// ```dart
  /// final stringType = ResolvableType.forClass(String);
  /// final listType = ResolvableType.forClass(List<int>);
  /// final unknownType = ResolvableType.NONE;
  /// 
  /// final stringClass = stringType.resolve();
  /// print(stringClass?.getType()); // String
  /// 
  /// final listClass = listType.resolve();
  /// print(listClass?.getType()); // List<int>
  /// 
  /// final unknownClass = unknownType.resolve();
  /// print(unknownClass); // null
  /// 
  /// // With fallback
  /// final objectFallback = Class.forType(Object);
  /// final unknownWithFallback = unknownType.resolve(objectFallback);
  /// print(unknownWithFallback?.getType()); // Object
  /// 
  /// // Useful for safe operations
  /// void processType(ResolvableType type) {
  ///   final clazz = type.resolve();
  ///   if (clazz != null) {
  ///     print("Processing ${clazz.getType()}");
  ///     // Perform operations with the resolved class
  ///   } else {
  ///     print("Cannot resolve type");
  ///   }
  /// }
  /// ```
  /// {@endtemplate}
  Class? resolve([Class? fallback]) {
    if (_resolved != null) return _resolved;
    
    final resolved = _resolveClass();
    _resolved = resolved;
    return resolved ?? fallback;
  }

  Class? _resolveClass() {
    if (_type == _EmptyType._instance) {
      return null;
    }

    // Try to find via type discovery
    final declaration = TypeDiscovery.findByType(_type);
    if (declaration != null) {
      return Class.declared(declaration, ProtectionDomain.system());
    }

    // Try to create directly
    try {
      return Class.forType(_type);
    } catch (e) {
      return null;
    }
  }

  /// {@template resolvable_type_resolve_type}
  /// Resolves this type by a single level, returning the resolved value or NONE.
  /// 
  /// This method attempts to resolve one level of type indirection, such as
  /// resolving type variables through their bounds or resolving types through
  /// type providers and variable resolvers.
  /// 
  /// Returns:
  /// - ResolvableType representing the resolved type
  /// - ResolvableType.NONE if resolution is not possible
  /// - this if no resolution is needed
  /// 
  /// Example:
  /// ```dart
  /// // For a type variable T with bounds
  /// final typeVariable = ResolvableType.forTypeVariable(someTypeVariable);
  /// final resolved = typeVariable.resolveType();
  /// // resolved might be the bound type or a more concrete type
  /// 
  /// // For array types with unresolved component types
  /// final arrayType = ResolvableType.forArrayComponent(someUnresolvedType);
  /// final resolvedArray = arrayType.resolveType();
  /// // resolvedArray has a resolved component type
  /// 
  /// // Useful for incremental type resolution
  /// ResolvableType fullyResolve(ResolvableType type) {
  ///   ResolvableType current = type;
  ///   ResolvableType resolved = current.resolveType();
  ///   while (resolved != current && resolved != ResolvableType.NONE) {
  ///     current = resolved;
  ///     resolved = current.resolveType();
  ///   }
  ///   return current;
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType resolveType() {
    if (this == NONE) return NONE;
    
    // Try to resolve the type through the type provider
    if (_typeProvider != null) {
      final providerType = _typeProvider.getType();
      if (providerType != null && providerType != _type) {
        return forType(providerType);
      }
    }
    
    // Try to resolve through variable resolver
    if (_variableResolver != null) {
      final resolved = _variableResolver.resolveVariable(_type);
      if (resolved != null && resolved != this) {
        return resolved;
      }
    }
    
    // Try to resolve generic bounds
    if (_isUnresolvableTypeVariable()) {
      // For type variables, try to get bounds
      final resolved = resolve();
      if (resolved != null) {
        return forType(resolved.getType());
      }
    }
    
    // For arrays, ensure component type is resolved
    if (isArray() && _componentType == null) {
      final componentType = _resolveComponentType();
      if (componentType != NONE) {
        return ResolvableType._(_type, _typeProvider, _variableResolver, componentType: componentType);
      }
    }
    
    return this;
  }

  ResolvableType _resolveComponentType() {
    final resolved = resolve();
    if (resolved != null) {
      final componentClass = resolved.componentType();
      if (componentClass != null) {
        return forType(componentClass.getType());
      }
    }
    return NONE;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResolvableType) return false;
    
    if (!_equalsType(other)) return false;
    
    if (_typeProvider != other._typeProvider &&
        (_typeProvider == null || other._typeProvider == null ||
         _typeProvider.getType() != other._typeProvider.getType())) {
      return false;
    }
    
    if (_variableResolver != other._variableResolver &&
        (_variableResolver == null || other._variableResolver == null ||
         _variableResolver.getSource() != other._variableResolver.getSource())) {
      return false;
    }
    
    return true;
  }

  /// Check for type-level equality with another ResolvableType
  bool _equalsType(ResolvableType otherType) {
    return _type == otherType._type && _componentType == otherType._componentType;
  }

  @override
  int get hashCode {
    if (_hash != null) return _hash;
    return _calculateHashCode();
  }

  int _calculateHashCode() {
    int hashCode = _type.hashCode;
    if (_componentType != null) {
      hashCode = 31 * hashCode + _componentType.hashCode;
    }
    if (_typeProvider != null) {
      hashCode = 31 * hashCode + (_typeProvider.getType()?.hashCode ?? 0);
    }
    if (_variableResolver != null) {
      hashCode = 31 * hashCode + _variableResolver.getSource().hashCode;
    }
    return hashCode;
  }

  /// {@template resolvable_type_as_variable_resolver}
  /// Adapts this ResolvableType to a VariableResolver for type variable resolution.
  /// 
  /// This method creates a VariableResolver that can be used to resolve type
  /// variables in the context of this ResolvableType. This is useful when
  /// working with generic types that need to resolve their type parameters.
  /// 
  /// Returns:
  /// - VariableResolver instance that can resolve type variables
  /// - null if this ResolvableType is NONE
  /// 
  /// Example:
  /// ```dart
  /// final listType = ResolvableType.forClass(List<String>);
  /// final resolver = listType.asVariableResolver();
  /// 
  /// // Use resolver to resolve type variables in generic contexts
  /// if (resolver != null) {
  ///   final resolved = resolver.resolveVariable(someTypeVariable);
  ///   print("Resolved type variable to: ${resolved?.resolve()?.getType()}");
  /// }
  /// 
  /// // Useful for creating type contexts
  /// VariableResolver? createTypeContext(ResolvableType contextType) {
  ///   return contextType.asVariableResolver();
  /// }
  /// ```
  /// {@endtemplate}
  VariableResolver? asVariableResolver() {
    if (this == NONE) return null;
    return _DefaultVariableResolver(this);
  }

  @override
  String toString() {
    if (isArray()) {
      return '${getComponentType()}[]';
    }
    if (_resolved == null) {
      return '?';
    }
    if (hasGenerics()) {
      final genericStrings = getGenerics().map((g) => g.toString()).join(', ');
      return '${_resolved!.getName()}<$genericStrings>';
    }
    return _resolved!.getName();
  }

  // ================================= FACTORY METHODS =================================

  /// {@macro resolvable_type_for_class_static}
  static ResolvableType forClass(Type type) {
    try {
      final classObj = Class.forType(type);
      return ResolvableType._forClass(classObj);
    } catch (e) {
      return ResolvableType._(type, null, null);
    }
  }

  /// {@template resolvable_type_for_raw_class}
  /// Returns a ResolvableType for the specified Class doing assignability checks against the raw class only.
  /// 
  /// This factory method creates a ResolvableType that ignores generic parameters
  /// when performing assignability checks. This is useful when you need to work
  /// with raw types and ignore generic type safety.
  /// 
  /// Parameters:
  /// - [clazz]: The Type to create a raw ResolvableType for
  /// 
  /// Returns:
  /// - ResolvableType that performs raw type assignability checking
  /// 
  /// Example:
  /// ```dart
  /// final rawListType = ResolvableType.forRawClass(List);
  /// final stringListType = ResolvableType.forClass(List<String>);
  /// final intListType = ResolvableType.forClass(List<int>);
  /// 
  /// // Raw type is assignable from any parameterized version
  /// print(rawListType.isAssignableFromResolvable(stringListType)); // true
  /// print(rawListType.isAssignableFromResolvable(intListType)); // true
  /// 
  /// // But parameterized types are not assignable from each other
  /// print(stringListType.isAssignableFromResolvable(intListType)); // false
  /// 
  /// // Useful for legacy code or when generic safety is not required
  /// ResolvableType createCompatibleType(Type rawType) {
  ///   return ResolvableType.forRawClass(rawType);
  /// }
  /// ```
  /// {@endtemplate}
  static ResolvableType forRawClass(Type clazz) {
    return _RawClassResolvableType(clazz);
  }

  /// {@macro resolvable_type_for_class_with_implementation}
  static ResolvableType forClassWithImplementation(Type baseType, Type implementationClass) {
    final asType = forType(implementationClass).as(baseType);
    return asType != NONE ? asType : forType(baseType);
  }

  /// {@macro resolvable_type_for_class_with_generics}
  static ResolvableType forClassWithGenerics(Type clazz, List<Type> generics) {
    final resolvableGenerics = generics.map((g) => forClass(g)).toList();
    return forClassWithResolvableGenerics(clazz, resolvableGenerics);
  }

  /// {@macro resolvable_type_for_class_with_resolvable_generics}
  static ResolvableType forClassWithResolvableGenerics(Type clazz, List<ResolvableType> generics) {
    return _GenericResolvableType(clazz, generics);
  }

  /// {@macro resolvable_type_for_instance}
  static ResolvableType forInstance(Object? instance) {
    if (instance == null) return NONE;
    return forClass(instance.runtimeType);
  }

  /// {@macro resolvable_type_for_field}
  static ResolvableType forField(FieldDeclaration field) {
    final typeProvider = _FieldTypeProvider(field);
    return forTypeWithProviderAndResolver(field.getType(), typeProvider, null);
  }

  /// {@macro resolvable_type_for_field_with_implementation}
  static ResolvableType forFieldWithImplementation(FieldDeclaration field, Type implementationClass) {
    final owner = forType(implementationClass);
    final ownerAsField = owner.as(field.getType());
    final resolver = ownerAsField.asVariableResolver();
    return forTypeWithProviderAndResolver(field.getType(), _FieldTypeProvider(field), resolver);
  }

  /// {@macro resolvable_type_for_field_with_resolvable_implementation}
  static ResolvableType forFieldWithResolvableImplementation(FieldDeclaration field, ResolvableType? implementationType) {
    final owner = implementationType ?? NONE;
    final ownerAsField = owner.as(field.getType());
    final resolver = ownerAsField.asVariableResolver();
    return forTypeWithProviderAndResolver(field.getType(), _FieldTypeProvider(field), resolver);
  }

  /// {@macro resolvable_type_for_constructor_parameter}
  static ResolvableType forConstructorParameter(ConstructorDeclaration constructor, int parameterIndex) {
    final params = constructor.getParameters();
    if (parameterIndex >= 0 && parameterIndex < params.length) {
      final param = params[parameterIndex];
      final typeProvider = _ParameterTypeProvider(param);
      return forTypeWithProviderAndResolver(param.getType(), typeProvider, null);
    }
    return NONE;
  }

  /// {@template resolvable_type_for_constructor_parameter_with_implementation}
  /// Creates a ResolvableType for a constructor parameter with implementation context.
  /// 
  /// This factory method creates a ResolvableType for a constructor parameter
  /// that considers a specific implementation class context. This is useful
  /// when the parameter type needs to be resolved in the context of a concrete
  /// implementation rather than the declaring class.
  /// 
  /// Parameters:
  /// - [constructor]: The ConstructorDeclaration containing the parameter
  /// - [parameterIndex]: The zero-based index of the parameter
  /// - [implementationClass]: The implementation class Type to provide context
  /// 
  /// Returns:
  /// - ResolvableType representing the parameter type in the implementation context
  /// - ResolvableType.NONE if the parameter index is invalid
  /// 
  /// Example:
  /// ```dart
  /// abstract class Repository<T> {
  ///   Repository(T initialValue);
  /// }
  /// 
  /// class UserRepository extends Repository<User> {
  ///   UserRepository(User user) : super(user);
  /// }
  /// 
  /// final constructor = getConstructorDeclaration(Repository);
  /// 
  /// // Without implementation context - returns T (type variable)
  /// final genericParamType = ResolvableType.forConstructorParameter(constructor, 0);
  /// 
  /// // With implementation context - returns User
  /// final concreteParamType = ResolvableType.forConstructorParameterWithImplementation(
  ///   constructor, 
  ///   0,
  ///   UserRepository
  /// );
  /// 
  /// print(concreteParamType.resolve()?.getType()); // User
  /// ```
  /// {@endtemplate}
  static ResolvableType forConstructorParameterWithImplementation(ConstructorDeclaration constructor, int parameterIndex, Type implementationClass) {
    final params = constructor.getParameters();
    if (parameterIndex >= 0 && parameterIndex < params.length) {
      final param = params[parameterIndex];
      final owner = forType(implementationClass);
      final resolver = owner.asVariableResolver();
      return forTypeWithProviderAndResolver(param.getType(), _ParameterTypeProvider(param), resolver);
    }
    return NONE;
  }

  /// {@template resolvable_type_for_method_return_type}
  /// Creates a ResolvableType for a method's return type.
  /// 
  /// This factory method creates a ResolvableType representing the return type
  /// of a method declaration. This is useful for reflection-based operations
  /// where you need to work with method return types.
  /// 
  /// Parameters:
  /// - [method]: The MethodDeclaration to get the return type from
  /// 
  /// Returns:
  /// - ResolvableType representing the method's return type
  /// 
  /// Example:
  /// ```dart
  /// class UserService {
  ///   List<User> getUsers() { ... }
  ///   User? findUser(String id) { ... }
  ///   void deleteUser(String id) { ... }
  /// }
  /// 
  /// final getUsersMethod = getMethodDeclaration(UserService, 'getUsers');
  /// final findUserMethod = getMethodDeclaration(UserService, 'findUser');
  /// final deleteUserMethod = getMethodDeclaration(UserService, 'deleteUser');
  /// 
  /// final getUsersReturnType = ResolvableType.forMethodReturnType(getUsersMethod);
  /// final findUserReturnType = ResolvableType.forMethodReturnType(findUserMethod);
  /// final deleteUserReturnType = ResolvableType.forMethodReturnType(deleteUserMethod);
  /// 
  /// print(getUsersReturnType.resolve()?.getType()); // List<User>
  /// print(getUsersReturnType.hasGenerics()); // true
  /// print(getUsersReturnType.getGeneric().resolve()?.getType()); // User
  /// 
  /// print(findUserReturnType.resolve()?.getType()); // User?
  /// print(deleteUserReturnType.resolve()?.getType()); // void
  /// ```
  /// {@endtemplate}
  static ResolvableType forMethodReturnType(MethodDeclaration method) {
    final typeProvider = _MethodReturnTypeProvider(method);
    return forTypeWithProviderAndResolver(method.getReturnType().getType(), typeProvider, null);
  }

  /// {@template resolvable_type_for_method_return_type_with_implementation}
  /// Creates a ResolvableType for a method's return type with implementation context.
  /// 
  /// This factory method creates a ResolvableType for a method's return type
  /// that considers a specific implementation class context. This is useful
  /// when the return type needs to be resolved in the context of a concrete
  /// implementation rather than the declaring class.
  /// 
  /// Parameters:
  /// - [method]: The MethodDeclaration to get the return type from
  /// - [implementationClass]: The implementation class Type to provide context
  /// 
  /// Returns:
  /// - ResolvableType representing the return type in the implementation context
  /// 
  /// Example:
  /// ```dart
  /// abstract class Repository<T> {
  ///   T findById(String id);
  ///   List<T> findAll();
  /// }
  /// 
  /// class UserRepository extends Repository<User> {
  ///   // findById returns User, findAll returns List<User>
  /// }
  /// 
  /// final findByIdMethod = getMethodDeclaration(Repository, 'findById');
  /// final findAllMethod = getMethodDeclaration(Repository, 'findAll');
  /// 
  /// // Without implementation context - returns T and List<T>
  /// final genericFindByIdType = ResolvableType.forMethodReturnType(findByIdMethod);
  /// final genericFindAllType = ResolvableType.forMethodReturnType(findAllMethod);
  /// 
  /// // With implementation context - returns User and List<User>
  /// final concreteFindByIdType = ResolvableType.forMethodReturnTypeWithImplementation(
  ///   findByIdMethod, 
  ///   UserRepository
  /// );
  /// final concreteFindAllType = ResolvableType.forMethodReturnTypeWithImplementation(
  ///   findAllMethod, 
  ///   UserRepository
  /// );
  /// 
  /// print(concreteFindByIdType.resolve()?.getType()); // User
  /// print(concreteFindAllType.resolve()?.getType()); // List<User>
  /// print(concreteFindAllType.getGeneric().resolve()?.getType()); // User
  /// ```
  /// {@endtemplate}
  static ResolvableType forMethodReturnTypeWithImplementation(MethodDeclaration method, Type implementationClass) {
    final owner = forType(implementationClass);
    final resolver = owner.asVariableResolver();
    return forTypeWithProviderAndResolver(method.getReturnType().getType(), _MethodReturnTypeProvider(method), resolver);
  }

  /// {@template resolvable_type_for_method_parameter}
  /// Creates a ResolvableType for a method parameter.
  /// 
  /// This factory method creates a ResolvableType representing the type of
  /// a specific parameter in a method declaration. This is useful for
  /// reflection-based operations and method analysis.
  /// 
  /// Parameters:
  /// - [method]: The MethodDeclaration containing the parameter
  /// - [parameterIndex]: The zero-based index of the parameter
  /// 
  /// Returns:
  /// - ResolvableType representing the parameter's type
  /// - ResolvableType.NONE if the parameter index is invalid
  /// 
  /// Example:
  /// ```dart
  /// class UserService {
  ///   User createUser(String name, int age, List<String> emails);
  ///   void updateUser(User user, Map<String, dynamic> updates);
  /// }
  /// 
  /// final createUserMethod = getMethodDeclaration(UserService, 'createUser');
  /// final updateUserMethod = getMethodDeclaration(UserService, 'updateUser');
  /// 
  /// final nameParamType = ResolvableType.forMethodParameter(createUserMethod, 0);
  /// final ageParamType = ResolvableType.forMethodParameter(createUserMethod, 1);
  /// final emailsParamType = ResolvableType.forMethodParameter(createUserMethod, 2);
  /// 
  /// print(nameParamType.resolve()?.getType()); // String
  /// print(ageParamType.resolve()?.getType()); // int
  /// print(emailsParamType.resolve()?.getType()); // List<String>
  /// print(emailsParamType.hasGenerics()); // true
  /// print(emailsParamType.getGeneric().resolve()?.getType()); // String
  /// 
  /// final userParamType = ResolvableType.forMethodParameter(updateUserMethod, 0);
  /// final updatesParamType = ResolvableType.forMethodParameter(updateUserMethod, 1);
  /// 
  /// print(userParamType.resolve()?.getType()); // User
  /// print(updatesParamType.resolve()?.getType()); // Map<String, dynamic>
  /// ```
  /// {@endtemplate}
  static ResolvableType forMethodParameter(MethodDeclaration method, int parameterIndex) {
    final params = method.getParameters();
    if (parameterIndex >= 0 && parameterIndex < params.length) {
      final param = params[parameterIndex];
      final typeProvider = _ParameterTypeProvider(param);
      return forTypeWithProviderAndResolver(param.getType(), typeProvider, null);
    }
    return NONE;
  }

  /// {@template resolvable_type_for_method_parameter_with_implementation}
  /// Creates a ResolvableType for a method parameter with implementation context.
  /// 
  /// This factory method creates a ResolvableType for a method parameter
  /// that considers a specific implementation class context. This is useful
  /// when the parameter type needs to be resolved in the context of a concrete
  /// implementation rather than the declaring class.
  /// 
  /// Parameters:
  /// - [method]: The MethodDeclaration containing the parameter
  /// - [parameterIndex]: The zero-based index of the parameter
  /// - [implementationClass]: The implementation class Type to provide context
  /// 
  /// Returns:
  /// - ResolvableType representing the parameter type in the implementation context
  /// - ResolvableType.NONE if the parameter index is invalid
  /// 
  /// Example:
  /// ```dart
  /// abstract class Repository<T> {
  ///   void save(T entity);
  ///   List<T> findByExample(T example);
  /// }
  /// 
  /// class UserRepository extends Repository<User> {
  ///   // save parameter is User, findByExample parameter is User
  /// }
  /// 
  /// final saveMethod = getMethodDeclaration(Repository, 'save');
  /// final findByExampleMethod = getMethodDeclaration(Repository, 'findByExample');
  /// 
  /// // Without implementation context - returns T
  /// final genericSaveParamType = ResolvableType.forMethodParameter(saveMethod, 0);
  /// 
  /// // With implementation context - returns User
  /// final concreteSaveParamType = ResolvableType.forMethodParameterWithImplementation(
  ///   saveMethod, 
  ///   0,
  ///   UserRepository
  /// );
  /// 
  /// final concreteExampleParamType = ResolvableType.forMethodParameterWithImplementation(
  ///   findByExampleMethod, 
  ///   0,
  ///   UserRepository
  /// );
  /// 
  /// print(concreteSaveParamType.resolve()?.getType()); // User
  /// print(concreteExampleParamType.resolve()?.getType()); // User
  /// ```
  /// {@endtemplate}
  static ResolvableType forMethodParameterWithImplementation(
      MethodDeclaration method, int parameterIndex, Type implementationClass) {
    final params = method.getParameters();
    if (parameterIndex >= 0 && parameterIndex < params.length) {
      final param = params[parameterIndex];
      final owner = forType(implementationClass);
      final resolver = owner.asVariableResolver();
      return forTypeWithProviderAndResolver(param.getType(), _ParameterTypeProvider(param), resolver);
    }
    return NONE;
  }

  /// {@template resolvable_type_for_array_component}
  /// Returns a ResolvableType representing an array of the specified component type.
  /// 
  /// This factory method creates a ResolvableType that represents an array (List in Dart)
  /// with the specified component type. This is useful for programmatically creating
  /// array types when you know the element type.
  /// 
  /// Parameters:
  /// - [componentType]: The ResolvableType representing the array element type
  /// 
  /// Returns:
  /// - ResolvableType representing an array of the component type
  /// 
  /// Example:
  /// ```dart
  /// final stringType = ResolvableType.forClass(String);
  /// final userType = ResolvableType.forClass(User);
  /// 
  /// final stringArrayType = ResolvableType.forArrayComponent(stringType);
  /// final userArrayType = ResolvableType.forArrayComponent(userType);
  /// 
  /// print(stringArrayType.isArray()); // true
  /// print(stringArrayType.getComponentType().resolve()?.getType()); // String
  /// 
  /// print(userArrayType.isArray()); // true
  /// print(userArrayType.getComponentType().resolve()?.getType()); // User
  /// 
  /// // Useful for creating nested array types
  /// final stringArrayArrayType = ResolvableType.forArrayComponent(stringArrayType);
  /// print(stringArrayArrayType.getComponentType().isArray()); // true
  /// print(stringArrayArrayType.getComponentType().getComponentType().resolve()?.getType()); // String
  /// 
  /// // Useful for dynamic array type creation
  /// ResolvableType createArrayType(Type elementType) {
  ///   final elementResolvableType = ResolvableType.forClass(elementType);
  ///   return ResolvableType.forArrayComponent(elementResolvableType);
  /// }
  /// ```
  /// {@endtemplate}
  static ResolvableType forArrayComponent(ResolvableType componentType) {
    final arrayType = List; // Use List as array representation
    return ResolvableType._(arrayType, null, null, componentType: componentType);
  }

  /// {@template resolvable_type_for_type}
  /// Returns a ResolvableType for the specified Type with optional owner context.
  /// 
  /// This is the most general factory method for creating ResolvableType instances.
  /// It can optionally take an owner ResolvableType to provide context for
  /// type variable resolution.
  /// 
  /// Parameters:
  /// - [type]: The Type to create a ResolvableType for
  /// - [owner]: Optional ResolvableType to provide context for type resolution
  /// 
  /// Returns:
  /// - ResolvableType representing the specified type
  /// 
  /// Example:
  /// ```dart
  /// // Simple type creation
  /// final stringType = ResolvableType.forType(String);
  /// final listType = ResolvableType.forType(List<int>);
  /// 
  /// print(stringType.resolve()?.getType()); // String
  /// print(listType.resolve()?.getType()); // List<int>
  /// 
  /// // With owner context for type variable resolution
  /// final ownerType = ResolvableType.forClass(List<String>);
  /// final contextualType = ResolvableType.forType(String, ownerType);
  /// 
  /// // Useful for general type creation
  /// ResolvableType createType(Type type, [ResolvableType? context]) {
  ///   return ResolvableType.forType(type, context);
  /// }
  /// 
  /// // Batch type creation
  /// List<ResolvableType> createTypes(List<Type> types) {
  ///   return types.map((type) => ResolvableType.forType(type)).toList();
  /// }
  /// ```
  /// {@endtemplate}
  static ResolvableType forType(Type type, [ResolvableType? owner]) {
    VariableResolver? variableResolver;
    if (owner != null) {
      variableResolver = owner.asVariableResolver();
    }
    return forTypeWithVariableResolver(type, variableResolver);
  }

  /// {@template resolvable_type_for_type_with_variable_resolver}
  /// Returns a ResolvableType for the specified Type backed by a VariableResolver.
  /// 
  /// This factory method creates a ResolvableType with a specific VariableResolver
  /// for resolving type variables. This provides fine-grained control over how
  /// type variables are resolved in generic contexts.
  /// 
  /// Parameters:
  /// - [type]: The Type to create a ResolvableType for
  /// - [variableResolver]: Optional VariableResolver for type variable resolution
  /// 
  /// Returns:
  /// - ResolvableType with the specified VariableResolver
  /// 
  /// Example:
  /// ```dart
  /// // Create a custom variable resolver
  /// class CustomVariableResolver implements VariableResolver {
  ///   @override
  ///   Object getSource() => this;
  ///   
  ///   @override
  ///   ResolvableType? resolveVariable(Object variable) {
  ///     // Custom resolution logic
  ///     if (variable == someTypeVariable) {
  ///       return ResolvableType.forClass(String);
  ///     }
  ///     return null;
  ///   }
  /// }
  /// 
  /// final customResolver = CustomVariableResolver();
  /// final typeWithResolver = ResolvableType.forTypeWithVariableResolver(
  ///   someGenericType, 
  ///   customResolver
  /// );
  /// 
  /// // The type will use the custom resolver for type variable resolution
  /// ```
  /// {@endtemplate}
  static ResolvableType forTypeWithVariableResolver(Type type, VariableResolver? variableResolver) {
    return forTypeWithProviderAndResolver(type, null, variableResolver);
  }

  /// {@template resolvable_type_for_type_with_provider_and_resolver}
  /// Returns a ResolvableType with both TypeProvider and VariableResolver.
  /// 
  /// This is the most comprehensive factory method that allows specifying both
  /// a TypeProvider (for type information) and a VariableResolver (for type
  /// variable resolution). This provides maximum flexibility for complex
  /// type resolution scenarios.
  /// 
  /// Parameters:
  /// - [type]: The Type to create a ResolvableType for
  /// - [typeProvider]: Optional TypeProvider for additional type information
  /// - [variableResolver]: Optional VariableResolver for type variable resolution
  /// 
  /// Returns:
  /// - ResolvableType with the specified providers and resolvers
  /// 
  /// Example:
  /// ```dart
  /// // Create custom providers
  /// class CustomTypeProvider implements TypeProvider {
  ///   @override
  ///   Type? getType() => String; // Override the actual type
  ///   
  ///   @override
  ///   Object? getSource() => this;
  /// }
  /// 
  /// class CustomVariableResolver implements VariableResolver {
  ///   @override
  ///   Object getSource() => this;
  ///   
  ///   @override
  ///   ResolvableType? resolveVariable(Object variable) {
  ///     return ResolvableType.forClass(int);
  ///   }
  /// }
  /// 
  /// final provider = CustomTypeProvider();
  /// final resolver = CustomVariableResolver();
  /// 
  /// final complexType = ResolvableType.forTypeWithProviderAndResolver(
  ///   Object, // Base type
  ///   provider, // Will override to String
  ///   resolver  // Will resolve variables to int
  /// );
  /// 
  /// // This type will use both custom provider and resolver
  /// ```
  /// {@endtemplate}
  static ResolvableType forTypeWithProviderAndResolver(
      Type type, TypeProvider? typeProvider, VariableResolver? variableResolver) {
    if (type == _EmptyType._instance) {
      return NONE;
    }

    // For simple Class references, build the wrapper right away
    try {
      final classObj = Class.forType(type);
      // Use the classObj to create a more complete ResolvableType
      final result = ResolvableType._(type, typeProvider, variableResolver);
      result._resolved = classObj;
      return result;
    } catch (e) {
      // Continue with caching logic
    }

    // Check the cache
    final resultType = ResolvableType._(type, typeProvider, variableResolver);
    ResolvableType? cachedType = _cache[resultType];
    if (cachedType == null) {
      cachedType = ResolvableType._(type, typeProvider, variableResolver, hash: resultType.hashCode);
      _cache[cachedType] = cachedType;
    }
    return cachedType;
  }

  /// {@template resolvable_type_clear_cache}
  /// Clears the internal ResolvableType cache.
  /// 
  /// This method clears the internal cache used by ResolvableType to store
  /// previously created instances. This can be useful for memory management
  /// in long-running applications or when you need to ensure fresh type
  /// resolution.
  /// 
  /// Example:
  /// ```dart
  /// // Create some types (they get cached)
  /// final type1 = ResolvableType.forClass(String);
  /// final type2 = ResolvableType.forClass(List<int>);
  /// 
  /// // Clear the cache to free memory
  /// ResolvableType.clearCache();
  /// 
  /// // Subsequent type creation will not use cached instances
  /// final type3 = ResolvableType.forClass(String); // New instance, not cached
  /// 
  /// // Useful for memory management
  /// void cleanupTypeSystem() {
  ///   ResolvableType.clearCache();
  /// }
  /// ```
  /// {@endtemplate}
  static void clearCache() {
    _cache.clear();
  }
}

// ================================= SUPPORTING CLASSES =================================

/// {@template variable_resolver}
/// Strategy interface used to resolve type variables in generic contexts.
/// 
/// VariableResolver provides a mechanism for resolving type variables (like T, K, V)
/// to concrete types in generic type contexts. This is essential for proper type
/// resolution in generic classes and methods.
/// 
/// Implementations should provide:
/// - A source object that represents the context of resolution
/// - Logic to resolve specific type variables to concrete ResolvableType instances
/// 
/// Example Implementation:
/// ```dart
/// class GenericClassResolver implements VariableResolver {
///   final Map<Object, ResolvableType> _typeMapping;
///   final Object _source;
///   
///   GenericClassResolver(this._source, this._typeMapping);
///   
///   @override
///   Object getSource() => _source;
///   
///   @override
///   ResolvableType? resolveVariable(Object variable) {
///     return _typeMapping[variable];
///   }
/// }
/// 
/// // Usage
/// final resolver = GenericClassResolver(
///   myGenericClass,
///   {typeVariableT: ResolvableType.forClass(String)}
/// );
/// ```
/// {@endtemplate}
abstract class VariableResolver {
  /// {@template variable_resolver_get_source}
  /// Returns the source object that provides the context for type variable resolution.
  /// 
  /// The source object typically represents the generic class, method, or other
  /// construct that defines the type variables being resolved.
  /// 
  /// Returns:
  /// - The source object providing resolution context
  /// 
  /// Example:
  /// ```dart
  /// class MyResolver implements VariableResolver {
  ///   final Class _sourceClass;
  ///   
  ///   MyResolver(this._sourceClass);
  ///   
  ///   @override
  ///   Object getSource() => _sourceClass;
  ///   
  ///   // ... other methods
  /// }
  /// ```
  /// {@endtemplate}
  Object getSource();
  
  /// {@template variable_resolver_resolve_variable}
  /// Resolves the specified type variable to a concrete ResolvableType.
  /// 
  /// This method takes a type variable (such as T, K, V in generic declarations)
  /// and returns the concrete ResolvableType that the variable should resolve to
  /// in the current context.
  /// 
  /// Parameters:
  /// - [variable]: The type variable to resolve
  /// 
  /// Returns:
  /// - ResolvableType representing the resolved concrete type
  /// - null if the variable cannot be resolved in this context
  /// 
  /// Example:
  /// ```dart
  /// @override
  /// ResolvableType? resolveVariable(Object variable) {
  ///   if (variable == typeVariableT) {
  ///     return ResolvableType.forClass(String);
  ///   } else if (variable == typeVariableK) {
  ///     return ResolvableType.forClass(int);
  ///   }
  ///   return null; // Cannot resolve this variable
  /// }
  /// ```
  /// {@endtemplate}
  ResolvableType? resolveVariable(Object variable);
}

class _DefaultVariableResolver implements VariableResolver {
  final ResolvableType source;

  _DefaultVariableResolver(this.source);

  @override
  ResolvableType? resolveVariable(Object variable) {
    // Try to resolve through the source's generics
    final generics = source.getGenerics();
    for (final generic in generics) {
      if (generic.getType() == variable) {
        return generic;
      }
    }
    return null;
  }

  @override
  Object getSource() => source;
}

/// {@template type_provider}
/// Interface providing access to Type information with optional source context.
/// 
/// TypeProvider abstracts the source of type information, allowing ResolvableType
/// to work with types that come from various sources like fields, method parameters,
/// return types, etc. This provides flexibility in how type information is obtained
/// and allows for lazy type resolution.
/// 
/// Example Implementation:
/// ```dart
/// class FieldTypeProvider implements TypeProvider {
///   final FieldDeclaration _field;
///   
///   FieldTypeProvider(this._field);
///   
///   @override
///   Type? getType() => _field.getType();
///   
///   @override
///   Object? getSource() => _field;
/// }
/// ```
/// {@endtemplate}
abstract class TypeProvider {
  /// {@template type_provider_get_type}
  /// Returns the Type provided by this TypeProvider.
  /// 
  /// This method returns the actual Type object that this provider represents.
  /// The Type may be obtained from various sources such as field declarations,
  /// method signatures, or other type-bearing constructs.
  /// 
  /// Returns:
  /// - The Type object provided by this provider
  /// - null if no type is available
  /// 
  /// Example:
  /// ```dart
  /// @override
  /// Type? getType() {
  ///   // Return the type from whatever source this provider represents
  ///   return _field.getType();
  /// }
  /// ```
  /// {@endtemplate}
  Type? getType();
  
  /// {@template type_provider_get_source}
  /// Returns the source object that provides the type information.
  /// 
  /// This method returns the underlying source object (such as a Field,
  /// Method, Parameter, etc.) that this TypeProvider is wrapping. This
  /// can be useful for debugging, logging, or when additional context
  /// about the type source is needed.
  /// 
  /// Returns:
  /// - The source object providing the type information
  /// - null if no source is available or known
  /// 
  /// Example:
  /// ```dart
  /// @override
  /// Object? getSource() => _field; // Return the field declaration
  /// ```
  /// {@endtemplate}
  Object? getSource() => null;
}

class _FieldTypeProvider implements TypeProvider {
  final FieldDeclaration field;

  _FieldTypeProvider(this.field);

  @override
  Type? getType() => field.getType();

  @override
  Object? getSource() => field;
}

class _ParameterTypeProvider implements TypeProvider {
  final ParameterDeclaration parameter;

  _ParameterTypeProvider(this.parameter);

  @override
  Type? getType() => parameter.getType();

  @override
  Object? getSource() => parameter;
}

class _MethodReturnTypeProvider implements TypeProvider {
  final MethodDeclaration method;

  _MethodReturnTypeProvider(this.method);

  @override
  Type? getType() => method.getReturnType().getType();

  @override
  Object? getSource() => method;
}

class _RawClassResolvableType extends ResolvableType {
  _RawClassResolvableType(Type type) : super._(type, null, null);

  @override
  List<ResolvableType> getGenerics() => [];

  @override
  bool isAssignableFromType(Type other) {
    final resolved = resolve();
    if (resolved == null) return false;
    
    final otherClass = Class.forType(other);
    return resolved.isAssignableFrom(otherClass);
  }

  @override
  bool isAssignableFromResolvable(ResolvableType other) {
    final otherClass = other.resolve();
    if (otherClass == null) return false;
    
    final resolved = resolve();
    return resolved?.isAssignableFrom(otherClass) ?? false;
  }
}

class _GenericResolvableType extends ResolvableType {
  final List<ResolvableType> _genericTypes;

  _GenericResolvableType(Type type, this._genericTypes) : super._(type, null, null);

  @override
  List<ResolvableType> getGenerics() => List.unmodifiable(_genericTypes);
}

/// {@template empty_type}
/// Internal Type implementation used to represent an empty or unresolvable value.
/// 
/// This class serves as a sentinel value within the ResolvableType system to
/// represent cases where no type information is available or where type
/// resolution has failed. It implements the Type interface but represents
/// the absence of a concrete type.
/// 
/// This class is used internally by ResolvableType.NONE and should not be
/// instantiated directly by user code.
/// {@endtemplate}
class _EmptyType implements Type {
  static final _EmptyType _instance = _EmptyType._();
  
  _EmptyType._();
  
  @override
  String toString() => 'EmptyType';
}