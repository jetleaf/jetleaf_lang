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

import 'dart:async';

import '../../io/closeable.dart';
import '../../io/flushable.dart';
import '../../meta/protection_domain.dart';
import '../../meta/class.dart';

/// {@template class_loader}
/// An abstract class loader that manages the loading and caching of class metadata.
/// 
/// The ClassLoader serves as a centralized cache and management system for class
/// reflection data, providing efficient access to class hierarchies, interfaces,
/// mixins, and other type information. It implements both [Closeable] and [Flushable]
/// interfaces to support proper resource management and cache invalidation.
/// 
/// ## Key Features
/// - **Hierarchical Caching**: Maintains separate caches for classes, subclasses, 
///   interfaces, mixins, and their relationships
/// - **Memory Management**: Provides flush and close operations for cache cleanup
/// - **Thread Safety**: Ensures safe concurrent access to cached data
/// - **Performance Optimization**: Reduces redundant reflection operations through
///   intelligent caching strategies
/// 
/// ## Cache Categories
/// The ClassLoader maintains several specialized caches:
/// - **Class Cache**: Primary class instances indexed by qualified name
/// - **Subclass Cache**: Direct subclass relationships for inheritance traversal
/// - **Interface Cache**: Implemented interfaces for each class
/// - **Declared Interface Cache**: Directly declared interfaces (non-transitive)
/// - **Mixin Cache**: Applied mixins for composition analysis
/// - **Declared Mixin Cache**: Directly declared mixins (non-transitive)
/// 
/// ## Usage Patterns
/// ```dart
/// // Get or create a class loader
/// final loader = SystemClassLoader();
/// 
/// // Load a class with caching
/// final userClass = await loader.loadClass<User>('package:example/test.dart.User');
/// 
/// // Find related classes efficiently
/// final subclasses = await loader.findSubclasses(userClass);
/// final interfaces = await loader.findInterfaces(userClass);
/// 
/// // Clean up resources
/// await loader.flush(); // Clear caches
/// await loader.close(); // Release all resources
/// ```
/// 
/// ## Implementation Requirements
/// Concrete implementations must provide:
/// - Class loading strategy ([loadClass], [findClass])
/// - Cache management policies ([flush], [close])
/// - Resource cleanup procedures
/// - Thread safety mechanisms
/// 
/// ## Memory Considerations
/// The ClassLoader maintains strong references to loaded classes and their metadata.
/// Regular flushing is recommended for long-running applications to prevent
/// memory leaks, especially when dealing with dynamic class loading scenarios.
/// 
/// {@endtemplate}
abstract class ClassLoader implements Closeable, Flushable {
  /// {@macro class_loader}
  ClassLoader();

  /// Loads a class by its fully qualified name with caching support.
  /// 
  /// {@template class_loader_load_class}
  /// Type Parameters:
  /// - `T`: The expected class type for type safety
  /// 
  /// Parameters:
  /// - [className]: The fully qualified class name (e.g., 'dart:core/string.dart.String')
  /// - [domain]: Optional protection domain for security context
  /// 
  /// Returns:
  /// - A cached or newly loaded [Class<T>] instance
  /// - `null` if the class cannot be found or loaded
  /// 
  /// ## Caching Behavior
  /// - First checks the primary class cache for existing instances
  /// - If not cached, delegates to [findClass] for loading
  /// - Caches successful results for future requests
  /// - Updates related caches (subclasses, interfaces, mixins)
  /// 
  /// ## Example
  /// ```dart
  /// // Load with type safety
  /// final stringClass = await loader.loadClass<String>('dart:core/string.dart.String');
  /// 
  /// // Load with custom domain
  /// final userClass = await loader.loadClass<User>(
  ///   'package:example/test.dart.User',
  ///   ProtectionDomain.application()
  /// );
  /// ```
  /// 
  /// ## Performance Notes
  /// - Subsequent calls for the same class return cached instances
  /// - Cache lookups are O(1) for qualified name access
  /// - Related type information is pre-computed and cached
  /// 
  /// Throws:
  /// - [ClassNotFoundException] if the class cannot be located
  /// - [SecurityException] if access is denied by protection domain
  /// {@endtemplate}
  Class<T>? loadClass<T>(String className, [ProtectionDomain? domain]);

