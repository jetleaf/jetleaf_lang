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

part of 'field.dart';

class _Field extends Field {
  final FieldDeclaration _declaration;
  final ProtectionDomain _pd;
  
  _Field(this._declaration, this._pd);
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_FIELDS);
    return _declaration.getName();
  }
  
  @override
  Class<T> getClass<T>() {
    checkAccess('getType', DomainPermission.READ_FIELDS);
    return Class.declared<T>(_declaration.getTypeDeclaration(), _pd);
  }

  @override
  Type getType() {
    checkAccess('getType', DomainPermission.READ_FIELDS);
    return _declaration.getType();
  }
  
  @override
  Class<D> getDeclaringClass<D>() {
    checkAccess('getDeclaringClass', DomainPermission.READ_FIELDS);

    final parentClass = _declaration.getParentClass();
    if (parentClass == null) {
      throw IllegalStateException('Field ${getName()} has no declaring class');
    }

    return Class.declared<D>(parentClass, _pd);
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
  
  @override
  bool isStatic() {
    checkAccess('isStatic', DomainPermission.READ_FIELDS);
    return _declaration.getIsStatic();
  }
  
  @override
  bool isFinal() {
    checkAccess('isFinal', DomainPermission.READ_FIELDS);
    return _declaration.getIsFinal();
  }
  
  @override
  bool isConst() {
    checkAccess('isConst', DomainPermission.READ_FIELDS);
    return _declaration.getIsConst();
  }
  
  @override
  bool isLate() {
    checkAccess('isLate', DomainPermission.READ_FIELDS);
    return _declaration.getIsLate();
  }
  
  @override
  bool isAbstract() {
    checkAccess('isAbstract', DomainPermission.READ_FIELDS);
    return _declaration.getIsAbstract();
  }
  
  @override
  dynamic getValue(Object? instance) {
    checkAccess('getValue', DomainPermission.READ_FIELDS);
    return _declaration.getValue(instance);
  }
  
  @override
  void setValue(Object? instance, dynamic value) {
    checkAccess('setValue', DomainPermission.WRITE_FIELDS);
    _declaration.setValue(instance, value);
  }
  
  @override
  T? getValueAs<T>(Object? instance) {
    checkAccess('getValueAs', DomainPermission.READ_FIELDS);
    final value = getValue(instance);
    return value is T ? value : null;
  }
  
  @override
  void setValueWithTypeCheck(Object? instance, dynamic value) {
    checkAccess('setValueWithTypeCheck', DomainPermission.WRITE_FIELDS);
    final fieldType = getClass();
    
    if (value != null && !fieldType.isInstance(value)) {
      throw IllegalStateException('Value of type ${value.runtimeType} cannot be assigned to field of type ${fieldType.getName()}');
    }
    
    setValue(instance, value);
  }
  
  @override
  bool isReadable() {
    checkAccess('isReadable', DomainPermission.READ_FIELDS);
    return true; // All fields in Dart are readable
  }
  
  @override
  bool isWritable() {
    checkAccess('isWritable', DomainPermission.READ_FIELDS);
    return !isFinal() && !isConst();
  }
  
  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_FIELDS);
    final modifiers = <String>[];
    
    if (isStatic()) modifiers.add('static');
    if (isFinal()) modifiers.add('final');
    if (isConst()) modifiers.add('const');
    if (isLate()) modifiers.add('late');
    
    final modifierStr = modifiers.isEmpty ? '' : '${modifiers.join(' ')} ';
    return '$modifierStr${getClass().getName()} ${getName()}';
  }
  
  @override
  String toString() => 'Field(${getName()})';
}