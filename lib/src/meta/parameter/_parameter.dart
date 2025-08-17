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

part of 'parameter.dart';

class _Parameter extends Parameter {
  final ParameterDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Parameter(this._declaration, this._pd);
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_METHODS);
    return _declaration.getName();
  }
  
  @override
  Class<P> getClass<P>() {
    checkAccess('getType', DomainPermission.READ_METHODS);
    return Class.declared<P>(_declaration.getTypeDeclaration(), _pd);
  }

  @override
  Type getType() {
    checkAccess('getType', DomainPermission.READ_METHODS);
    return _declaration.getType();
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
  int getIndex() {
    checkAccess('getIndex', DomainPermission.READ_METHODS);
    return _declaration.getIndex();
  }
  
  @override
  bool isOptional() {
    checkAccess('isOptional', DomainPermission.READ_METHODS);
    return _declaration.getIsOptional();
  }
  
  @override
  bool isNamed() {
    checkAccess('isNamed', DomainPermission.READ_METHODS);
    return _declaration.getIsNamed();
  }
  
  @override
  bool isPositional() {
    checkAccess('isPositional', DomainPermission.READ_METHODS);
    return !_declaration.getIsNamed();
  }
  
  @override
  bool isRequired() {
    checkAccess('isRequired', DomainPermission.READ_METHODS);
    return !_declaration.getIsOptional();
  }
  
  @override
  bool hasDefaultValue() {
    checkAccess('hasDefaultValue', DomainPermission.READ_METHODS);
    return _declaration.getHasDefaultValue();
  }
  
  @override
  dynamic getDefaultValue() {
    checkAccess('getDefaultValue', DomainPermission.READ_METHODS);
    return _declaration.getDefaultValue();
  }
  
  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_METHODS);
    final typeStr = getClass().getName();
    final nameStr = getName();
    
    if (isNamed()) {
      return '{$typeStr $nameStr}';
    } else if (isOptional()) {
      return '[$typeStr $nameStr]';
    } else {
      return '$typeStr $nameStr';
    }
  }
  
  @override
  String toString() => 'Parameter(${getName()}: ${getClass().getName()})';
}