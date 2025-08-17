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

class _Constructor extends Constructor {
  final ConstructorDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Constructor(this._declaration, this._pd);
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getName();
  }
  
  @override
  Class<D> getDeclaringClass<D>() {
    checkAccess('getDeclaringClass', DomainPermission.READ_CONSTRUCTORS);
    return Class.declared<D>(_declaration.getParentClass()!, _pd);
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _pd;

  @override
  @override
  List<Annotation> getAllAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = _declaration.getAnnotations();
    return annotations.map((a) => Annotation.declared(a, getProtectionDomain())).toList();
  }

  // =========================================== PARAMETER METHODS ===========================================
  
  @override
  List<Parameter> getParameters() {
    checkAccess('getParameters', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getParameters().map((p) => Parameter.declared(p, _pd)).toList();
  }
  
  @override
  int getParameterCount() {
    checkAccess('getParameterCount', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getParameters().length;
  }
  
  @override
  Parameter? getParameter(String name) {
    checkAccess('getParameter', DomainPermission.READ_CONSTRUCTORS);

    final parameters = _declaration.getParameters();
    final parameter = parameters.where((p) => p.getName() == name).firstOrNull;
    return parameter != null ? Parameter.declared(parameter, _pd) : null;
  }
  
  @override
  Parameter? getParameterAt(int index) {
    checkAccess('getParameterAt', DomainPermission.READ_CONSTRUCTORS);

    final parameters = _declaration.getParameters();
    if (index < 0 || index >= parameters.length) return null;
    return Parameter.declared(parameters[index], _pd);
  }
  
  @override
  List<Class> getParameterTypes() {
    checkAccess('getParameterTypes', DomainPermission.READ_CONSTRUCTORS);
    return _declaration.getParameters().map((p) => Class.declared(p.getTypeDeclaration(), _pd)).toList();
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
  bool canAcceptArguments(Map<String, dynamic> arguments) {
    checkAccess('canAcceptArguments', DomainPermission.READ_CONSTRUCTORS);

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
    checkAccess('canAcceptPositionalArguments', DomainPermission.READ_CONSTRUCTORS);

    final parameters = _declaration.getParameters();
    final positionalParams = parameters.where((p) => !p.getIsNamed()).toList();
    final requiredPositionalCount = positionalParams.where((p) => !p.getIsOptional()).length;
    
    return args.length >= requiredPositionalCount && args.length <= positionalParams.length;
  }

  // ========================================== INSTANCE CREATORS =============================================
  
  @override
  Instance newInstance<Instance>([Map<String, dynamic>? arguments]) {
    checkAccess('newInstance', DomainPermission.CREATE_INSTANCES);
    return _declaration.newInstance<Instance>(arguments ?? {});
  }

  @override
  Instance newInstanceWithArgs<Instance>(List<dynamic> args) {
    checkAccess('newInstanceWithArgs', DomainPermission.CREATE_INSTANCES);
    final parameters = _declaration.getParameters();
    final arguments = <String, dynamic>{};
    
    // Map positional arguments to parameter names
    for (int i = 0; i < args.length && i < parameters.length; i++) {
      if (!parameters[i].getIsNamed()) {
        arguments[parameters[i].getName()] = args[i];
      }
    }
    
    return _declaration.newInstance<Instance>(arguments);
  }

  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_CONSTRUCTORS);
    final paramTypes = getParameterTypes().map((t) => t.getName()).join(', ');
    return '${getName()}($paramTypes)';
  }
  
  @override
  String toString() => 'Constructor(${getName()})';
}