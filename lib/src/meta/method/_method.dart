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

part of 'method.dart';

class _Method extends Method with EqualsAndHashCode {
  final MethodDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Method(this._declaration, this._pd);

  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_METHODS);
    return _declaration.getName();
  }

  @override
  MethodDeclaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_METHODS);
    return _declaration;
  }

  @override
  Class<D> getDeclaringClass<D>() {
    checkAccess('getDeclaringClass', DomainPermission.READ_METHODS);
    final parentClass = _declaration.getParentClass();

    if (parentClass == null) {
      throw IllegalStateException('Method ${getName()} has no declaring class');
    }

    return Class.fromQualifiedName<D>(parentClass.getPointerQualifiedName(), _pd, parentClass);
  }

  @override
  ProtectionDomain getProtectionDomain() => _pd;

  @override
  List<Annotation> getAllDirectAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);

    final annotations = _declaration.getAnnotations();
    return UnmodifiableListView(annotations.map((a) => Annotation.declared(a, getProtectionDomain())));
  }

  @override
  Class<Object> getReturnClass() {
    checkAccess('getReturnType', DomainPermission.READ_METHODS);
    return LangUtils.obtainClassFromLink(_declaration.getReturnType());
  }

  @override
  Version? getVersion() {
    checkAccess("getVersion", DomainPermission.READ_TYPE_INFO);

    if (getDeclaringClass().getPackage() case final package?) {
      return Version.parse(package.getVersion());
    }

    return null;
  }

  @override
  List<Class> getTypeParameters() {
    checkAccess('getTypeParameters', DomainPermission.READ_TYPE_INFO);

    return UnmodifiableListView(
      _declaration.getReturnType().getTypeArguments()
      .map((dec) => Class.fromQualifiedName(dec.getPointerQualifiedName(), _pd, dec))
    );
  }

  @override
  LinkDeclaration getLinkDeclaration() {
    checkAccess('getLinkDeclaration', DomainPermission.READ_METHODS);
    return _declaration.getReturnType();
  }
  
  @override
  bool isKeyValuePaired() {
    checkAccess('isKeyValuePaired', DomainPermission.READ_TYPE_INFO);
    final args = _declaration.getReturnType().getTypeArguments();

    return (args.isNotEmpty && args.length >= 2) 
      || _declaration.getReturnType().getType() == Map 
      || getReturnClass().isAssignableTo(Class.of<Map>()) 
      || getReturnClass().isAssignableTo(Class.of<MapEntry>());
  }

  @override
  bool hasGenerics() => _declaration.getReturnType().getTypeArguments().isNotEmpty;

  @override
  bool isFunction() {
    checkAccess('isFunction', DomainPermission.READ_METHODS);
    return getLinkDeclaration() is FunctionLinkDeclaration;
  }

  @override
  Class<K>? keyType<K>() {
    checkAccess('keyType', DomainPermission.READ_TYPE_INFO);
    if (!isKeyValuePaired()) return null;

    final args = _declaration.getReturnType().getTypeArguments();
    if (args.isEmpty || args.length < 2) {
      return null;
    } 
    
    final link = args[0];
    final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
    return Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link);
  }
  
  @override
  Class<C>? componentType<C>() {
    checkAccess('componentType', DomainPermission.READ_TYPE_INFO);

    final args = _declaration.getReturnType().getTypeArguments();
    if (args.isEmpty) {
      return null;
    } 
    
    final link = keyType() != null ? args[1] : args[0];
    final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
    return Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link);
  }

  @override
  Type getReturnType() {
    checkAccess('getReturnType', DomainPermission.READ_METHODS);
    return getReturnClass().getType();
  }

  @override
  List<Parameter> getParameters() {
    checkAccess('getParameters', DomainPermission.READ_METHODS);
    return UnmodifiableListView(_declaration.getParameters().map((p) => Parameter.declared(p, this, _pd)));
  }

  @override
  int getParameterCount() {
    checkAccess('getParameterCount', DomainPermission.READ_METHODS);
    return getParameters().length;
  }

  @override
  Parameter? getParameter(String name) {
    checkAccess('getParameter', DomainPermission.READ_METHODS);
    final parameters = getParameters();
    return parameters.where((p) => p.getName() == name).firstOrNull;
  }

  @override
  Parameter? getParameterAt(int index) {
    checkAccess('getParameterAt', DomainPermission.READ_METHODS);
    final parameters = getParameters();
    if (index < 0 || index >= parameters.length) return null;
    return parameters[index];
  }

  @override
  List<Class> getParameterTypes() {
    checkAccess('getParameterTypes', DomainPermission.READ_METHODS);
    return UnmodifiableListView(
      _declaration.getParameters().map((p) {
        final link = p.getLinkDeclaration();
        return Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link);
      })
    );
  }

  @override
  List<String> getModifiers() {
    checkAccess('getModifiers', DomainPermission.READ_METHODS);

    return [
      if (isPublic()) 'PUBLIC',
      if (!isPublic()) 'PRIVATE',
      if (isStatic()) 'STATIC',
      if (isAbstract()) 'ABSTRACT',
      if (isConst()) 'CONST',
      if (isFactory()) 'FACTORY',
      if (isGetter()) 'GETTER',
      if (isSetter()) 'SETTER',
    ];
  }

  @override
  bool isStatic() {
    checkAccess('isStatic', DomainPermission.READ_METHODS);
    return _declaration.getIsStatic();
  }

  @override
  bool isAbstract() {
    checkAccess('isAbstract', DomainPermission.READ_METHODS);
    return _declaration.getIsAbstract();
  }

  @override
  bool isVoid() {
    checkAccess('isVoid', DomainPermission.READ_METHODS);

    final type = getReturnClass();
    return type == VOID_CLASS || type.getType() == Void;
  }

  @override
  bool isDynamic() {
    checkAccess('isDynamic', DomainPermission.READ_METHODS);

    final type = getReturnClass();
    return type == DYNAMIC_CLASS || type.getType() == Dynamic;
  }

  @override
  bool isAsync() {
    checkAccess('isAsync', DomainPermission.READ_METHODS);

    // if (_declaration.getDartType() case final dartType?) {
    //   if (dartType.isDartAsyncFuture || dartType.isDartAsyncFutureOr) {
    //     return true;
    //   }
    // }

    final type = getReturnClass();
    return type == Class<Future>(null, PackageNames.DART) || type == Class<FutureOr>(null, PackageNames.DART);
  }

  @override
  bool isFutureVoid() {
    checkAccess('isFutureVoid', DomainPermission.READ_METHODS);

    final type = getReturnClass();

    if (type == Class<Future>(null, PackageNames.DART) || type == Class<FutureOr>(null, PackageNames.DART)) {
      final generic = type.componentType();
      return generic != null && (generic == VOID_CLASS || generic.getType() == Void);
    }
    
    return false;
  }

  @override
  bool isFutureDynamic() {
    checkAccess('isFutureDynamic', DomainPermission.READ_METHODS);

    final type = getReturnClass();

    if (type == Class<Future>(null, PackageNames.DART) || type == Class<FutureOr>(null, PackageNames.DART)) {
      final generic = type.componentType();
      return generic != null && (generic == DYNAMIC_CLASS || generic.getType() == Dynamic);
    }
    
    return false;
  }

  @override
  bool isGetter() {
    checkAccess('isGetter', DomainPermission.READ_METHODS);
    return _declaration.getIsGetter();
  }

  @override
  bool isSetter() {
    checkAccess('isSetter', DomainPermission.READ_METHODS);
    return _declaration.getIsSetter();
  }

  @override
  bool isPublic() {
    checkAccess('isPublic', DomainPermission.READ_METHODS);
    return _declaration.getIsPublic();
  }

  @override
  bool isConst() {
    checkAccess('isConst', DomainPermission.READ_METHODS);
    return _declaration.getIsConst();
  }

  @override
  bool isExternal() {
    checkAccess('isExternal', DomainPermission.READ_METHODS);
    return _declaration.isExternal();
  }

  @override
  bool getIsEntryPoint() {
    checkAccess('getIsEntryPoint', DomainPermission.READ_METHODS);
    return _declaration.getIsEntryPoint();
  }

  @override
  bool getIsTopLevel() {
    checkAccess('getIsTopLevel', DomainPermission.READ_METHODS);
    return _declaration.getIsTopLevel();
  }

  @override
  bool hasNullableReturn() {
    checkAccess('hasNullableReturn', DomainPermission.READ_METHODS);
    return _declaration.hasNullableReturn();
  }

  @override
  bool isFactory() {
    checkAccess('isFactory', DomainPermission.READ_METHODS);
    return _declaration.getIsFactory();
  }

  @override
  dynamic invoke(Object? instance, [Map<String, dynamic>? arguments, List<dynamic> args = const []]) {
    checkAccess('invoke', DomainPermission.INVOKE_METHODS);
    
    // 1. Try to invoke with positional arguments if provided
    if(args.isNotEmpty && arguments == null) {
      final parameters = _declaration.getParameters();
      final result = <String, dynamic>{};

      // Map positional arguments to parameter names
      for (int i = 0; i < args.length && i < parameters.length; i++) {
        final param = parameters[i];
        if (!param.getIsNamed()) {
          result[param.getName()] = args[i];
        }
      }

      return _declaration.invoke(instance, result);
    }

    // 2. Try to invoke with both positional and named arguments if both are provided
    if(args.isNotEmpty && arguments != null) {
      final parameters = _declaration.getParameters();
      final result = <String, dynamic>{...arguments};

      // Map positional arguments to parameter names
      for (int i = 0; i < args.length && i < parameters.length; i++) {
        final param = parameters[i];
        if (!param.getIsNamed()) {
          result[param.getName()] = args[i];
        }
      }

      // Map named arguments to parameter names
      for (int i = 0; i < arguments.length && i < parameters.length; i++) {
        final param = parameters[i];
        if (param.getIsNamed()) {
          final name = param.getName();
          result[name] = arguments[name];
        }
      }

      return _declaration.invoke(instance, result);
    }

    // 3. Try to invoke with named arguments if provided, or we assume that the method has no parameters.
    return _declaration.invoke(instance, arguments ?? {});
  }

  @override
  bool canAcceptArguments(Map<String, dynamic> arguments) {
    checkAccess('canAcceptArguments', DomainPermission.READ_METHODS);
    return MethodUtils.canAcceptArguments(arguments, getParameters());
  }

  @override
  bool canAcceptPositionalArguments(List<dynamic> args) {
    checkAccess('canAcceptPositionalArguments', DomainPermission.READ_METHODS);
    return MethodUtils.canAcceptPositionalArguments(args, getParameters());
  }

  @override
  bool canAcceptNamedArguments(Map<String, dynamic> arguments) {
    checkAccess('canAcceptNamedArguments', DomainPermission.READ_METHODS);
    return MethodUtils.canAcceptNamedArguments(arguments, getParameters());
  }

  @override
  String getSignature() => _createMethodSignature(_declaration);

  @override
  bool isOverride() {
    checkAccess('isOverride', DomainPermission.READ_METHODS);
    
    // Static methods cannot be overridden
    if (isStatic()) {
      return false;
    }
    
    // Constructors cannot be overridden
    if (_declaration.getName().isEmpty || _declaration.getName() == _declaration.getParentClass()?.getName()) {
      return false;
    }
    
    // Check if this method overrides a method from superclass or interfaces
    final overriddenMethod = _findOverriddenMethod();
    return overriddenMethod != null;
  }

  @override
  Method? getOverriddenMethod() {
    checkAccess('getOverriddenMethod', DomainPermission.READ_METHODS);
    
    // Static methods cannot be overridden
    if (isStatic()) {
      return null;
    }
    
    // Find the overridden method
    final overriddenDeclaration = _findOverriddenMethod();
    if (overriddenDeclaration != null) {
      return Method.declared(overriddenDeclaration, _pd);
    }
    
    return null;
  }

  /// Internal method to find the overridden method declaration
  MethodDeclaration? _findOverriddenMethod() {
    final link = _declaration.getParentClass();
    if (link == null) return null;

    // This method declaration might be coming from [ClassDeclaration]
    ClassDeclaration? parent;
    try {
      parent = Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link).getClassDeclaration();
    } on ClassNotFoundException catch (_) { }

    try {
      if(parent == null) {
        return null;
      }
    
      final methodName = _declaration.getName();
      final methodSignature = _createMethodSignature(_declaration);
      
      // Search in superclass hierarchy
      final superclassMethod = _searchInSuperclassHierarchy(parent, methodName, methodSignature);
      if (superclassMethod != null) {
        return superclassMethod;
      }
      
      // Search in implemented interfaces
      final interfaceMethod = _searchInInterfaces(parent, methodName, methodSignature);
      if (interfaceMethod != null) {
        return interfaceMethod;
      }

      // Search in mixed-in types
      final mixinMethod = _searchInMixins(parent, methodName, methodSignature);
      if (mixinMethod != null) {
        return mixinMethod;
      }
    } catch (_) {
      // suppress error
    }

    return null;
  }

  /// Search for method in superclass hierarchy
  MethodDeclaration? _searchInSuperclassHierarchy(ClassDeclaration currentClass, String methodName, String methodSignature) {
    final supertype = currentClass.getSuperClass();
    if (supertype == null) return null;
    
    ClassDeclaration? superclass;

    try {
      superclass = Class.fromQualifiedName(supertype.getPointerQualifiedName(), _pd, supertype).getClassDeclaration();
    } catch (_) {
      // suppress error
    }

    if (superclass == null) return null;
    
    // Check methods in the superclass
    final method = _findMatchingMethod(superclass, methodName, methodSignature);
    if (method != null) {
      return method;
    }
    
    // Recursively search in the superclass hierarchy
    return _searchInSuperclassHierarchy(superclass, methodName, methodSignature);
  }

  /// Search for method in implemented interfaces
  MethodDeclaration? _searchInInterfaces(ClassDeclaration currentClass, String methodName, String methodSignature) {
    final interfaces = currentClass.getInterfaces();
    
    for (final interfaceType in interfaces) {
      ClassDeclaration? interfaceClass;

      try {
        interfaceClass = Class.fromQualifiedName(interfaceType.getPointerQualifiedName(), _pd, interfaceType).getClassDeclaration();
      } catch (_) {
        // suppress error
      }

      if (interfaceClass != null) {
        final method = _findMatchingMethod(interfaceClass, methodName, methodSignature);
        if (method != null) {
          return method;
        }
        
        // Recursively search in interface hierarchy
        final inheritedMethod = _searchInInterfaces(interfaceClass, methodName, methodSignature);
        if (inheritedMethod != null) {
          return inheritedMethod;
        }
      }
    }
    
    return null;
  }

  /// Search for method in mixed-in types
  MethodDeclaration? _searchInMixins(ClassDeclaration currentClass, String methodName, String methodSignature) {
    final mixins = currentClass.getMixins();
    
    for (final mixinType in mixins) {
      MixinDeclaration? mixinDeclaration;

      try {
        mixinDeclaration = Class.fromQualifiedName(mixinType.getPointerQualifiedName(), _pd, mixinType).getDeclaration() as MixinDeclaration;
      } catch (_) {
        // suppress error
      }

      if (mixinDeclaration != null) {
        final method = _findMatchingMethodInMixin(mixinDeclaration, methodName, methodSignature);
        if (method != null) {
          return method;
        }
      }
    }
    
    return null;
  }

  /// Find matching method in a class
  MethodDeclaration? _findMatchingMethod(ClassDeclaration clazz, String methodName, String methodSignature) {
    final methods = clazz.getMethods();
    
    for (final method in methods) {
      if (method.getName() == methodName && !method.getIsStatic() && _createMethodSignature(method) == methodSignature) {
        return method;
      }
    }
    
    return null;
  }

  /// Find matching method in a mixin
  MethodDeclaration? _findMatchingMethodInMixin(MixinDeclaration mixin, String methodName, String methodSignature) {
    final methods = mixin.getMethods();
    
    for (final method in methods) {
      if (method.getName() == methodName && 
          !method.getIsStatic() && 
          _createMethodSignature(method) == methodSignature) {
        return method;
      }
    }
    
    return null;
  }

  /// Create a method signature for comparison
  String _createMethodSignature(MethodDeclaration method) {
    final parameters = method.getParameters();
    final paramSignatures = <String>[];
    
    for (final param in parameters) {
      final paramName = param.getName();
      final isOptional = param.getIsNullable();
      final isNamed = param.getIsNamed();
      
      String paramSignature = param.getLinkDeclaration().getName();
      
      if (isNamed) {
        paramSignature = '{$paramSignature $paramName}';
      } else if (isOptional) {
        paramSignature = '[$paramSignature $paramName]';
      } else {
        paramSignature = '$paramSignature $paramName';
      }
      
      paramSignatures.add(paramSignature);
    }
    
    final returnType = method.getReturnType().getName();
    final methodName = method.getName();
    final isGetter = method.getIsGetter();
    final isSetter = method.getIsSetter();
    
    String signature = '$returnType $methodName(${paramSignatures.join(', ')})';
    
    if (isGetter) {
      signature = 'get $signature';
    } else if (isSetter) {
      signature = 'set $signature';
    }
    
    return signature;
  }

  @override
  List<Object?> equalizedProperties() {
    return [
      _declaration.getName(),
      _declaration.getIsStatic(),
      _declaration.getIsGetter(),
      _declaration.getIsSetter(),
      _declaration.getIsPublic(),
      _declaration.getIsSynthetic(),
      _declaration.getType(),
    ];
  }

  @override
  String toString() => 'Method(${getName()})';
}

