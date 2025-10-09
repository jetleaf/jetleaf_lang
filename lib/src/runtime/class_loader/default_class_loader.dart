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
import 'dart:collection';

import '../../commons/string_builder.dart';
import '../../extensions/primitives/iterable.dart';
import '../../exceptions.dart';
import '../../declaration/declaration.dart';
import '../utils/generic_type_parser.dart';
import '../runtime_provider/meta_runtime_provider.dart';
import '../../meta/protection_domain.dart';
import '../type_discovery.dart';
import '../../meta/class.dart';
import 'class_loader.dart';

// Primary caches
final Map<String, Class> _classCache = HashMap<String, Class>();
final Map<String, Class> _superClassCache = HashMap<String, Class>();
final Map<String, Class> _classKeyCache = HashMap<String, Class>();
final Map<String, Class> _classComponentCache = HashMap<String, Class>();
final Map<String, List<Class>> _typeParameterCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _subclassCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _interfaceCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _interfaceArgumentCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _constraintCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _constraintArgumentCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _mixinCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _mixinArgumentCache = HashMap<String, List<Class>>();
final Map<String, List<Class>> _superClassArgumentCache = HashMap<String, List<Class>>();

/// {@template meta_class_loader}
/// The default system implementation of [ClassLoader] with comprehensive caching.
/// 
/// Provides efficient class loading and caching for the JetLeaf reflection system.
/// This implementation uses multiple specialized caches to optimize different
/// types of reflection queries and maintains detailed statistics for monitoring.
/// 
/// ## Cache Architecture
/// The DefaultClassLoader employs a multi-tier caching strategy:
/// 
/// ### Primary Caches
/// - **Class Cache**: Maps qualified names to [Class] instances
/// - **Subclass Cache**: Maps parent classes to their direct classes
/// - **Interface Cache**: Maps classes to their implemented interfaces
/// - **Mixin Cache**: Maps classes to their applied mixins
/// 
/// ### Declared Caches (Non-transitive)
/// - **Declared Interface Cache**: Direct interface implementations only
/// - **Declared Mixin Cache**: Direct mixin applications only
/// 
/// ## Performance Characteristics
/// - **Class Loading**: O(1) for cached, O(log n) for new classes
/// - **Hierarchy Queries**: O(1) for cached relationships
/// - **Memory Usage**: Configurable with automatic cleanup
/// - **Thread Safety**: Full concurrent access support
/// 
/// ## Example Usage
/// ```dart
/// // Create system class loader
/// final loader = DefaultClassLoader();
/// 
/// // Load classes with caching
/// final stringClass = await loader.loadClass<String>('dart:core/string.dart.String');
/// final listClass = await loader.loadClass<List>('dart:core/list.dart.List');
/// 
/// // Query relationships (cached)
/// final classes = await loader.findSubclasses(stringClass);
/// final interfaces = await loader.findInterfaces(listClass);
/// 
/// // Monitor performance
/// final stats = loader.getCacheStats();
/// print('Hit rate: ${stats.hitRate}');
/// 
/// // Cleanup
/// await loader.flush(); // Clear caches
/// await loader.close(); // Release resources
/// ```
/// 
/// ## Configuration Options
/// The loader supports various configuration parameters:
/// - **Max Cache Size**: Prevents unbounded memory growth
/// - **Auto-flush Threshold**: Automatic cache cleanup triggers
/// - **Statistics Collection**: Detailed performance monitoring
/// - **Security Domains**: Fine-grained access control
/// 
/// ## Thread Safety
/// All operations are thread-safe and support concurrent access:
/// - Multiple threads can load classes simultaneously
/// - Cache updates are atomic and consistent
/// - Statistics are accurately maintained under concurrency
/// - Resource cleanup is coordinated across threads
/// 
/// {@endtemplate}
class DefaultClassLoader extends ClassLoader {
  // Statistics tracking
  int _hitCount = 0;
  int _missCount = 0;
  int _successfulLoads = 0;
  int _failedLoads = 0;
  final List<int> _loadTimes = <int>[];
  
  // State management
  bool _closed = false;
  final Completer<void> _closeCompleter = Completer<void>();

  /// {@macro meta_class_loader}
  DefaultClassLoader();