  /// Finds and loads a class without caching (used internally by [loadClass]).
  /// 
  /// {@template class_loader_find_class}
  /// Type Parameters:
  /// - `T`: The expected class type for type safety
  /// 
  /// Parameters:
  /// - [className]: The fully qualified class name to locate
  /// - [domain]: Optional protection domain for security context
  /// 
  /// Returns:
  /// - A newly created [Class<T>] instance if found
  /// - `null` if the class cannot be located
  /// 
  /// ## Implementation Contract
  /// This method is called by [loadClass] when a class is not found in the cache.
  /// Implementations should:
  /// - Perform the actual class discovery and loading
  /// - Create appropriate [Class] instances with metadata
  /// - Handle security checks and domain validation
  /// - NOT perform caching (handled by [loadClass])
  /// 
  /// ## Example Implementation
  /// ```dart
  /// @override
  /// Class<T>? findClass<T>(String className, [ProtectionDomain? domain]) async {
  ///   final declaration = await _typeDiscovery.findByQualifiedName(className);
  ///   if (declaration == null) return null;
  ///   
  ///   return Class.declared<T>(declaration, domain ?? ProtectionDomain.current());
  /// }
  /// ```
  /// 
  /// Throws:
  /// - [SecurityException] if access is denied by protection domain
  /// {@endtemplate}
  Class<T>? findClass<T>(String className, [ProtectionDomain? domain]);

  /// {@template class_loader_find_super_class}
  /// Finds the superclass of a given [parentClass].
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose superclass should be located.
  /// - [declared]: If `true` (default), returns the directly declared superclass only.  
  ///   If `false`, returns the nearest superclass in the hierarchy.
  /// 
  /// Returns:
  /// - The superclass [Class] instance, or `null` if none exists.
  /// 
  /// ## Example
  /// ```dart
  /// final dogClass = await loader.loadClass<Dog>('package:example/test.dart.Dog');
  /// final superClass = loader.findSuperClass(dogClass);
  /// print(superClass?.qualifiedName); // e.g., "package:example/test.dart.Animal"
  /// ```
  /// 
  /// ## Usage Notes
  /// - Declared mode is useful for analyzing direct inheritance.
  /// - Non-declared mode is helpful for traversing extended hierarchies.
  /// {@endtemplate}
  Class? findSuperClass(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_super_class_as}
  /// Finds and casts the superclass of a given [parentClass] to a specific type.
  /// 
  /// Type Parameters:
  /// - `S`: The expected type of the superclass.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose superclass should be located.
  /// - [declared]: If `true` (default), returns the directly declared superclass.  
  ///   If `false`, searches up the hierarchy.
  /// 
  /// Returns:
  /// - A typed [Class<S>] instance if found, or `null` otherwise.
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
  /// final superIterable = loader.findSuperClassAs<Iterable>(listClass);
  /// print(superIterable?.qualifiedName); // e.g., "dart:core/iterable.dart.Iterable"
  /// ```
  /// {@endtemplate}
  Class<S>? findSuperClassAs<S>(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_super_class_arguments}
  /// Finds the type arguments of the superclass of a given [parentClass].
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose superclass should be located.
  /// - [declared]: If `true` (default), returns the directly declared superclass.  
  ///   If `false`, searches up the hierarchy.
  /// 
  /// Returns:
  /// - A list of [Class] instances representing the type arguments of the superclass.
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
  /// final superIterableArgs = loader.findSuperClassArguments(listClass);
  /// print(superIterableArgs.map((arg) => arg.qualifiedName)); // e.g., ["dart:core/iterable.dart.Iterable"]
  /// ```
  /// {@endtemplate}
  List<Class> findSuperClassArguments(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_component_type}
  /// Finds the component type of a collection-like class.
  /// 
  /// Type Parameters:
  /// - `C`: The expected component type.
  /// 
  /// Parameters:
  /// - [parentClass]: The class representing the collection.
  /// - [component]: The runtime [Type] to help narrow the match (optional).
  /// 
  /// Returns:
  /// - A [Class<C>] representing the component type, or `null` if none exists.
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List<String>>('dart:core/list.dart.List');
  /// final stringType = loader.findComponentType<String>(listClass);
  /// print(stringType?.qualifiedName); // "dart:core/string.dart.String"
  /// ```
  /// {@endtemplate}
  Class<C>? findComponentType<C>(Class parentClass, Type? component);