/// Extensions to support method override detection
extension MethodOverrideExtensions on MethodDeclaration {
  /// Check if this method has the same signature as another method
  bool hasSameSignature(MethodDeclaration other) {
    // Check method name
    if (getName() != other.getName()) return false;
    
    // Check getter/setter status
    if (getIsGetter() != other.getIsGetter()) return false;
    if (getIsSetter() != other.getIsSetter()) return false;
    
    // Check parameters
    final thisParams = getParameters();
    final otherParams = other.getParameters();
    
    if (thisParams.length != otherParams.length) return false;
    
    for (int i = 0; i < thisParams.length; i++) {
      final thisParam = thisParams[i];
      final otherParam = otherParams[i];
      
      // Check parameter type
      if (thisParam.getLinkDeclaration().getName() != otherParam.getLinkDeclaration().getName()) {
        return false;
      }
      
      // Check parameter name (important for named parameters)
      if (thisParam.getName() != otherParam.getName()) {
        return false;
      }
      
      // Check parameter modifiers
      if (thisParam.getIsNullable() != otherParam.getIsNullable()) {
        return false;
      }
      
      if (thisParam.getIsNamed() != otherParam.getIsNamed()) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Check if this method can override another method (considering covariance)
  bool canOverride(MethodDeclaration other) {
    // Must have same signature
    if (!hasSameSignature(other)) return false;
    
    // Static methods cannot be overridden
    if (other.getIsStatic()) return false;
    
    // Check return type covariance (return type can be more specific)
    final thisReturnType = getReturnType();
    final otherReturnType = other.getReturnType();
    
    // For now, we'll do exact matching, but this could be enhanced
    // to support covariant return types
    return thisReturnType.getName() == otherReturnType.getName();
  }
}