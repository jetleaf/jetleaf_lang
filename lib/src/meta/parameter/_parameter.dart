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

class _Parameter extends Parameter with EqualsAndHashCode {
  final ParameterDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Parameter(this._declaration, this._pd);
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_METHODS);
    return _declaration.getName();
  }

  @override
  Declaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_METHODS);
    return _declaration;
  }
  
  @override
  Class<Object> getClass() {
    checkAccess('getType', DomainPermission.READ_METHODS);
    try {
      final link = _declaration.getLinkDeclaration();
      return Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link);
    } catch (e) {
      return Class.forType(_declaration.getType());
    }
  }

  @override
  Member getMember() {
    checkAccess('getMember', DomainPermission.READ_METHODS);
    
    if(_declaration.getMemberDeclaration() is ConstructorDeclaration) {
      return Constructor.declared(_declaration.getMemberDeclaration() as ConstructorDeclaration, _pd);
    }
    
    if(_declaration.getMemberDeclaration() is MethodDeclaration) {
      return Method.declared(_declaration.getMemberDeclaration() as MethodDeclaration, _pd);
    }
    
    if(_declaration.getMemberDeclaration() is FieldDeclaration) {
      final field = _declaration.getMemberDeclaration() as FieldDeclaration;
      final parent = field.getParentClass();
      
      if(parent != null) {
        return Field.declared(field, parent, _pd);
      }
    }
    
    throw IllegalArgumentException('Member not found');
  }

  @override
  Type getType() {
    checkAccess('getType', DomainPermission.READ_METHODS);
    return _declaration.getType();
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _pd;

  @override
  List<Annotation> getAllDirectAnnotations() {
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
  List<String> getModifiers() => [
    if (isPublic()) 'PUBLIC',
    if (!isPublic()) 'PRIVATE',
    if (isOptional()) 'OPTIONAL',
    if (isNamed()) 'NAMED',
    if (isPositional()) 'POSITIONAL',
    if (isRequired()) 'REQUIRED',
  ];
  
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
  bool isPublic() {
    checkAccess('isPublic', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsPublic();
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
  List<Object?> equalizedProperties() {
    return [
      _declaration.getName(),
      getSignature(),
      _declaration.getIsOptional(),
      _declaration.getIsNamed(),
      _declaration.getIsSynthetic(),
      _declaration.getIndex(),
      _declaration.getHasDefaultValue(),
      _declaration.getDefaultValue(),
    ];
  }
  
  @override
  String toString() => 'Parameter(${getName()}: ${getClass().getName()})';
}