  /// {@template class_loader_find_key_type}
  /// Finds the key type of a map-like class.
  /// 
  /// Type Parameters:
  /// - `K`: The expected key type.
  /// 
  /// Parameters:
  /// - [parentClass]: The class representing the map.
  /// - [key]: The runtime [Type] to help narrow the match (optional).
  /// 
  /// Returns:
  /// - A [Class<K>] representing the key type, or `null` if none exists.
  /// 
  /// ## Example
  /// ```dart
  /// final mapClass = await loader.loadClass<Map<String, int>>('dart:core/map.dart.Map');
  /// final stringType = loader.findKeyType<String>(mapClass);
  /// print(stringType?.qualifiedName); // "dart:core/string.dart.String"
  /// ```
  /// {@endtemplate}
  Class<K>? findKeyType<K>(Class parentClass, Type? key);

  /// {@template class_loader_find_type_parameters}
  /// Finds the type parameters of a generic class.
  /// 
  /// Parameters:
  /// - [parentClass]: The class representing the generic type.
  /// 
  /// Returns:
  /// - A list of [Class] instances representing the type parameters.
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List<String>>('dart:core/list.dart.List');
  /// final typeParams = loader.findTypeParameters(listClass);
  /// print(typeParams.map((arg) => arg.qualifiedName)); // e.g., ["dart:core/string.dart.String"]
  /// ```
  /// {@endtemplate}
  List<Class> findTypeParameters(Class parentClass);

  /// {@template class_loader_extract_component_type}
  /// Extract component type for arrays/lists
  /// 
  /// Parameters:
  /// - [parentClass]: The class representing the collection.
  /// 
  /// Returns:
  /// - The component type, or `null` if not an array/list.
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List<String>>('dart:core/list.dart.List');
  /// final componentType = loader.extractComponentType(listClass);
  /// print(componentType?.qualifiedName); // "dart:core/string.dart.String"
  /// ```
  /// {@endtemplate}
  Type? extractComponentType(Class parentClass);

  /// {@template class_loader_extract_key_type}
  /// Extract key type for maps
  /// 
  /// Parameters:
  /// - [parentClass]: The class representing the map.
  /// 
  /// Returns:
  /// - The key type, or `null` if not a map.
  /// 
  /// ## Example
  /// ```dart
  /// final mapClass = await loader.loadClass<Map<String, int>>('dart:core/map.dart.Map');
  /// final keyType = loader.extractKeyType(mapClass);
  /// print(keyType?.qualifiedName); // "dart:core/string.dart.String"
  /// ```
  /// {@endtemplate}
  Type? extractKeyType(Class parentClass);

  /// Finds all direct subclasses of the specified class with caching.
  /// 
  /// {@template class_loader_find_subclasses}
  /// Parameters:
  /// - [parentClass]: The parent class to find subclasses for
  /// 
  /// Returns:
  /// - List of direct subclasses (not transitive)
  /// - Empty list if no subclasses exist
  /// - Cached results for subsequent calls
  /// 
  /// ## Caching Strategy
  /// - Results are cached by parent class qualified name
  /// - Cache is invalidated when new classes are loaded
  /// - Supports incremental updates for dynamic loading
  /// 
  /// ## Example
  /// ```dart
  /// final animalClass = await loader.loadClass<Animal>('package:example/test.dart.Animal');
  /// final subclasses = await loader.findSubclasses(animalClass);
  /// // Returns: [Dog, Cat, Bird] (direct subclasses only)
  /// ```
  /// 
  /// ## Performance Notes
  /// - First call performs full hierarchy scan
  /// - Subsequent calls return cached O(1) results
  /// - Cache updates are incremental for new class additions
  /// {@endtemplate}
  List<Class> findSubclasses(Class parentClass);

