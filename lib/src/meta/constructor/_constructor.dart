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

part of 'constructor.dart';

class _Constructor extends Constructor with EqualsAndHashCode {
  final ConstructorDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Constructor(this._declaration, this._pd);
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getName();
  }
  
  @override
  ConstructorDeclaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_CONSTRUCTORS);
    return _declaration;
  }

  @override
  List<String> getModifiers() {
    checkAccess('getModifiers', DomainPermission.READ_CONSTRUCTORS);

    return [
      if (isPublic()) 'PUBLIC',
      if (!isPublic()) 'PRIVATE',
      if (isConst()) 'CONST',
      if (isFactory()) 'FACTORY',
    ];
  }

  @override
  Class<D> getDeclaringClass<D>() {
    checkAccess('getDeclaringClass', DomainPermission.READ_CONSTRUCTORS);
    
    final link = _declaration.getParentClass();
    if(link == null) {
      throw IllegalStateException('Constructor ${getName()} has no declaring class');
    }
    return Class.fromQualifiedName<D>(link.getPointerQualifiedName(), _pd, link);
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
  Class<Object> getReturnClass() {
    checkAccess('getReturnClass', DomainPermission.READ_CONSTRUCTORS);
    
    final link = _declaration.getParentClass();
    if(link == null) {
      throw IllegalStateException('Constructor ${getName()} has no return class');
    }
    return Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link);
  }
  
  @override
  Type getReturnType() {
    checkAccess('getReturnType', DomainPermission.READ_CONSTRUCTORS);
    
    final link = _declaration.getParentClass();
    if(link == null) {
      throw IllegalStateException('Constructor ${getName()} has no return type');
    }
    return Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link).getType();
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _pd;

  @override
  List<Annotation> getAllDirectAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);

    final annotations = _declaration.getAnnotations();
    return UnmodifiableListView(annotations.map((a) => Annotation.declared(a, getProtectionDomain())));
  }

  // =========================================== PARAMETER METHODS ===========================================
  
  @override
  List<Parameter> getParameters() {
    checkAccess('getParameters', DomainPermission.READ_CONSTRUCTORS);
    return UnmodifiableListView(_declaration.getParameters().map((p) => Parameter.declared(p, this, _pd)));
  }
  
  @override
  int getParameterCount() {
    checkAccess('getParameterCount', DomainPermission.READ_CONSTRUCTORS);
    return getParameters().length;
  }
  
  @override
  Parameter? getParameter(String name) {
    checkAccess('getParameter', DomainPermission.READ_CONSTRUCTORS);

    final parameters = _declaration.getParameters();
    final parameter = parameters.where((p) => p.getName() == name).firstOrNull;
    return parameter != null ? Parameter.declared(parameter, this, _pd) : null;
  }
  
  @override
  Parameter? getParameterAt(int index) {
    checkAccess('getParameterAt', DomainPermission.READ_CONSTRUCTORS);

    final parameters = _declaration.getParameters();
    if (index < 0 || index >= parameters.length) return null;
    return Parameter.declared(parameters[index], this, _pd);
  }
  
  @override
  List<Class> getParameterTypes() {
    checkAccess('getParameterTypes', DomainPermission.READ_CONSTRUCTORS);
    return getParameters().map((p) => p.getReturnClass()).toList();
  }

  // =========================================== HELPER METHODS ============================================
  
  @override
  bool isFactory() {
    checkAccess('isFactory', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getIsFactory();
  }
  
  @override
  bool isConst() {
    checkAccess('isConst', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getIsConst();
  }

  @override
  bool isPublic() {
    checkAccess('isPublic', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsPublic();
  }

  @override
  bool canAcceptArguments(Map<String, dynamic> arguments) {
    checkAccess('canAcceptArguments', DomainPermission.READ_CONSTRUCTORS);
    return MethodUtils.canAcceptArguments(arguments, getParameters());
  }

  @override
  bool canAcceptPositionalArguments(List<dynamic> args) {
    checkAccess('canAcceptPositionalArguments', DomainPermission.READ_CONSTRUCTORS);
    return MethodUtils.canAcceptPositionalArguments(args, getParameters());
  }

  @override
  bool canAcceptNamedArguments(Map<String, dynamic> arguments) {
    checkAccess('canAcceptNamedArguments', DomainPermission.READ_CONSTRUCTORS);
    return MethodUtils.canAcceptNamedArguments(arguments, getParameters());
  }

  // ========================================== INSTANCE CREATORS =============================================
  
  @override
  Instance newInstance<Instance>([Map<String, dynamic>? arguments, List<dynamic> args = const []]) {
    checkAccess('newInstance', DomainPermission.CREATE_INSTANCES);

    // 1. Try instantiation with positional arguments if provided
    if(args.isNotEmpty && arguments == null) {
      final parameters = _declaration.getParameters();
      final result = <String, dynamic>{};
      
      // Map positional arguments to parameter names
      for (int i = 0; i < args.length && i < parameters.length; i++) {
        if (!parameters[i].getIsNamed()) {
          result[parameters[i].getName()] = args[i];
        }
      }
      
      return _declaration.newInstance<Instance>(result);
    }

    // 2. Try instantiation with named and positional arguments if provided
    if(args.isNotEmpty && arguments != null) {
      final parameters = _declaration.getParameters();
      final result = <String, dynamic>{};
      
      // Map positional arguments to parameter names
      for (int i = 0; i < args.length && i < parameters.length; i++) {
        if (!parameters[i].getIsNamed()) {
          result[parameters[i].getName()] = args[i];
        }
      }

      // Map named arguments to parameter names
      for (int i = 0; i < arguments.length && i < parameters.length; i++) {
        if (parameters[i].getIsNamed()) {
          final name = parameters[i].getName();
          result[name] = arguments[name];
        }
      }

      return _declaration.newInstance<Instance>(result);
    }

    // 3. Try instantiation with named arguments if provided or we assume that the constructor has no parameters.
    return _declaration.newInstance<Instance>(arguments ?? {});
  }

  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_CONSTRUCTORS);
    final paramTypes = getParameters().map((t) => "${t.getReturnClass().getName()} ${t.getName()}").join(', ');
    final name = getName();

    if (name.isEmpty) {
      return '${getDeclaringClass().getName()}($paramTypes)';
    }

    if (isPublic()) {
      return '${getDeclaringClass().getName()} ${getName()}($paramTypes)';
    }

    return '${getDeclaringClass().getName()}${getName()}($paramTypes)';
  }

  @override
  List<Object?> equalizedProperties() {
    return [
      _declaration.getName(),
      getSignature(),
      _declaration.getDebugIdentifier(),
      _declaration.getType(),
    ];
  }
  
  @override
  String toString() => 'Constructor(${getName()})';
}