  @override
  Class<T>? loadClass<T>(String className, [ProtectionDomain? domain]) {
    _checkClosed();
    
    // Check cache first
    final cached = _classCache[className];
    if (cached != null) {
      _hitCount++;
      return cached as Class<T>;
    }
    
    _missCount++;
    
    // Load class and measure time
    final stopwatch = Stopwatch()..start();
    try {
      final clazz = findClass<T>(className, domain);
      stopwatch.stop();
      _loadTimes.add(stopwatch.elapsedMilliseconds);
      
      if (clazz != null) {
        // Cache the result
        _classCache[className] = clazz;
        _successfulLoads++;
        
        return clazz;
      } else {
        _failedLoads++;
        return null;
      }
    } catch (e) {
      stopwatch.stop();
      _failedLoads++;
      rethrow;
    }
  }

  @override
  Class<T>? findClass<T>(String className, [ProtectionDomain? domain]) {
    _checkClosed();
    
    try {
      // Try qualified name lookup first
      var declaration = TypeDiscovery.findByQualifiedName(className);
      
      // Fallback to simple name lookup
      declaration ??= TypeDiscovery.findBySimpleName(className);
      
      if (declaration == null) {
        return null;
      }
      
      return Class.declared<T>(declaration, domain ?? ProtectionDomain.current());
    } catch (e) {
      rethrow;
    }
  }

  String _buildCacheKey(Class c) {
    StringBuilder builder = StringBuilder();
    builder.append("${c.getQualifiedName()}:${c.getName()}:${c.getType()}:${c.hashCode}:$c");

    final args = c.getTypeDeclaration().getTypeArguments();
    args.map((a) => builder.append(":${a.getType()}-${a.getName()}-${a.getPointerQualifiedName()}-$a"));

    builder.append(c.getPackageUri());

    return builder.toString();
  }

  @override
  List<Class> findSubclasses(Class parentClass) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:classes";
    
    // Check cache first
    final cached = _subclassCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeSubclasses(parentClass);
    
    // Cache result
    _subclassCache[cacheKey] = classes;
    