  /// Finds all interfaces implemented by the specified class with caching.
  /// 
  /// {@template class_loader_find_interfaces}
  /// Parameters:
  /// - [parentClass]: The class to find interfaces for
  /// - [declared]: Whether to include inherited interfaces (default: true)
  /// 
  /// Returns:
  /// - List of implemented interfaces
  /// - Empty list if no interfaces are implemented
  /// - Cached results for subsequent calls
  /// 
  /// ## Interface Resolution
  /// - **Transitive (default)**: Includes interfaces from superclasses and mixins
  /// - **Direct only**: Only interfaces explicitly declared on this class
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
  /// final interfaces = await loader.findInterfaces(listClass);
  /// // Returns: [Iterable, Collection, etc.]
  /// 
  /// // Direct interfaces only
  /// final directInterfaces = await loader.findInterfaces(listClass, false);
  /// ```
  /// 
  /// ## Caching Behavior
  /// - Separate caches for transitive and direct interface queries
  /// - Cache keys include the transitive flag for proper segregation
  /// - Automatic cache invalidation on class hierarchy changes
  /// {@endtemplate}
  List<Class> findAllInterfaces(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_interfaces_as}
  /// Finds all interfaces implemented by the specified class with caching.
  /// 
  /// {@template class_loader_find_interfaces_as}
  /// Parameters:
  /// - [parentClass]: The class to find interfaces for
  /// - [declared]: Whether to include inherited interfaces (default: true)
  /// 
  /// Returns:
  /// - List of implemented interfaces
  /// - Empty list if no interfaces are implemented
  /// - Cached results for subsequent calls
  /// 
  /// ## Interface Resolution
  /// - **Transitive (default)**: Includes interfaces from superclasses and mixins
  /// - **Direct only**: Only interfaces explicitly declared on this class
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
  /// final interfaces = await loader.findInterfaces(listClass);
  /// // Returns: [Iterable, Collection, etc.]
  /// 
  /// // Direct interfaces only
  /// final directInterfaces = await loader.findInterfaces(listClass, false);
  /// ```
  /// 
  /// ## Caching Behavior
  /// - Separate caches for transitive and direct interface queries
  /// - Cache keys include the transitive flag for proper segregation
  /// - Automatic cache invalidation on class hierarchy changes
  /// {@endtemplate}
  /// {@endtemplate}
  List<Class<I>> findInterfaces<I>(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_interface_arguments}
  /// Finds all interface arguments of the specified class with caching.
  /// 
  /// {@template class_loader_find_interface_arguments}
  /// Parameters:
  /// - [parentClass]: The class to find interface arguments for
  /// - [declared]: Whether to include inherited interface arguments (default: true)
  /// 
  /// Returns:
  /// - List of interface arguments
  /// - Empty list if no interface arguments are found
  /// - Cached results for subsequent calls
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
  /// final interfaceArgs = await loader.findInterfaceArguments(listClass);
  /// // Returns: [Iterable, Collection, etc.]
  /// 
  /// // Direct interface arguments only
  /// final directInterfaceArgs = await loader.findInterfaceArguments(listClass, false);
  /// ```
  /// 
  /// ## Caching Behavior
  /// - Separate caches for transitive and direct interface queries
  /// - Cache keys include the transitive flag for proper segregation
  /// - Automatic cache invalidation on class hierarchy changes
  /// {@endtemplate}
  /// {@endtemplate}
  List<Class> findAllInterfaceArguments(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_interface_arguments_as}
  /// Finds all interface arguments of the specified class with caching.
  /// 
  /// {@template class_loader_find_interface_arguments_as}
  /// Parameters:
  /// - [parentClass]: The class to find interface arguments for
  /// - [declared]: Whether to include inherited interface arguments (default: true)
  /// 
  /// Returns:
  /// - List of interface arguments
  /// - Empty list if no interface arguments are found
  /// - Cached results for subsequent calls
  /// 
  /// ## Example
  /// ```dart
  /// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
  /// final interfaceArgs = await loader.findInterfaceArguments(listClass);
  /// // Returns: [Iterable, Collection, etc.]
  /// 
  /// // Direct interface arguments only
  /// final directInterfaceArgs = await loader.findInterfaceArguments(listClass, false);
  /// ```
  /// 
  /// ## Caching Behavior
  /// - Separate caches for transitive and direct interface queries
  /// - Cache keys include the transitive flag for proper segregation
  /// - Automatic cache invalidation on class hierarchy changes
  /// {@endtemplate}
  /// {@endtemplate}
  List<Class> findInterfaceArguments<I>(Class parentClass, [bool declared = true]);

