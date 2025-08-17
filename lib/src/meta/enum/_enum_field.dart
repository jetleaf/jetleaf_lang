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

part of 'enum_field.dart';

class _EnumField extends EnumField {
  final EnumFieldDeclaration _declaration;
  final ProtectionDomain _pd;

  _EnumField(this._declaration, this._pd);

  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_TYPE_INFO);
    return _declaration.getName();
  }

  @override
  dynamic getValue() {
    checkAccess('getValue', DomainPermission.READ_TYPE_INFO);
    return _declaration.getValue();
  }

  @override
  int getPosition() {
    checkAccess('getPosition', DomainPermission.READ_TYPE_INFO);
    return _declaration.getPosition();
  }

  @override
  EnumDeclaration getEnum() {
    checkAccess('getEnum', DomainPermission.READ_TYPE_INFO);
    return _declaration.getEnum();
  }

  @override
  ProtectionDomain getProtectionDomain() => _pd;
}