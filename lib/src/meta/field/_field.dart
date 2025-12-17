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

class _Field extends Field with EqualsAndHashCode {
  final Declaration _declaration;
  final Declaration _parent;
  final ProtectionDomain _pd;
  
  _Field(this._declaration, this._parent, this._pd) {
    if(asField() == null && asAnnotation() == null && asRecord() == null && asEnum() == null) {
      throw IllegalArgumentException('Declaration must be either of these: FieldDeclaration, AnnotationFieldDeclaration, RecordFieldDeclaration, or EnumFieldDeclaration');
    }
  }

  @override
  FieldDeclaration? asField() {
    checkAccess('asField', DomainPermission.READ_FIELDS);

    if(_declaration is FieldDeclaration && _parent is ClassDeclaration) {
      return _declaration;
    }

    return null;
  }

  ClassDeclaration? asFieldParent() {
    checkAccess('asFieldParent', DomainPermission.READ_FIELDS);

    if(_parent is ClassDeclaration) {
      return _parent;
    }

    return null;
  }

  AnnotationDeclaration? asAnnotationParent() {
    checkAccess('asAnnotationParent', DomainPermission.READ_FIELDS);

    if(_parent is AnnotationDeclaration) {
      return _parent;
    }

    return null;
  }

  EnumDeclaration? asEnumParent() {
    checkAccess('asEnumParent', DomainPermission.READ_FIELDS);

    if(_parent is EnumDeclaration) {
      return _parent;
    }

    return null;
  }

  @override
  AnnotationFieldDeclaration? asAnnotation() {
    checkAccess('asAnnotation', DomainPermission.READ_FIELDS);

    if(_declaration is AnnotationFieldDeclaration && _parent is AnnotationDeclaration) {
      return _declaration;
    }

    return null;
  }

  @override
  RecordFieldDeclaration? asRecord() {
    checkAccess('asRecord', DomainPermission.READ_FIELDS);

    if(_declaration is RecordFieldDeclaration && _parent is RecordLinkDeclaration) {
      return _declaration;
    }

    return null;
  }