  /// Finds all mixins applied to the specified class with caching.
  /// 
  /// {@template class_loader_find_mixins}
  /// Parameters:
  /// - [mixedClass]: The class to find mixins for
  /// - [declared]: Whether to include mixins from superclasses (default: true)
  /// 
  /// Returns:
  /// - List of applied mixins in application order
  /// - Empty list if no mixins are applied
  /// - Cached results for subsequent calls
  /// 
  /// ## Mixin Resolution
  /// - **Transitive (default)**: Includes mixins from entire class hierarchy
  /// - **Direct only**: Only mixins directly applied to this class
  /// - **Application Order**: Mixins are returned in the order they were applied
  /// 
  /// ## Example
  /// ```dart
  /// class MyClass extends BaseClass with MixinA, MixinB {}
  /// 
  /// final myClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final mixins = await loader.findMixins(myClass);
  /// // Returns: [MixinA, MixinB] (in application order)
  /// ```
  /// 
  /// ## Caching Strategy
  /// - Results cached by class and transitivity flag
  /// - Preserves mixin application order in cache
  /// - Efficient lookup for mixin composition analysis
  /// {@endtemplate}
  List<Class> findAllMixins(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_mixins_typed}
  /// Finds mixins applied to a class, returning them as typed [Class] instances.
  /// 
  /// Type Parameters:
  /// - `I`: The expected type of the mixins.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose mixins should be located.
  /// - [declared]: Whether to include inherited mixins (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class<I>] instances.
  /// 
  /// ## Example
  /// ```dart
  /// class Example with MixinA, MixinB {}
  /// final exampleClass = await loader.loadClass<Example>('package:example/test.dart.Example');
  /// final mixins = loader.findMixins<MixinA>(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class<I>> findMixins<I>(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_all_mixin_arguments}
  /// Retrieves all type arguments from all mixins applied to a class.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose mixin arguments should be retrieved.
  /// - [declared]: Whether to include inherited mixins (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class] instances representing all mixin type arguments.
  /// 
  /// ## Example
  /// ```dart
  /// final exampleClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final args = loader.findAllMixinArguments(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class> findAllMixinArguments(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_mixin_arguments}
  /// Retrieves the type arguments for a specific mixin applied to a class.
  /// 
  /// Type Parameters:
  /// - `I`: The mixin type to match.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose mixin arguments should be found.
  /// - [declared]: Whether to include inherited mixins (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class] instances representing the type arguments.
  /// 
  /// ## Example
  /// ```dart
  /// final exampleClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final mixinArgs = loader.findMixinArguments<SomeMixin>(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class> findMixinArguments<I>(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_all_constraint_arguments}
  /// Retrieves all type arguments from all constraints applied to a class.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose constraint arguments should be retrieved.
  /// - [declared]: Whether to include inherited constraints (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class] instances representing all constraint type arguments.
  /// 
  /// ## Example
  /// ```dart
  /// final exampleClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final args = loader.findAllConstraintArguments(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class> findAllConstraintArguments(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_constraint_arguments}
  /// Retrieves the type arguments for a specific constraint applied to a class.
  /// 
  /// Type Parameters:
  /// - `I`: The constraint type to match.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose constraint arguments should be found.
  /// - [declared]: Whether to include inherited constraints (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class] instances representing the type arguments.
  /// 
  /// ## Example
  /// ```dart
  /// final exampleClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final constraintArgs = loader.findConstraintArguments<SomeConstraint>(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class> findConstraintArguments<I>(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_constraints}
  /// Retrieves the constraints applied to a class.
  /// 
  /// Type Parameters:
  /// - `I`: The constraint type to match.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose constraints should be found.
  /// - [declared]: Whether to include inherited constraints (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class] instances representing the constraints.
  /// 
  /// ## Example
  /// ```dart
  /// final exampleClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final constraints = loader.findConstraints<SomeConstraint>(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class<I>> findConstraints<I>(Class parentClass, [bool declared = true]);

