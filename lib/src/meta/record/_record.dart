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

part of 'record.dart';

class _Record extends Record {
  final RecordDeclaration _declaration;
  final ProtectionDomain _protectionDomain;
  
  _Record(this._declaration, this._protectionDomain);
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_TYPE_INFO);
    return _declaration.getName();
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _protectionDomain;

  @override
  List<Annotation> getAllAnnotations() {
    _protectionDomain.checkAccess('getAnnotations', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getAnnotations().map((a) => Annotation.declared(a, _protectionDomain)).toList();
  }
  
  @override
  List<RecordField> getPositionalFields() {
    checkAccess('getPositionalFields', DomainPermission.READ_FIELDS);
    return _declaration.getPositionalFields()
        .map((f) => RecordField.declared(f, _protectionDomain))
        .toList();
  }
  
  @override
  Map<String, RecordField> getNamedFields() {
    checkAccess('getNamedFields', DomainPermission.READ_FIELDS);
    final namedFields = <String, RecordField>{};
    
    for (final entry in _declaration.getNamedFields().entries) {
      namedFields[entry.key] = RecordField.declared(entry.value, _protectionDomain);
    }
    
    return namedFields;
  }
  
  @override
  RecordField? getPositionalField(int index) {
    checkAccess('getPositionalField', DomainPermission.READ_FIELDS);
    final field = _declaration.getPositionalField(index);
    return field != null ? RecordField.declared(field, _protectionDomain) : null;
  }
  
  @override
  RecordField? getNamedField(String name) {
    checkAccess('getNamedField', DomainPermission.READ_FIELDS);
    final field = _declaration.getField(name);
    return field != null ? RecordField.declared(field, _protectionDomain) : null;
  }
  
  @override
  int getFieldCount() {
    checkAccess('getFieldCount', DomainPermission.READ_FIELDS);
    return getPositionalFieldCount() + getNamedFieldCount();
  }
  
  @override
  int getPositionalFieldCount() {
    checkAccess('getPositionalFieldCount', DomainPermission.READ_FIELDS);
    return _declaration.getPositionalFields().length;
  }
  
  @override
  int getNamedFieldCount() {
    checkAccess('getNamedFieldCount', DomainPermission.READ_FIELDS);
    return _declaration.getNamedFields().length;
  }
  
  @override
  bool hasPositionalFields() {
    checkAccess('hasPositionalFields', DomainPermission.READ_FIELDS);
    return getPositionalFieldCount() > 0;
  }
  
  @override
  bool hasNamedFields() {
    checkAccess('hasNamedFields', DomainPermission.READ_FIELDS);
    return getNamedFieldCount() > 0;
  }
  
  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_TYPE_INFO);
    final positional = getPositionalFields().map((f) => f.getClass().getName()).join(', ');
    final named = getNamedFields().entries.map((e) => '${e.value.getClass().getName()} ${e.key}').join(', ');
    
    if (named.isEmpty) {
      return '($positional)';
    } else if (positional.isEmpty) {
      return '({$named})';
    } else {
      return '($positional, {$named})';
    }
  }
  
  @override
  String toString() => 'Record(${getName()})';
}