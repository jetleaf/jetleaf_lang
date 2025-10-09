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

part of '../meta/annotation.dart';

class _Annotation extends Annotation {
  final AnnotationDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Annotation(this._declaration, this._pd);

  // ============================================== COMMON METHODS ========================================
  
  @override
  Type getType() {
    checkAccess('getType', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getType();
  }
  
  @override
  Class getClass() {
    checkAccess('getType', DomainPermission.READ_ANNOTATIONS);
    
    try {
      return Class.fromQualifiedName(_declaration.getLinkDeclaration().getPointerQualifiedName(), _pd);
    } catch (_) {
      try {
        return Class.forType(_declaration.getLinkDeclaration().getPointerType(), _pd);
      } catch (_) {
        return Class.forType(_declaration.getLinkDeclaration().getType(), _pd);
      }
    }
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _pd;
  
  @override
  List<String> getFieldNames() {
    checkAccess('getFieldNames', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getFieldNames();
  }

  // ========================================= VALUE PROVIDERS ============================================

  @override
  dynamic getDefaultValue(String fieldName) {
    checkAccess('getDefaultValue', DomainPermission.READ_ANNOTATIONS);
    final field = _declaration.getField(fieldName);
    return field?.getDefaultValue();
  }
  
  @override
  dynamic getUserProvidedValue(String fieldName) {
    checkAccess('getUserProvidedValue', DomainPermission.READ_ANNOTATIONS);
    final field = _declaration.getField(fieldName);
    return field?.getUserProvidedValue();
  }

  @override
  dynamic getFieldValue(String fieldName) {
    checkAccess('getFieldValue', DomainPermission.READ_ANNOTATIONS);
    final field = _declaration.getField(fieldName);
    return field?.getValue();
  }
  
  @override
  T? getFieldValueAs<T>(String fieldName) {
    checkAccess('getFieldValueAs', DomainPermission.READ_ANNOTATIONS);
    final value = getFieldValue(fieldName);
    return value is T ? value : null;
  }

  @override
  Map<String, dynamic> getUserProvidedValues() {
    checkAccess('getUserProvidedValues', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getUserProvidedValues();
  }
  
  @override
  Map<String, dynamic> getAllFieldValues() {
    checkAccess('getAllFieldValues', DomainPermission.READ_ANNOTATIONS);
    final values = <String, dynamic>{};
    
    for (final fieldName in getFieldNames()) {
      final field = _declaration.getField(fieldName);
      if (field != null) {
        values[fieldName] = field.getValue();
      }
    }
    
    return values;
  }

  // ======================================== HELPER METHODS ==============================================
  
  @override
  bool hasField(String fieldName) {
    checkAccess('hasField', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getField(fieldName) != null;
  }
  
  @override
  bool hasUserProvidedValue(String fieldName) {
    checkAccess('hasUserProvidedValue', DomainPermission.READ_ANNOTATIONS);
    final field = _declaration.getField(fieldName);
    return field?.hasUserProvidedValue() ?? false;
  }
  
  @override
  bool hasDefaultValue(String fieldName) {
    checkAccess('hasDefaultValue', DomainPermission.READ_ANNOTATIONS);
    final field = _declaration.getField(fieldName);
    return field?.hasDefaultValue() ?? false;
  }

  @override
  List<Field> getFields() {
    checkAccess('getFields', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getFields().map((f) => Field.declared(f, _declaration, _pd)).toList();
  }

  @override
  Field getField(String name) {
    checkAccess('getField', DomainPermission.READ_ANNOTATIONS);
    final field = _declaration.getField(name);
    
    if(field == null) {
      throw IllegalArgumentException('Field $name not found');
    }

    return Field.declared(field, _declaration, _pd);
  }

  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_ANNOTATIONS);
    final typeName = getClass().getName();
    final userValues = getAllFieldValues();
    
    if (userValues.isEmpty) {
      return '@$typeName';
    }
    
    final valueStr = userValues.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    
    return '@$typeName($valueStr)';
  }

  // ============================================= INSTANCE CREATOR ========================================
  
  @override
  Instance getInstance<Instance>() {
    checkAccess('getInstance', DomainPermission.READ_ANNOTATIONS);
    return _declaration.getInstance() as Instance;
  }
  
  @override
  String toString() => 'Annotation(${getClass().getName()})';
}