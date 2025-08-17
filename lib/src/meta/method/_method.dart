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

class _Method extends Method {
  final MethodDeclaration _declaration;
  final ProtectionDomain _pd;
  
  // Cache for override detection to avoid repeated traversals
  bool? _isOverrideCache;
  Method? _overriddenMethodCache;
  
  _Method(this._declaration, this._pd);

  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_METHODS);
    return _declaration.getName();
  }

  @override
  Class<D> getDeclaringClass<D>() {
    checkAccess('getDeclaringClass', DomainPermission.READ_METHODS);
    final parentClass = _declaration.getParentClass();
    if (parentClass == null) {
      throw IllegalStateException('Method ${getName()} has no declaring class');
    }
    return Class.declared<D>(parentClass, _pd);
  }

  @override
  ProtectionDomain getProtectionDomain() => _pd;

  @override
  List<Annotation> getAllAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = _declaration.getAnnotations();
    return annotations.map((a) => Annotation.declared(a, getProtectionDomain())).toList();
  }

  @override
  Class<R> getReturnClass<R>() {
    checkAccess('getReturnType', DomainPermission.READ_METHODS);
    return Class.fromQualifiedName<R>(_declaration.getReturnType().getQualifiedName(), _pd);
  }

  @override
  Type getReturnType() {
    checkAccess('getReturnType', DomainPermission.READ_METHODS);
    return _declaration.getReturnType().getType();
  }

  @override
  List<Parameter> getParameters() {
    checkAccess('getParameters', DomainPermission.READ_METHODS);
    return _declaration.getParameters().map((p) => Parameter.declared(p, _pd)).toList();
  }

  @override
  int getParameterCount() {
    checkAccess('getParameterCount', DomainPermission.READ_METHODS);
    return _declaration.getParameters().length;
  }

  @override
  Parameter? getParameter(String name) {
    checkAccess('getParameter', DomainPermission.READ_METHODS);
    final parameters = _declaration.getParameters();
    final parameter = parameters.where((p) => p.getName() == name).firstOrNull;
    return parameter != null ? Parameter.declared(parameter, _pd) : null;
  }

  @override
  Parameter? getParameterAt(int index) {
    checkAccess('getParameterAt', DomainPermission.READ_METHODS);
    final parameters = _declaration.getParameters();
    if (index < 0 || index >= parameters.length) return null;
    return Parameter.declared(parameters[index], _pd);
  }

  @override
  List<Class> getParameterTypes() {
    checkAccess('getParameterTypes', DomainPermission.READ_METHODS);
    return _declaration.getParameters().map((p) => Class.fromQualifiedName(p.getTypeDeclaration().getQualifiedName(), _pd)).toList();
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
  bool isConst() {
    checkAccess('isConst', DomainPermission.READ_METHODS);
    return _declaration.getIsConst();
  }

  @override
  bool isFactory() {
    checkAccess('isFactory', DomainPermission.READ_METHODS);
    return _declaration.getIsFactory();
  }

  @override
  dynamic invoke(Object? instance, [Map<String, dynamic>? arguments]) {
    checkAccess('invoke', DomainPermission.INVOKE_METHODS);
    return _declaration.invoke(instance, arguments ?? {});
  }

  @override
  dynamic invokeWithArgs(Object? instance, List<dynamic> args) {
    checkAccess('invokeWithArgs', DomainPermission.INVOKE_METHODS);
    final parameters = _declaration.getParameters();
    final arguments = <String, dynamic>{};

    // Map positional arguments to parameter names
    for (int i = 0; i < args.length && i < parameters.length; i++) {
      if (!parameters[i].getIsNamed()) {
        arguments[parameters[i].getName()] = args[i];
      }
    }
    return _declaration.invoke(instance, arguments);
  }

  @override
  bool canAcceptArguments(Map<String, dynamic> arguments) {
    checkAccess('canAcceptArguments', DomainPermission.READ_METHODS);
    final parameters = _declaration.getParameters();

    // Check if all required parameters are provided
    for (final param in parameters) {
      if (!param.getIsOptional() && !arguments.containsKey(param.getName())) {
        return false;
      }
    }

    // Check if all provided arguments have corresponding parameters
    for (final argName in arguments.keys) {
      if (!parameters.any((p) => p.getName() == argName)) {
        return false;
      }
    }
    return true;
  }

  @override
  bool canAcceptPositionalArguments(List<dynamic> args) {
    checkAccess('canAcceptPositionalArguments', DomainPermission.READ_METHODS);
    final parameters = _declaration.getParameters();
    final positionalParams = parameters.where((p) => !p.getIsNamed()).toList();
    final requiredPositionalCount = positionalParams.where((p) => !p.getIsOptional()).length;
    return args.length >= requiredPositionalCount && args.length <= positionalParams.length;
  }

  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_METHODS);
    final paramTypes = getParameterTypes().map((t) => t.getName()).join(', ');
    return '${getReturnClass().getName()} ${getName()}($paramTypes)';
  }

  @override
  bool isOverride() {
    checkAccess('isOverride', DomainPermission.READ_METHODS);
    
    // Use cached result if available
    if (_isOverrideCache != null) {
      return _isOverrideCache!;
    }
    
    // Static methods cannot be overridden
    if (isStatic()) {
      _isOverrideCache = false;
      return false;
    }
    
    // Constructors cannot be overridden
    if (_declaration.getName().isEmpty || _declaration.getName() == _declaration.getParentClass()?.getName()) {
      _isOverrideCache = false;
      return false;
    }
    
    // Check if this method overrides a method from superclass or interfaces
    final overriddenMethod = _findOverriddenMethod();
    _isOverrideCache = overriddenMethod != null;
    return _isOverrideCache!;
  }

  @override
  Method? getOverriddenMethod() {
    checkAccess('getOverriddenMethod', DomainPermission.READ_METHODS);
    
    // Use cached result if available
    if (_overriddenMethodCache != null) {
      return _overriddenMethodCache;
    }
    
    // Static methods cannot be overridden
    if (isStatic()) {
      return null;
    }
    
    // Find the overridden method
    final overriddenDeclaration = _findOverriddenMethod();
    if (overriddenDeclaration != null) {
      _overriddenMethodCache = Method.declared(overriddenDeclaration, _pd);
    }
    
    return _overriddenMethodCache;
  }

  /// Internal method to find the overridden method declaration
  MethodDeclaration? _findOverriddenMethod() {
    final parentClass = _declaration.getParentClass();
    if (parentClass == null) return null;
    
    final methodName = _declaration.getName();
    final methodSignature = _createMethodSignature(_declaration);
    
    // Search in superclass hierarchy
    final superclassMethod = _searchInSuperclassHierarchy(parentClass, methodName, methodSignature);
    if (superclassMethod != null) {
      return superclassMethod;
    }
    
    // Search in implemented interfaces
    final interfaceMethod = _searchInInterfaces(parentClass, methodName, methodSignature);
    if (interfaceMethod != null) {
      return interfaceMethod;
    }
    
    // Search in mixed-in types
    final mixinMethod = _searchInMixins(parentClass, methodName, methodSignature);
    
    return mixinMethod;
  }

  /// Search for method in superclass hierarchy
  MethodDeclaration? _searchInSuperclassHierarchy(ClassDeclaration currentClass, String methodName, String methodSignature) {
    final supertype = currentClass.getSuperClass();
    if (supertype == null) return null;
    
    final superclass = Class.forType(supertype.getPointerType()).getDeclaration().asClass();
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
      final interfaceClass = Class.forType(interfaceType.getPointerType()).getDeclaration().asClass();
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
      final mixinDeclaration = Class.forType(mixinType.getPointerType()).getDeclaration().asMixin();
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
      final isOptional = param.getIsOptional();
      final isNamed = param.getIsNamed();
      
      String paramSignature = param.getTypeDeclaration().getName();
      
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
      if (thisParam.getTypeDeclaration().getName() != otherParam.getTypeDeclaration().getName()) {
        return false;
      }
      
      // Check parameter name (important for named parameters)
      if (thisParam.getName() != otherParam.getName()) {
        return false;
      }
      
      // Check parameter modifiers
      if (thisParam.getIsOptional() != otherParam.getIsOptional()) {
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