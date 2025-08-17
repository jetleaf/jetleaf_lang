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

part of 'record_field.dart';

class _RecordField extends RecordField {
  final RecordFieldDeclaration _reflectedField;
  final ProtectionDomain _protectionDomain;
  
  _RecordField(this._reflectedField, this._protectionDomain);
  
  @override
  String getName() {
    _protectionDomain.checkAccess('getName', DomainPermission.READ_FIELDS);
    return _reflectedField.getName();
  }
  
  @override
  Class<T> getClass<T>() {
    _protectionDomain.checkAccess('getType', DomainPermission.READ_FIELDS);
    return Class.declared<T>(_reflectedField.getTypeDeclaration(), _protectionDomain);
  }

  @override
  Type getType() {
    _protectionDomain.checkAccess('getType', DomainPermission.READ_FIELDS);
    return _reflectedField.getType();
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _protectionDomain;
  
  @override
  int? getPosition() {
    _protectionDomain.checkAccess('getPosition', DomainPermission.READ_FIELDS);
    return _reflectedField.getPosition();
  }
  
  @override
  bool isNamed() {
    _protectionDomain.checkAccess('isNamed', DomainPermission.READ_FIELDS);
    return _reflectedField.getIsNamed();
  }
  
  @override
  bool isPositional() {
    _protectionDomain.checkAccess('isPositional', DomainPermission.READ_FIELDS);
    return _reflectedField.getIsPositional();
  }
  
  @override
  List<Annotation> getAllAnnotations() {
    _protectionDomain.checkAccess('getAnnotations', DomainPermission.READ_ANNOTATIONS);
    return _reflectedField.getAnnotations().map((a) => Annotation.declared(a, _protectionDomain)).toList();
  }
  
  @override
  String getSignature() {
    _protectionDomain.checkAccess('getSignature', DomainPermission.READ_FIELDS);
    return '${getClass().getName()} ${getName()}';
  }
  
  @override
  String toString() => 'RecordField(${getName()})';
}