  /// {@template class_loader_find_all_constraints}
  /// Retrieves all constraints applied to a class.
  /// 
  /// Parameters:
  /// - [parentClass]: The class whose constraints should be found.
  /// - [declared]: Whether to include inherited constraints (default: `true`).
  /// 
  /// Returns:
  /// - A list of [Class] instances representing all constraints.
  /// 
  /// ## Example
  /// ```dart
  /// final exampleClass = await loader.loadClass<MyClass>('package:example/test.dart.MyClass');
  /// final constraints = loader.findAllConstraints(exampleClass);
  /// ```
  /// {@endtemplate}
  List<Class> findAllConstraints(Class parentClass, [bool declared = true]);

  /// Checks if a class is already loaded in the cache.
  /// 
  /// {@template class_loader_is_loaded}
  /// Parameters:
  /// - [className]: The fully qualified class name to check
  /// 
  /// Returns:
  /// - `true` if the class is currently cached
  /// - `false` if the class needs to be loaded
  /// 
  /// ## Use Cases
  /// - Avoiding unnecessary loading operations
  /// - Cache hit rate monitoring
  /// - Conditional loading strategies
  /// 
  /// ## Example
  /// ```dart
  /// if (!loader.isLoaded('package:example/test.dart.User')) {
  ///   print('Loading User class for first time...');
  ///   await loader.loadClass<User>('package:example/test.dart.User');
  /// }
  /// ```
  /// 
  /// ## Performance
  /// - O(1) lookup operation
  /// - No I/O or reflection overhead
  /// - Safe for frequent checking
  /// {@endtemplate}
  bool isLoaded(String className);

  /// Gets cache statistics for monitoring and optimization.
  /// 
  /// {@template class_loader_get_cache_stats}
  /// Returns:
  /// - [ClassLoaderStats] containing cache metrics
  /// 
  /// ## Available Metrics
  /// - **Hit Rate**: Percentage of cache hits vs misses
  /// - **Cache Sizes**: Number of entries in each cache category
  /// - **Memory Usage**: Estimated memory consumption
  /// - **Load Times**: Average class loading performance
  /// 
  /// ## Example
  /// ```dart
  /// final stats = loader.getCacheStats();
  /// print('Cache hit rate: ${stats.hitRate}%');
  /// print('Classes cached: ${stats.classCount}');
  /// print('Memory usage: ${stats.memoryUsage} bytes');
  /// ```
  /// 
  /// ## Monitoring Use Cases
  /// - Performance tuning and optimization
  /// - Memory usage tracking
  /// - Cache efficiency analysis
  /// - Capacity planning
  /// {@endtemplate}
  ClassLoaderStats getCacheStats();

  /// Flushes all caches, clearing cached class data while keeping the loader active.
  /// 
  /// {@template class_loader_flush}
  /// This operation:
  /// - Clears all cached class instances
  /// - Removes subclass relationship caches
  /// - Clears interface and mixin caches
  /// - Resets cache statistics
  /// - Keeps the loader ready for new operations
  /// 
  /// ## When to Flush
  /// - Memory pressure situations
  /// - After dynamic class modifications
  /// - Periodic maintenance in long-running applications
  /// - Before major application phase transitions
  /// 
  /// ## Example
  /// ```dart
  /// // Clear caches but keep loader active
  /// await loader.flush();
  /// 
  /// // Loader is still usable after flush
  /// final newClass = await loader.loadClass<String>('dart:core/string.dart.String');
  /// ```
  /// 
  /// ## Performance Impact
  /// - Immediate: Frees cached memory
  /// - Short-term: Increased loading times until cache rebuilds
  /// - Long-term: Improved memory efficiency
  /// 
  /// Throws [IOException] if cache cleanup encounters I/O errors.
  /// {@endtemplate}
  @override
  Future<void> flush();

