part of 'record_class.dart';

final class _RecordClass extends RecordClass {
  final RecordLinkDeclaration _linkDeclaration;
  final ProtectionDomain _pd;

  _RecordClass(this._linkDeclaration, this._pd);

  @override
  bool getIsNullable() {
    checkAccess("isNullable", DomainPermission.READ_TYPE_INFO);
    return _linkDeclaration.getIsNullable();
  }

  @override
  bool isCanonical() {
    checkAccess("isCanonical", DomainPermission.READ_TYPE_INFO);
    return _linkDeclaration.getIsCanonical();
  }

  @override
  bool isPublic() {
    checkAccess("isPublic", DomainPermission.READ_TYPE_INFO);
    return _linkDeclaration.getIsPublic();
  }

  @override
  bool isSynthetic() {
    checkAccess("isSynthetic", DomainPermission.READ_TYPE_INFO);
    return _linkDeclaration.getIsSynthetic();
  }

  @override
  String getName() {
    checkAccess("getName", DomainPermission.READ_TYPE_INFO);
    return _linkDeclaration.getName();
  }

  @override
  RecordLinkDeclaration getRecordDeclaration() {
    checkAccess("getRecordDeclaration", DomainPermission.READ_TYPE_INFO);
    return _linkDeclaration;
  }

  @override
  RecordField? getRecordField(Object id) {
    checkAccess("getRecordField", DomainPermission.READ_FIELDS);

    if (id is String) {
      final field = _linkDeclaration.getField(id);
      return field != null ? RecordField.linked(field, _linkDeclaration, _pd) : null;
    }

    if (id is int) {
      final field = _linkDeclaration.getPositionalField(id);
      return field != null ? RecordField.linked(field, _linkDeclaration, _pd) : null;
    }

    return null;
  }

  @override
  List<RecordField> getRecordFields() {
    checkAccess("getRecordFields", DomainPermission.READ_FIELDS);

    final fields = _linkDeclaration.getFields();
    return UnmodifiableListView(fields.map((field) => RecordField.linked(field, _linkDeclaration, _pd)));
  }

  @override
  Field? getField(String name) {
    checkAccess("getField", DomainPermission.READ_FIELDS);

    if (getRecordField(name) case final field?) {
      return Field.declared(field.getFieldDeclaration(), _linkDeclaration, _pd);
    }

    return null;
  }

  @override
  List<Field> getFields() {
    checkAccess("getFields", DomainPermission.READ_FIELDS);
    
    final fields = getRecordFields();
    return UnmodifiableListView(fields.map((field) => Field.declared(field.getFieldDeclaration(), _linkDeclaration, _pd)));
  }

  @override
  bool isRecord() {
    checkAccess("isRecord", DomainPermission.READ_TYPE_INFO);
    return true;
  }
}