  @override
  EnumFieldDeclaration? asEnum() {
    checkAccess('asEnum', DomainPermission.READ_FIELDS);

    if(_declaration is EnumFieldDeclaration && _parent is EnumDeclaration) {
      return _declaration;
    }

    return null;
  }
  
  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_FIELDS);
    return _declaration.getName();
  }

  @override
  Type getType() {
    checkAccess('getType', DomainPermission.READ_FIELDS);
    return _declaration.getType();
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
  List<String> getModifiers() {
    checkAccess('getModifiers', DomainPermission.READ_FIELDS);

    return [
      if (isPublic()) 'PUBLIC',
      if (!isPublic()) 'PRIVATE',
      if (isPositional()) 'POSITIONAL',
      if (isNamed()) 'NAMED',
      if (isLate()) 'LATE',
      if (isNullable()) 'NULLABLE',
      if (isStatic()) 'STATIC',
      if (isFinal()) 'FINAL',
    ];
  }
  
  @override
  Class<D> getDeclaringClass<D>() {
    checkAccess('getDeclaringClass', DomainPermission.READ_FIELDS);

    ClassDeclaration? annotationParent;
    try {
      if(asAnnotationParent() != null) {
        final link = asAnnotationParent()!.getLinkDeclaration();
        annotationParent = Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link).getClassDeclaration();
      }
    } catch (e) {
      annotationParent = null;
    }

    final parentClass = annotationParent ?? asEnumParent() ?? asFieldParent();
    if (parentClass == null) {
      throw IllegalStateException('Field ${getName()} has no declaring class');
    }

    return Class.declared<D>(parentClass, _pd);
  }
  
  @override
  ProtectionDomain getProtectionDomain() => _pd;

  @override
  Declaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_FIELDS);
    return _declaration;
  }

  @override
  Declaration getParent() {
    checkAccess('getParent', DomainPermission.READ_FIELDS);
    return _parent;
  }
  
  @override
  int getPosition() {
    checkAccess('getPosition', DomainPermission.READ_FIELDS);
    
    return asAnnotation()?.getPosition() ?? asRecord()?.getPosition() ?? asEnum()?.getPosition() ?? -1;
  }
  
  @override
  Class<Object> getReturnClass() {
    checkAccess('getDeclaringClass', DomainPermission.READ_FIELDS);

    final enumClass = asEnumParent();
    if(enumClass != null) {
      return Class.declared(enumClass, _pd);
    }

    final link = asField()?.getLinkDeclaration() ?? asAnnotation()?.getLinkDeclaration() ?? asRecord()?.getLinkDeclaration();
    if (link == null) {
      throw IllegalStateException('Field ${getName()} has no return class');
    }

    return LangUtils.obtainClassFromLink(link);
  }
  
  @override
  Type getReturnType() {
    checkAccess('getReturnType', DomainPermission.READ_TYPE_INFO);
    return getType();
  }
  
  @override
  bool isEnumField() {
    checkAccess('isEnumField', DomainPermission.READ_TYPE_INFO);
    return asEnum() != null;
  }
  
  @override
  bool isRecordField() {
    checkAccess('isRecordField', DomainPermission.READ_TYPE_INFO);
    return asRecord() != null;
  }

  @override
  bool isTopLevel() {
    checkAccess('isTopLevel', DomainPermission.READ_TYPE_INFO);
    return asField()?.getIsTopLevel() ?? false;
  }

  @override
  bool isPublic() {
    checkAccess('isPublic', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsPublic();
  }

  @override
  bool isAnnotationField() {
    checkAccess('isAnnotationField', DomainPermission.READ_TYPE_INFO);
    return asAnnotation() != null;
  }

  @override
  bool isNullable() {
    checkAccess('isNullable', DomainPermission.READ_FIELDS);
    return asField()?.isNullable() ?? asRecord()?.getIsNullable() ?? asEnum()?.isNullable() ?? asAnnotation()?.isNullable() ?? false;
  }

  @override
  List<Annotation> getAllDirectAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);

    final annotations = asField()?.getAnnotations() ?? asEnum()?.getAnnotations() ?? [];
    return UnmodifiableListView(annotations.map((a) => Annotation.declared(a, getProtectionDomain())));
  }

  @override
  bool isNamed() {
    checkAccess('isNamed', DomainPermission.READ_FIELDS);
    return asRecord()?.getIsNamed() ?? false;
  }
  
  @override
  bool isPositional() {
    checkAccess('isPositional', DomainPermission.READ_FIELDS);
    return asRecord()?.getIsPositional() ?? false;
  }
  
  @override
  bool isStatic() {
    checkAccess('isStatic', DomainPermission.READ_FIELDS);
    return asField()?.getIsStatic() ?? false;
  }
  
  @override
  bool isFinal() {
    checkAccess('isFinal', DomainPermission.READ_FIELDS);
    return asField()?.getIsFinal() ?? false;
  }
  
  @override
  bool isConst() {
    checkAccess('isConst', DomainPermission.READ_FIELDS);
    return asField()?.getIsConst() ?? false;
  }
  
  @override
  bool isLate() {
    checkAccess('isLate', DomainPermission.READ_FIELDS);
    return asField()?.getIsLate() ?? false;
  }
  
  @override
  bool isAbstract() {
    checkAccess('isAbstract', DomainPermission.READ_FIELDS);
    return asField()?.getIsAbstract() ?? false;
  }
  
  @override
  dynamic getValue([Object? instance]) {
    checkAccess('getValue', DomainPermission.READ_FIELDS);
    
    if(isEnumField()) {
      return asEnum()?.getValue();
    }
    
    if(isRecordField()) {
      // return asRecord()?.getValue(instance);
      throw UnsupportedOperationException('Record field value getter is not supported at the moment.');
    }
    
    if(isAnnotationField()) {
      return asAnnotation()?.getValue();
    }

    final instanceValue = instance ?? (isStatic() ? getDeclaringClass().getType() : null);
    return asField()?.getValue(instanceValue);
  }
  
  @override
  void setValue(Object? instance, dynamic value) {
    checkAccess('setValue', DomainPermission.WRITE_FIELDS);
    
    if(isEnumField()) {
      throw UnsupportedOperationException('Enum field value setter is not supported at the moment.');
    }
    
    if(isRecordField()) {
      // asRecord()?.setValue(instance, value);
      throw UnsupportedOperationException('Record field value setter is not supported at the moment.');
    }
    
    if(isAnnotationField()) {
      throw UnsupportedOperationException('Annotation field value setter is not supported at the moment.');
    }
    
    final instanceValue = instance ?? (isStatic() ? getDeclaringClass().getType() : null);
    asField()?.setValue(instanceValue, value);
  }
  
  @override
  T? getValueAs<T>([Object? instance]) {
    checkAccess('getValueAs', DomainPermission.READ_FIELDS);
    final value = getValue(instance);
    
    try {
      return value is T ? value : null;
    } on TypeError catch (_) {
      throw IllegalArgumentException('Value of type ${value.runtimeType} cannot be assigned to field of type ${T.toString()}');
    }
  }
  
  @override
  bool isReadable() {
    checkAccess('isReadable', DomainPermission.READ_FIELDS);
    
    if (isPublic()) {
      return true;
    }

    return false;
  }

  @override
  bool isWritable() {
    checkAccess('isWritable', DomainPermission.READ_FIELDS);

    if (isPublic()) {
      if (isFinal() && isLate()) {
        return true; // late final String name;
      }

      if (isStatic() && (isConst() || isFinal())) {
        return false; // static const String name | static final String name
      }

      if (isFinal() || isConst()) {
        return false; // final String name | const String name
      }

      return true;
    }

    return false;
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
    return '$modifierStr${getReturnClass().getName()} ${getName()}';
  }

  @override
  List<Object?> equalizedProperties() {
    return [
      _declaration.getName(),
      getSignature(),
      _declaration.getIsPublic(),
      _declaration.getIsSynthetic(),
      _declaration.getType(),
    ];
  }
  
  @override
  String toString() => 'Field(${getName()})';
}