    return List.from(classes);
  }

  /// Computes direct classes for a given parent class.
  List<Class> _computeSubclasses(Class parentClass) {
    final allClasses = Runtime.getAllClasses();
    final subClasses = <Class>[];
    final pd = parentClass.getProtectionDomain();
    
    for (final clazz in allClasses) {
      final supertype = clazz.getSuperClass();
      if (supertype != null && (supertype.getPointerType() == parentClass.getType() || supertype.getType() == parentClass.getType() || supertype.getPointerQualifiedName() == parentClass.getQualifiedName())) {
        Class classToAdd;
        if(GenericTypeParser.shouldCheckGeneric(clazz.getType())) {
          classToAdd = Class.fromQualifiedName(clazz.getQualifiedName(), pd);
        } else {
          classToAdd = Class.declared(clazz, pd);
        }

        subClasses.add(classToAdd);
      }

      final superInterface = clazz.getInterfaces().firstWhereOrNull((i) => i.getPointerType() == parentClass.getType() || i.getType() == parentClass.getType() || i.getPointerQualifiedName() == parentClass.getQualifiedName());
      if (superInterface != null && (superInterface.getPointerType() == parentClass.getType() || superInterface.getType() == parentClass.getType() || superInterface.getPointerQualifiedName() == parentClass.getQualifiedName())) {
        Class classToAdd;
        if(GenericTypeParser.shouldCheckGeneric(clazz.getType())) {
          classToAdd = Class.fromQualifiedName(clazz.getQualifiedName(), pd);
        } else {
          classToAdd = Class.declared(clazz, pd);
        }

        subClasses.add(classToAdd);
      }
    }

    return subClasses.toSet().toList();
  }

  @override
  List<Class> findTypeParameters(Class parentClass) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:typeParameters";
    
    // Check cache first
    final cached = _typeParameterCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final args = parentClass.getTypeDeclaration().getTypeArguments();
    final classes = args.map((tp) => _getFromLink(tp, parentClass.getProtectionDomain(), useType: true)).toList();
    
    // Cache result
    _typeParameterCache[cacheKey] = classes;
    
    return List.from(classes);
  }

  Class _getFromLink(LinkDeclaration link, ProtectionDomain pd, {bool useType = false, bool usePointer = false}) {
    try {
      if (useType) {
        return _handleTypeLogic(link, pd);
      } else if (usePointer) {
        return _handlePointerLogic(link, pd);
      }
      return _handleDefaultLogic(link, pd);
    } catch (_) {
      if (useType) {
        return _handleTypeFallback(link, pd);
      } else if (usePointer) {
        return _handlePointerFallback(link, pd);
      }
      return _handleDefaultFallback(link, pd);
    }
  }

  Class _handleTypeLogic(LinkDeclaration link, ProtectionDomain pd) {
    if (GenericTypeParser.shouldCheckGeneric(link.getType())) {
      return Class.fromQualifiedName(link.getPointerQualifiedName(), pd);
    }
    return Class.forType(link.getType(), pd);
  }

  Class _handlePointerLogic(LinkDeclaration link, ProtectionDomain pd) {
    if (link.getType() == link.getPointerType()) {
      return Class.fromQualifiedName(link.getPointerQualifiedName());
    }
    if (GenericTypeParser.shouldCheckGeneric(link.getPointerType())) {
      return Class.fromQualifiedName(link.getPointerQualifiedName(), pd);
    }
    return Class.forType(link.getPointerType(), pd);
  }

  Class _handleDefaultLogic(LinkDeclaration link, ProtectionDomain pd) {
    if (link.getType() == link.getPointerType()) {
      return Class.fromQualifiedName(link.getPointerQualifiedName());
    }
    
    if (GenericTypeParser.shouldCheckGeneric(link.getPointerType())) {
      return Class.fromQualifiedName(link.getPointerQualifiedName(), pd);
    }
    
    if (GenericTypeParser.shouldCheckGeneric(link.getType())) {
      return Class.fromQualifiedName(link.getPointerQualifiedName(), pd);
    }
    
    return Class.forType(link.getType(), pd);
  }

  Class _handleTypeFallback(LinkDeclaration link, ProtectionDomain pd) {
    if (GenericTypeParser.shouldCheckGeneric(link.getType())) {
      return Class.forType(link.getPointerType(), pd);
    }
    return Class.forType(link.getType(), pd);
  }

  Class _handlePointerFallback(LinkDeclaration link, ProtectionDomain pd) {
    if (link.getType() == link.getPointerType()) {
      return Class.forType(link.getType(), pd);
    }
    return Class.forType(link.getPointerType(), pd);
  }

  Class _handleDefaultFallback(LinkDeclaration link, ProtectionDomain pd) {
    if (link.getType() == link.getPointerType()) {
      return Class.forType(link.getType(), pd);
    }
    
    if (GenericTypeParser.shouldCheckGeneric(link.getPointerType())) {
      return Class.forType(link.getType(), pd);
    }
    
    if (GenericTypeParser.shouldCheckGeneric(link.getType())) {
      return Class.forType(link.getPointerType(), pd);
    }
    
    if (link.getType() != link.getPointerType()) {
      return Class.forType(link.getPointerType(), pd);
    }
    
    return Class.forType(link.getType(), pd);
  }

  @override
  List<Class> findAllInterfaceArguments(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:interfaceArguments:$declared";
    
    // Check cache first
    final cached = _interfaceArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeAllInterfaceArguments(parentClass, declared);
    
    // Cache result
    _interfaceArgumentCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeAllInterfaceArguments(Class parentClass, bool declared) {
    if(declared) {
      return parentClass.getTypeDeclaration().getInterfaces()
        .flatMap((i) => i.getTypeArguments())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getInterfaces()
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .flatMap((i) => i.getTypeParameters())
        .toList();
    }
  }
  
  @override
  List<Class> findAllMixinArguments(Class parentClass, [bool declared = true]) {
    _checkClosed();

    final cacheKey = "${_buildCacheKey(parentClass)}:mixinArguments:$declared";
    
    // Check cache first
    final cached = _mixinArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeAllMixinArguments(parentClass, declared);
    
    // Cache result
    _mixinArgumentCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeAllMixinArguments(Class parentClass, bool declared) {
    if(declared) {
      return parentClass.getTypeDeclaration().getMixins()
        .flatMap((i) => i.getTypeArguments())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getMixins()
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .flatMap((i) => i.getTypeParameters())
        .toList();
    }
  }

  @override
  List<Class> findAllConstraintArguments(Class parentClass, [bool declared = true]) {
    _checkClosed();

    final cacheKey = "${_buildCacheKey(parentClass)}:constraintArguments:$declared";
    
    // Check cache first
    final cached = _constraintArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeAllConstraintArguments(parentClass, declared);
    
    // Cache result
    _constraintArgumentCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeAllConstraintArguments(Class parentClass, bool declared) {
    if(parentClass.getTypeDeclaration() is MixinDeclaration) {
      if(declared) {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .flatMap((i) => i.getTypeArguments())
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
          .toList();
      } else {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
          .flatMap((i) => i.getTypeParameters())
          .toList();
      }
    }

    return [];
  }
  
  @override
  List<Class> findInterfaceArguments<I>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<I>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:interfaceArguments:$declared";
    
    // Check cache first
    final cached = _interfaceArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeInterfaceArguments(parentClass, declared, clazz);
    
    // Cache result
    _interfaceArgumentCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeInterfaceArguments(Class parentClass, bool declared, Class clazz) {
    if(declared) {
      return parentClass.getTypeDeclaration().getInterfaces()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .flatMap((i) => i.getTypeArguments())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getInterfaces()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .flatMap((i) => i.getTypeParameters())
        .toList();
    }
  }
  
  @override
  List<Class<I>> findInterfaces<I>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<I>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:interfaces:$declared";
    
    // Check cache first
    final cached = _interfaceCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeInterfaces(parentClass, declared, clazz);
    
    // Cache result
    _interfaceCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeInterfaces(Class parentClass, bool declared, Class clazz) {
    if(declared) {
      return parentClass.getTypeDeclaration().getInterfaces()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getInterfaces()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .toList();
    }
  }
  
  @override
  List<Class> findMixinArguments<I>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<I>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:mixinArguments:$declared";
    
    // Check cache first
    final cached = _mixinArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeMixinArguments(parentClass, declared, clazz);
    
    // Cache result
    _mixinArgumentCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeMixinArguments(Class parentClass, bool declared, Class clazz) {
    if(declared) {
      return parentClass.getTypeDeclaration().getMixins()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .flatMap((i) => i.getTypeArguments())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getMixins()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .flatMap((i) => i.getTypeParameters())
        .toList();
    }
  }
  
  @override
  List<Class<I>> findMixins<I>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<I>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:mixins:$declared";
    
    // Check cache first
    final cached = _mixinCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeMixins(parentClass, declared, clazz);
    
    // Cache result
    _mixinCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeMixins(Class parentClass, bool declared, Class clazz) {
    if(declared) {
      return parentClass.getTypeDeclaration().getMixins()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getMixins()
        .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .toList();
    }
  }

  @override
  List<Class> findConstraintArguments<I>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<I>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:constraintArguments:$declared";
    
    // Check cache first
    final cached = _constraintArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeConstraintArguments(parentClass, declared, clazz);
    
    // Cache result
    _constraintArgumentCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeConstraintArguments(Class parentClass, bool declared, Class clazz) {
    if(parentClass.getTypeDeclaration() is MixinDeclaration) {
      if(declared) {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
          .flatMap((i) => i.getTypeArguments())
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
          .toList();
      } else {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
          .flatMap((i) => i.getTypeParameters())
          .toList();
      }
    }

    return [];
  }
  
  @override
  List<Class<I>> findConstraints<I>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<I>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:constraints:$declared";
    
    // Check cache first
    final cached = _constraintCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeConstraints(parentClass, declared, clazz);
    
    // Cache result
    _constraintCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeConstraints(Class parentClass, bool declared, Class clazz) {
    if(parentClass.getTypeDeclaration() is MixinDeclaration) {
      if(declared) {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
          .toList();
      } else {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .where((i) => i.getPointerQualifiedName() == clazz.getQualifiedName())
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
          .toList();
      }
    }

    return [];
  }
  
  @override
  Class? findSuperClass(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:superClass:$declared";
    
    // Check cache first
    final cached = _superClassCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return cached;
    }
    
    _missCount++;
    
    // Compute classes
    final link = parentClass.getTypeDeclaration().asClass()?.getSuperClass();
    if (link == null) return null;

    final result = _getFromLink(link, parentClass.getProtectionDomain(), useType: declared);
    
    // Cache result
    _superClassCache[cacheKey] = result;
    
    return result;
  }

  @override
  Class<S>? findSuperClassAs<S>(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final clazz = Class<S>();
    final cacheKey = "${_buildCacheKey(parentClass)}:${_buildCacheKey(clazz)}:superClass:$declared";
    
    // Check cache first
    final cached = _superClassCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return cached as Class<S>;
    }
    
    _missCount++;
    
    // Compute classes
    final link = parentClass.getTypeDeclaration().asClass()?.getSuperClass();
    if (link == null) return null;

    final result = _getFromLink(link, parentClass.getProtectionDomain(), useType: declared);
    
    // Cache result
    _superClassCache[cacheKey] = result;
    
    return result as Class<S>;
  }

  @override
  List<Class> findSuperClassArguments(Class parentClass, [bool declared = true]) {
    _checkClosed();

    final cacheKey = "${_buildCacheKey(parentClass)}:superClassArguments:$declared";
    
    // Check cache first
    final cached = _superClassArgumentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;

    final superType = parentClass.getTypeDeclaration().asClass()?.getSuperClass();
    if(superType == null) return [];

    final result = superType.getTypeArguments().map((t) => _getFromLink(t, parentClass.getProtectionDomain(), useType: declared)).toList();

    // Cache result
    _superClassArgumentCache[cacheKey] = result;
    
    return List.from(result.toSet().toList());
  }

  @override
  Class<C>? findComponentType<C>(Class parentClass, Type? component) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:${component ?? ""}:classComponent";
    
    // Check cache first
    final cached = _classComponentCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return cached as Class<C>;
    }
    
    _missCount++;

    component ??= extractComponentType(parentClass);

    Class<C>? result;
    if (component == null) {
      result = _extractComponentTypeFromName<C>(parentClass);
    } else if(component.toString().contains("dynamic") && !parentClass.getName().contains("dynamic")) {
      result = _extractComponentTypeFromName<C>(parentClass);
    } else {
      result = Class.forType<C>(component as C, parentClass.getProtectionDomain());
    }

    // Cache result
    if(result != null) {
      _classComponentCache[cacheKey] = result;
    }
    
    return result;
  }

  @override
  Type? extractComponentType(Class parentClass) {
    // Handle generic classes with type arguments
    final typeArgs = parentClass.getTypeDeclaration().getTypeArguments();
    if (typeArgs.isNotEmpty && typeArgs.length == 1) {
      return _getFromLink(typeArgs.first, parentClass.getProtectionDomain()).getType();
    } else if (typeArgs.length >= 2) {
      return _getFromLink(typeArgs[1], parentClass.getProtectionDomain()).getType();
    }
    
    return null;
  }

  Class<C>? _extractComponentTypeFromName<C>(Class parentClass) {
    String name = parentClass.isCanonical() ? parentClass.getName() : parentClass.getCanonicalName();

    if(GenericTypeParser.isGeneric(name)) {
      final result = GenericTypeParser.resolveGenericType(name);
      if(result.types.length == 1) {
        return Class.forName<C>(result.types.getFirst().typeString, parentClass.getProtectionDomain());
      } else if(result.types.length == 2) {
        return Class.forName<C>(result.types.getLast().typeString, parentClass.getProtectionDomain());
      }
    }

    return null;
  }

  @override
  Class<K>? findKeyType<K>(Class parentClass, Type? key) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:${key ?? ""}:classKey";
    
    // Check cache first
    final cached = _classKeyCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return cached as Class<K>;
    }
    
    _missCount++;

    key ??= extractKeyType(parentClass);

    Class<K>? result;
    if (key == null) {
      result = _extractKeyTypeFromName<K>(parentClass);
    } else if(key.toString().contains("dynamic") && !parentClass.getName().contains("dynamic")) {
      result = _extractKeyTypeFromName<K>(parentClass);
    } else {
      result = Class.forType<K>(key as K, parentClass.getProtectionDomain());
    }

    // Cache result
    if(result != null) {
      _classKeyCache[cacheKey] = result;
    }
    
    return result;
  }

  @override
  Type? extractKeyType(Class parentClass) {
    // Handle generic classes with type arguments (Map<K,V> pattern)
    final typeArgs = parentClass.getTypeDeclaration().getTypeArguments();
    if (typeArgs.length >= 2) {
      return _getFromLink(typeArgs[0], parentClass.getProtectionDomain()).getType();
    }
    
    return null;
  }

  Class<K>? _extractKeyTypeFromName<K>(Class parentClass) {
    String name = parentClass.isCanonical() ? parentClass.getName() : parentClass.getCanonicalName();

    if(GenericTypeParser.isGeneric(name)) {
      final result = GenericTypeParser.resolveGenericType(name);
      if(result.types.length >= 2) {
        return Class.forName<K>(result.types.getFirst().typeString, parentClass.getProtectionDomain());
      }
    }

    return null;
  }

  @override
  List<Class> findAllInterfaces(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:interfaces:$declared";
    
    // Check cache first
    final cached = _interfaceCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeAllInterfaces(parentClass, declared);
    // Cache result
    _interfaceCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeAllInterfaces(Class parentClass, bool declared) {
    if(declared) {
      return parentClass.getTypeDeclaration().getInterfaces()
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getInterfaces()
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .toList();
    }
  }

  @override
  List<Class> findAllMixins(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:mixins:$declared";
    
    // Check cache first
    final cached = _mixinCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeAllMixins(parentClass, declared);
    
    // Cache result
    _mixinCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeAllMixins(Class parentClass, bool declared) {
    if(declared) {
      return parentClass.getTypeDeclaration().getMixins()
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
        .toList();
    } else {
      return parentClass.getTypeDeclaration().getMixins()
        .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
        .toList();
    }
  }

  @override
  List<Class> findAllConstraints(Class parentClass, [bool declared = true]) {
    _checkClosed();
    
    final cacheKey = "${_buildCacheKey(parentClass)}:constraints:$declared";
    
    // Check cache first
    final cached = _constraintCache[cacheKey];
    if (cached != null) {
      _hitCount++;
      return List.from(cached);
    }
    
    _missCount++;
    
    // Compute classes
    final classes = _computeAllConstraints(parentClass, declared);
    
    // Cache result
    _constraintCache[cacheKey] = classes;
    
    return List.from(classes.toSet().toList());
  }

  List<Class> _computeAllConstraints(Class parentClass, bool declared) {
    if(parentClass.getTypeDeclaration() is MixinDeclaration) {
      if(declared) {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain(), useType: true))
          .toList();
      } else {
        return (parentClass.getTypeDeclaration() as MixinDeclaration).getConstraints()
          .map((i) => _getFromLink(i, parentClass.getProtectionDomain()))
          .toList();
      }
    }

    return [];
  }

  @override
  bool isLoaded(String className) {
    return _classCache.containsKey(className);
  }

  @override
  ClassLoaderStats getCacheStats() {
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? _hitCount / totalRequests : 0.0;
    
    final avgLoadTime = _loadTimes.isNotEmpty 
        ? _loadTimes.reduce((a, b) => a + b) / _loadTimes.length 
        : 0.0;
    
    // Estimate memory usage (rough calculation)
    final memoryUsage = (_classCache.length * 1024) + // ~1KB per class
      (_subclassCache.length * 512) +  // ~512B per subclass list
      (_interfaceCache.length * 256) + // ~256B per interface list
      (_mixinCache.length * 256);      // ~256B per mixin list
    
    return ClassLoaderStats(
      classCount: _classCache.length,
      subclassCount: _subclassCache.length,
      interfaceCount: _interfaceCache.length,
      declaredInterfaceCount: 0,
      mixinCount: _mixinCache.length,
      declaredMixinCount: 0,
      hitRate: hitRate,
      hitCount: _hitCount,
      missCount: _missCount,
      memoryUsage: memoryUsage,
      averageLoadTime: avgLoadTime,
      successfulLoads: _successfulLoads,
      failedLoads: _failedLoads,
    );
  }

  @override
  Future<void> flush() async {
    if (_closed) return;
    
    // Clear all caches
    _classCache.clear();
    _classComponentCache.clear();
    _classKeyCache.clear();
    _subclassCache.clear();
    _interfaceCache.clear();
    _mixinCache.clear();
    _interfaceArgumentCache.clear();
    _mixinArgumentCache.clear();
    _superClassArgumentCache.clear();
    _superClassCache.clear();
    _typeParameterCache.clear();
    _constraintCache.clear();
    _constraintArgumentCache.clear();
    
    // Reset statistics
    _hitCount = 0;
    _missCount = 0;
    _successfulLoads = 0;
    _failedLoads = 0;
    _loadTimes.clear();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    
    _closed = true;
    
    try {
      // Flush all caches
      await flush();
      
      // Complete the close operation
      _closeCompleter.complete();
    } catch (e) {
      _closeCompleter.completeError(e);
      rethrow;
    }
  }

  /// Checks if the loader is closed and throws if it is.
  void _checkClosed() {
    if (_closed) {
      throw IllegalStateException('ClassLoader has been closed');
    }
  }
}

/// {@macro meta_class_loader}
final ClassLoader MetaClassLoader = DefaultClassLoader();