  /// Closes the class loader and releases all resources.
  /// 
  /// {@template class_loader_close}
  /// This operation:
  /// - Flushes all caches (calls [flush])
  /// - Releases system resources
  /// - Marks the loader as closed
  /// - Prevents further operations
  /// 
  /// ## Post-Close Behavior
  /// After closing, the loader becomes unusable:
  /// - [loadClass] throws [IllegalStateException]
  /// - [findClass] throws [IllegalStateException]
  /// - Cache operations are no-ops
  /// - [close] calls are idempotent
  /// 
  /// ## Example
  /// ```dart
  /// try {
  ///   // Use the loader
  ///   final classes = await loader.loadMultipleClasses(classNames);
  /// } finally {
  ///   // Always close in finally block
  ///   await loader.close();
  /// }
  /// 
  /// // Or use with try-with-resources pattern
  /// await using(SystemClassLoader(), (loader) async {
  ///   return await loader.loadClass<User>('package:example/test.dart.User');
  /// });
  /// ```
  /// 
  /// ## Resource Management
  /// - Releases memory held by caches
  /// - Closes any open file handles or connections
  /// - Notifies dependent systems of shutdown
  /// - Ensures clean application termination
  /// 
  /// Throws [IOException] if resource cleanup encounters errors.
  /// {@endtemplate}
  @override
  Future<void> close();
}

/// {@template class_loader_stats}
/// Statistics and metrics for [ClassLoader] cache performance monitoring.
/// 
/// Provides comprehensive insights into cache behavior, memory usage, and
/// performance characteristics to support optimization and capacity planning.
/// 
/// ## Metric Categories
/// - **Cache Performance**: Hit rates, miss counts, load times
/// - **Memory Usage**: Cache sizes, memory consumption estimates
/// - **Operation Counts**: Load attempts, successful loads, failures
/// - **Efficiency Metrics**: Cache utilization, eviction rates
/// 
/// ## Example Usage
/// ```dart
/// final stats = loader.getCacheStats();
/// 
/// // Performance monitoring
/// if (stats.hitRate < 0.8) {
///   print('Low cache hit rate: ${stats.hitRate}');
/// }
/// 
/// // Memory monitoring
/// if (stats.memoryUsage > maxMemoryThreshold) {
///   await loader.flush();
/// }
/// 
/// // Capacity planning
/// print('Classes loaded: ${stats.classCount}');
/// print('Average load time: ${stats.averageLoadTime}ms');
/// ```
/// {@endtemplate}
class ClassLoaderStats {
  /// Total number of classes currently cached.
  final int classCount;
  
  /// Total number of subclass relationships cached.
  final int subclassCount;
  
  /// Total number of interface relationships cached.
  final int interfaceCount;
  
  /// Total number of declared interface relationships cached.
  final int declaredInterfaceCount;
  
  /// Total number of mixin relationships cached.
  final int mixinCount;
  
  /// Total number of declared mixin relationships cached.
  final int declaredMixinCount;
  
  /// Cache hit rate as a percentage (0.0 to 1.0).
  final double hitRate;
  
  /// Total number of cache hits since creation or last reset.
  final int hitCount;
  
  /// Total number of cache misses since creation or last reset.
  final int missCount;
  
  /// Estimated memory usage in bytes.
  final int memoryUsage;
  
  /// Average class loading time in milliseconds.
  final double averageLoadTime;
  
  /// Total number of successful class loads.
  final int successfulLoads;
  
  /// Total number of failed class load attempts.
  final int failedLoads;

  /// {@macro class_loader_stats}
  const ClassLoaderStats({
    required this.classCount,
    required this.subclassCount,
    required this.interfaceCount,
    required this.declaredInterfaceCount,
    required this.mixinCount,
    required this.declaredMixinCount,
    required this.hitRate,
    required this.hitCount,
    required this.missCount,
    required this.memoryUsage,
    required this.averageLoadTime,
    required this.successfulLoads,
    required this.failedLoads,
  });

  /// Creates empty statistics (all zeros).
  const ClassLoaderStats.empty()
      : classCount = 0,
        subclassCount = 0,
        interfaceCount = 0,
        declaredInterfaceCount = 0,
        mixinCount = 0,
        declaredMixinCount = 0,
        hitRate = 0.0,
        hitCount = 0,
        missCount = 0,
        memoryUsage = 0,
        averageLoadTime = 0.0,
        successfulLoads = 0,
        failedLoads = 0;

  @override
  String toString() => 'ClassLoaderStats('
      'classes: $classCount, '
      'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
      'memory: ${memoryUsage}B, '
      'avgLoadTime: ${averageLoadTime.toStringAsFixed(2)}ms'
      ')';
}
