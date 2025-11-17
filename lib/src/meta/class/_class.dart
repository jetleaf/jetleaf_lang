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

part of 'class.dart';

@Generic(_Class)
class _Class<T> with EqualsAndHashCode implements Class<T> {
  String _name;
  final String? _package;
  final ProtectionDomain _pd;
  final LinkDeclaration? _link;

  late final TypeDeclaration _declaration;
  
  _Class(this._name, this._pd, this._package, this._link) {
    final checker = _name != T.toString() ? _name : T;

    final result = _name != T.toString() 
      ? TypeDiscovery.findByName(_name, _package) ?? TypeDiscovery.findByType(T, _package)
      : TypeDiscovery.findByType(T, _package) ?? TypeDiscovery.findByName(_name, _package);
    
    if(result == null) {
      throw ClassNotFoundException(checker.toString());
    }

    _confirmResult(result);

    _declaration = result;
  }

  _Class.fromQualifiedName(this._name, this._pd, this._link) : _package = null {
    TypeDeclaration? result = TypeDiscovery.findByQualifiedName(_name);

    if (result == null && _name == "dart:mirrors.void") {
      result = TypeDiscovery.findByName("void", _package);
    }

    if(result == null) {
      throw ClassNotFoundException(_name);
    }

    _confirmResult(result);

    _declaration = result;
    _name = result.getName();
  }

  _Class.declared(this._declaration, this._pd) : _link = null, _name = _declaration.getName(), _package = null {
    _confirmResult(_declaration);
  }

  void _confirmResult(TypeDeclaration result) {
    if(result is! ClassDeclaration && result is! EnumDeclaration && result is! RecordDeclaration && result is! MixinDeclaration && result is! TypedefDeclaration) {
      throw UnsupportedOperationException("Class of $T must either be a class, enum, record, mixin or typedef");
    }
  }

  @override
  Declaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_TYPE_INFO);
    return _declaration;
  }
  
  @override
  TypeDeclaration getTypeDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_TYPE_INFO);
    return _declaration;
  }

  List<LinkDeclaration> _getTypeArgs() => _link?.getTypeArguments() ?? _declaration.getTypeArguments();

  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_TYPE_INFO);

    // Handle records
    if (_declaration is RecordDeclaration) {
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

    // Handle classes
    if (_declaration is ClassDeclaration) {
      final typeParams = _getTypeArgs().isNotEmpty
          ? '<${_getTypeArgs().join(', ')}>'
          : '';

      final superType = _declaration.getSuperClass() != null
          ? ' extends ${_declaration.getSuperClass()!.getName()}'
          : '';

      final interfaces = _declaration.getInterfaces().isNotEmpty
          ? ' implements ${_declaration.getInterfaces().map((i) => i.getName()).join(', ')}'
          : '';

      final mixins = _declaration.getMixins().isNotEmpty
          ? ' with ${_declaration.getMixins().map((m) => m.getName()).join(', ')}'
          : '';

      return 'class ${_declaration.getName()}$typeParams$superType$mixins$interfaces';
    }

    // Handle enums
    if (_declaration is EnumDeclaration) {
      final values = _declaration.getValues().map((v) => v.getName()).join(', ');
      return 'enum ${_declaration.getName()} { $values }';
    }

    // Handle mixins
    if (_declaration is MixinDeclaration) {
      final typeParams = _getTypeArgs().isNotEmpty
          ? '<${_getTypeArgs().join(', ')}>'
          : '';

      final onClause = _declaration.getConstraints().isNotEmpty
          ? ' on ${_declaration.getConstraints().map((t) => t.getName()).join(', ')}'
          : '';

      final interfaces = _declaration.getInterfaces().isNotEmpty
          ? ' implements ${_declaration.getInterfaces().map((i) => i.getName()).join(', ')}'
          : '';

      return 'mixin ${_declaration.getName()}$typeParams$onClause$interfaces';
    }

    // Handle typedefs
    if (_declaration is TypedefDeclaration) {
      final typeParams = _getTypeArgs().isNotEmpty
          ? '<${_getTypeArgs().join(', ')}>'
          : '';
      return 'typedef ${_declaration.getName()}$typeParams = ${_declaration.getAliasedType()}';
    }

    // Fallback
    return toString();
  }

  // ======================================= META OVERRIDDEN METHODS =========================================

  @override
  void checkAccess(String operation, DomainPermission permission) {
    getProtectionDomain().checkAccess(operation, permission);
  }

  @override
  A? getDirectAnnotation<A>() {
    checkAccess('getAnnotation', DomainPermission.READ_ANNOTATIONS);

    final annotations = getAllDirectAnnotations();
    for (final annotation in annotations) {
      if (annotation.matches<A>()) {
        try {
          return annotation.getInstance<A>();
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  List<A> getDirectAnnotations<A>() {
    checkAccess('getAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = getAllDirectAnnotations();
    return annotations.where((a) => a.matches<A>()).map((a) => a.getInstance<A>()).toList();
  }

  @override
  bool hasDirectAnnotation<A>() {
    checkAccess('hasAnnotation', DomainPermission.READ_ANNOTATIONS);
    return getDirectAnnotation<A>() != null;
  }

  @override
  List<Annotation> getAllDirectAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);

    final annotations = _declaration.getDeclaration()?.getAnnotations();
    return annotations?.map((a) => Annotation.declared(a, getProtectionDomain())).toList() ?? [];
  }

  // ---------------------------------------------------------------------------------------------------------
  // === Name Information ===
  // ---------------------------------------------------------------------------------------------------------

  @override
  String getQualifiedName() {
    checkAccess('getQualifiedName', DomainPermission.READ_TYPE_INFO);
    return _declaration.getQualifiedName();
  }
  
  @override
  String getSimpleName() {
    checkAccess('getSimpleName', DomainPermission.READ_TYPE_INFO);
    return _declaration.getSimpleName();
  }

  @override
  String getPackageUri() {
    checkAccess('getPackageUri', DomainPermission.READ_TYPE_INFO);
    return _declaration.getPackageUri();
  }

  @override
  String getName() {
    checkAccess('getName', DomainPermission.READ_TYPE_INFO);
    return _declaration.getName();
  }

  @override
  String getCanonicalName() {
    checkAccess('getCanonical', DomainPermission.READ_TYPE_INFO);
    return _name;
  }

  // ---------------------------------------------------------------------------------------------------------
  // === Comparable Methods ===
  // ---------------------------------------------------------------------------------------------------------
  
  @override
  bool isCanonical() => getName() == getCanonicalName();

  @override
  bool isInvokable() => !isAbstract() || getConstructors().any((c) => c.isFactory());

  @override
  bool isInstance(Object? obj) {
    if (obj == null) return false;

    if(obj is Class) {
      if(obj.getQualifiedName() == getQualifiedName()) {
        if (obj.hasGenerics()) {
          final comp = obj.componentType();
          final thisComp = componentType();
          final key = obj.keyType();
          final thisKey = keyType();

          if (key == null && thisKey == null) {
            if (comp != null && thisComp != null) {
              if (comp == thisComp) {
                return true;
              }

              if (thisComp.isInstance(comp)) {
                return true;
              }
            }
          }

          if (key != null && thisKey != null && comp != null && thisComp != null) {
            if (key == thisKey && comp == thisComp) {
              return true;
            }

            if (thisKey.isInstance(key) && thisComp.isInstance(comp)) {
              return true;
            }
          }
        }

        return true;
      }

      if(obj.getDeclaration() == getDeclaration()) {
        return true;
      }

      if(obj.getQualifiedName() == getQualifiedName()) {
        return true;
      }

      return isAssignableFrom(obj) || obj.isAssignableTo(this);
    }

    final clazz = obj.getClass();

    if(isInstance(clazz)) {
      return true;
    }

    return isAssignableFrom(clazz) || clazz.isAssignableTo(this);
  }
  
  @override
  bool isAssignableFrom(Class other) {
    if(_declaration.isAssignableFrom(other.getDeclaration() as TypeDeclaration)) {
      return true;
    }

    return other.isAssignableTo(this);
  }

  @override
  bool isAssignableTo(Class other) {
    if(_declaration.isAssignableTo(other.getDeclaration() as TypeDeclaration)) {
      return true;
    }

    if(getQualifiedName() == other.getQualifiedName()) {
      return true;
    }

    if(isSubclassOf(other)) {
      return true;
    }

    if(getAllInterfaces().contains(other) || getAllInterfaces().any((i) => i.isSubclassOf(other) || i.getQualifiedName() == other.getQualifiedName())) {
      return true;
    }

    return false;
  }
  
  @override
  bool isSubclassOf(Class other) {
    if(this == other) {
      return true;
    }

    if(getQualifiedName() == other.getQualifiedName()) {
      return true;
    }
    
    final superClass = getSuperClass();
    if (superClass == null) return false;

    if(superClass == other) {
      return true;
    }

    if(superClass.getQualifiedName() == other.getQualifiedName()) {
      return true;
    }

    if(superClass.isSubclassOf(other)) {
      return true;
    }

    final interfaces = getAllInterfaces();
    for (final interface in interfaces) {
      if(interface.isSubclassOf(other)) {
        return true;
      }
    }

    return false;
  }

  @override
  List<Object?> equalizedProperties() => [
    _declaration.getName(),
    _declaration.getSimpleName(),
    _declaration.getQualifiedName(),
    _declaration.getPackageUri(),
    _declaration.getKind(),
    _declaration.getDebugIdentifier(),
    _declaration.getType(),
    _declaration.getElement(),
    _declaration.getIsNullable(),
    _declaration.getIsPublic(),
    _declaration.isGeneric()
  ];
  
  @override
  String toString() => 'Class<${getName()}>:Class<${getType()}>:${getQualifiedName()}';

  // =========================================== HELPER METHODS ===============================================

  @override
  List<String> getModifiers() => [
    if (isPublic()) 'PUBLIC',
    if (!isPublic()) 'PRIVATE',
    if (isBase()) 'BASE',
    if (isAbstract()) 'ABSTRACT',
    if (isEnum()) 'ENUM',
    if (isFinal()) 'FINAL',
    if (isInterface()) 'INTERFACE',
    if (isMixin()) 'MIXIN',
    if (isRecord()) 'RECORD',
    if (isSealed()) 'SEALED',
    if (isTypeVariable()) 'TYPE_VARIABLE',
    if (isTypedef()) 'TYPEDEF',
    if (isClass()) 'CLASS',
    if (isExtension()) 'EXTENSION',
  ];

  @override
  bool isAsync() {
    if (Class<Future>(null, "dart").isAssignableFrom(this) || Class<FutureOr>(null, "dart").isAssignableFrom(this)) {
      return true;
    }

    return false;
  }

  @override
  bool isAbstract() {
    checkAccess('isAbstract', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsAbstract() ?? false;
  }

  @override
  bool isPublic() {
    checkAccess('isPublic', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsPublic();
  }
  
  @override
  bool isBase() {
    checkAccess('isBase', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsBase() ?? false;
  }
  
  @override
  bool isEnum() {
    checkAccess('isEnum', DomainPermission.READ_TYPE_INFO);
    return _declaration.asEnum() != null;
  }
  
  @override
  bool isFinal() {
    checkAccess('isFinal', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsFinal() ?? false;
  }
  
  @override
  bool isInterface() {
    checkAccess('isInterface', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsInterface() ?? false;
  }
  
  @override
  bool isMixin() {
    checkAccess('isMixin', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsMixin() ?? _declaration.asMixin() != null;
  }
  
  @override
  bool isRecord() {
    checkAccess('isRecord', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsRecord() ?? _declaration.asRecord() != null;
  }
  
  @override
  bool isSealed() {
    checkAccess('isSealed', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsSealed() ?? false;
  }
  
  @override
  bool isTypeVariable() {
    checkAccess('isTypeVariable', DomainPermission.READ_TYPE_INFO);
    return _declaration.asTypeVariable() != null; // Typevariable is not yet fully used.
  }
  
  @override
  bool isTypedef() {
    checkAccess('isTypedef', DomainPermission.READ_TYPE_INFO);
    return _declaration.asTypedef() != null;
  }

  @override
  bool isClass() {
    checkAccess('isClass', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass() != null;
  }
  
  @override
  bool isExtension() {
    checkAccess('isExtension', DomainPermission.READ_TYPE_INFO);
    return false; // Extension support is not yet added
  }

  @override
  bool hasGenerics() => GenericTypeParser.isGeneric(T.toString()) || GenericTypeParser.isGeneric(_name);

  @override
  bool isArray() {
    checkAccess('isArray', DomainPermission.READ_TYPE_INFO);
    return _declaration.getKind() == TypeKind.listType 
      || (_getTypeArgs().isNotEmpty && _getTypeArgs().length == 1)
      || T.toString().startsWith("List<") || T.toString().startsWith("Iterable")
      || T is List || T is Iterable || T == List || T == Set || T == Iterable 
      || isAssignableTo(Class.of<List>())
      || isAssignableTo(Class.of<Set>()) 
      || isAssignableTo(Class.of<Iterable>());
  }

  @override
  bool isKeyValuePaired() {
    checkAccess('isKeyValuePaired', DomainPermission.READ_TYPE_INFO);
    return (_getTypeArgs().isNotEmpty && _getTypeArgs().length >= 2) 
      || _declaration.getKind() == TypeKind.mapType
      || T == Map 
      || isAssignableTo(Class.of<Map>()) 
      || isAssignableTo(Class.of<MapEntry>());
  }

  @override
  bool isPrimitive() {
    checkAccess('isPrimitive', DomainPermission.READ_TYPE_INFO);

    // If underlying declaration knows it's primitive, accept it.
    if (_declaration.getKind() == TypeKind.primitiveType) return true;

    // Resolve the non-nullable "base" type.
    final Type baseType = getType();

    // Common Dart built-ins we treat as primitives:
    if (baseType == Class.of<bool>().getType()) return true;
    if (baseType == Class.of<int>().getType()) return true;
    if (baseType == Class.of<double>().getType()) return true;
    if (baseType == Class.of<String>().getType()) return true;
    if (baseType == Class.of<Symbol>().getType()) return true;
    if (baseType == Class.of<Null>().getType()) return true;

    // Also consider 'num' as a builtin primitive-like type
    if (baseType == Class.of<num>().getType()) return true;

    return false;
  }

  @override
  Type getType() => _declaration.getType();

  @override
  Type getOriginal() => T;

  @override
  Package? getPackage() {
    checkAccess('getPackage', DomainPermission.READ_TYPE_INFO);
    return _declaration.getDeclaration()?.getParentLibrary().getPackage();
  }

  @override
  List<Class> getTypeParameters() {
    checkAccess('getTypeParameters', DomainPermission.READ_TYPE_INFO);

    final args = _link?.getTypeArguments();
    if (args != null && args.isNotEmpty) {
      return args.map((dec) => Class.fromQualifiedName(dec.getPointerQualifiedName(), _pd, dec)).toList();
    }

    return MetaClassLoader.findTypeParameters(this);
  }

  @override
  ProtectionDomain getProtectionDomain() => _pd;

  // =========================================== NESTED ACCESSORS ==============================================

  @override
  Class<K>? keyType<K>() {
    checkAccess('keyType', DomainPermission.READ_TYPE_INFO);

    if (!isKeyValuePaired()) return null;

    final args = _link?.getTypeArguments();
    if (args != null && args.isNotEmpty && args.length < 2) {
      final link = args[0];
      final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
      return Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link);
    }
    
    final keyDeclaration = MetaClassLoader.extractKeyType(this);
    return MetaClassLoader.findKeyType<K>(this, keyDeclaration);
  }
  
  @override
  Class<C>? componentType<C>() {
    checkAccess('componentType', DomainPermission.READ_TYPE_INFO);

    final args = _link?.getTypeArguments();
    if (args != null && args.isNotEmpty) {
      final link = args.length == 1 ? args[0] : args[1];
      final component = MetaClassLoader.getFromLink(link, _pd);
      return Class.fromQualifiedName(component.getQualifiedName(), _pd, link);
    }

    final componentDeclaration = MetaClassLoader.extractComponentType(this);
    return MetaClassLoader.findComponentType<C>(this, componentDeclaration);
  }

  // =========================================== SUPER CLASS METHODS ============================================

  @override
  Class<S>? getSuperClass<S>() {
    checkAccess('getSuperclass', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findSuperClassAs<S>(this, false);
  }

  @override
  Class? getDeclaredSuperClass() {
    checkAccess('getDeclaredSuperclass', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findSuperClass(this);
  }
  
  @override
  List<Class> getSuperClassArguments() {
    checkAccess('getSuperClassArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findSuperClassArguments(this);
  }

  // =========================================== SUB CLASS METHODS ===========================================

  @override
  List<Class> getSubClasses() {
    checkAccess('getSubClasses', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findSubclasses(this);
  }

  @override
  Class<S>? getSubClass<S>() {
    checkAccess('getSubClass', DomainPermission.READ_TYPE_INFO);

    final list = getSubClasses().where((c) => c.getQualifiedName() == Class<S>().getQualifiedName());
    if (list.isEmpty) {
      return null;
    }
    return list.first as Class<S>;
  }

  // ====================================== INTERFACE ACCESS METHODS ==========================================

  @override
  List<Class> getAllInterfaces() {
    checkAccess('getInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findAllConstraints(this, false);
    }

    return MetaClassLoader.findAllInterfaces(this, false);
  }

  @override
  List<Class> getAllDeclaredInterfaces() {
    checkAccess('getAllDeclaredInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findAllConstraints(this);
    }

    return MetaClassLoader.findAllInterfaces(this);
  }

  @override
  List<Class<I>> getInterfaces<I>() {
    checkAccess('getInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findConstraints<I>(this, false);
    }

    return MetaClassLoader.findInterfaces<I>(this, false);
  }

  @override
  List<Class<I>> getDeclaredInterfaces<I>() {
    checkAccess('getDeclaredInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findConstraints<I>(this);
    }

    return MetaClassLoader.findInterfaces<I>(this);
  }

  @override
  Class<I>? getInterface<I>() {
    checkAccess('getInterface', DomainPermission.READ_TYPE_INFO);
    
    final list = getInterfaces<I>();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  @override
  Class<I>? getDeclaredInterface<I>() {
    checkAccess('getDeclaredInterface', DomainPermission.READ_TYPE_INFO);
    
    final list = getDeclaredInterfaces<I>();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }
  
  @override
  List<Class> getInterfaceArguments<I>() {
    checkAccess('getInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findConstraintArguments<I>(this, false);
    }

    return MetaClassLoader.findInterfaceArguments<I>(this, false);
  }

  @override
  List<Class> getDeclaredInterfaceArguments<I>() {
    checkAccess('getDeclaredInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findConstraintArguments<I>(this);
    }

    return MetaClassLoader.findInterfaceArguments<I>(this);
  }

  @override
  List<Class> getAllInterfaceArguments() {
    checkAccess('getAllInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findAllConstraintArguments(this, false);
    }

    return MetaClassLoader.findAllInterfaceArguments(this, false);
  }

  @override
  List<Class> getAllDeclaredInterfaceArguments() {
    checkAccess('getAllDeclaredInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return MetaClassLoader.findAllConstraintArguments(this);
    }

    return MetaClassLoader.findAllInterfaceArguments(this);
  }

  // =========================================== MIXIN ACCESS METHODS ==========================================

  @override
  List<Class> getAllMixins() {
    checkAccess('getAllMixins', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findAllMixins(this, false);
  }

  @override
  List<Class> getAllDeclaredMixins() {
    checkAccess('getAllMixins', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findAllMixins(this);
  }
  
  @override
  List<Class> getMixinsArguments<M>() {
    checkAccess('getMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findMixinArguments<M>(this, false);
  }

  @override
  List<Class> getDeclaredMixinsArguments<M>() {
    checkAccess('getDeclaredMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findMixinArguments<M>(this);
  }
  
  @override
  List<Class> getAllMixinsArguments() {
    checkAccess('getAllMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findAllMixinArguments(this, false);
  }

  @override
  List<Class> getAllDeclaredMixinsArguments() {
    checkAccess('getAllDeclaredMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findAllMixinArguments(this);
  }
  
  @override
  List<Class<I>> getMixins<I>() {
    checkAccess('getMixins', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findMixins<I>(this, false);
  }

  @override
  List<Class<I>> getDeclaredMixins<I>() {
    checkAccess('getDeclaredMixins', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findMixins<I>(this);
  }

  @override
  Class<I>? getMixin<I>() {
    checkAccess('getMixin', DomainPermission.READ_TYPE_INFO);

    final list = getMixins<I>();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  @override
  Class<I>? getDeclaredMixin<I>() {
    checkAccess('getDeclaredMixin', DomainPermission.READ_TYPE_INFO);

    final list = getDeclaredMixins<I>();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  // ---------------------------------------------------------------------------------------------------------
  // === Annotation Information ===
  // ---------------------------------------------------------------------------------------------------------

  @override
  List<Annotation> getAllAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);
    return _getAllAnnotations();
  }

  List<Annotation> _getAllAnnotations([Set<Class>? visited]) {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);

    visited ??= <Class>{};

    // If this class has already been processed, stop to avoid cycles.
    if (!visited.add(this)) {
      return const [];
    }

    final list = <Annotation>[];
    list.addAll(getAllDirectAnnotations());

    // Superclass
    final superClass = getSuperClass();
    if (superClass != null && superClass is _Class) {
      list.addAll(superClass._getAllAnnotations(visited));
    }

    // Interfaces
    for (final interface in getInterfaces()) {
      if(interface is _Class) {
        list.addAll(interface._getAllAnnotations(visited));
      }
    }

    return list;
  }
  
  @override
  A? getAnnotation<A>() {
    checkAccess('getAnnotation', DomainPermission.READ_ANNOTATIONS);

    final annotations = getAllAnnotations();
    for (final annotation in annotations) {
      if (annotation.getClass().getType() == A) {
        return annotation.getInstance<A>();
      }
    }

    return null;
  }
  
  @override
  List<A> getAnnotations<A>() {
    checkAccess('getAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = getAllAnnotations();
    return annotations.where((a) => a.matches<A>()).map((a) => a.getInstance<A>()).toList();
  }

  @override
  bool hasAnnotation<A>() {
    checkAccess('hasAnnotation', DomainPermission.READ_ANNOTATIONS);
    return getAnnotation<A>() != null;
  }

  // ========================================== DECLARED MEMBERS ========================================
  
  @override
  List<Object> getDeclaredMembers() {
    checkAccess('getDeclaredMembers', DomainPermission.READ_TYPE_INFO);

    final members = <Object>[];
    members.addAll(getConstructors());
    members.addAll(getMethods());
    members.addAll(getFields());

    return members;
  }

  // ============================================ FIELD METHODS ===============================================
  
  @override
  Field? getField(String name) {
    checkAccess('getField', DomainPermission.READ_TYPE_INFO);

    final declaration = _declaration.asClass() ?? _declaration.asEnum() ?? _declaration.asRecord();
    if (declaration == null) {
      return null;
    }

    if (declaration is ClassDeclaration) {
      final field = declaration.getFields().firstWhereOrNull((f) => f.getName().equals(name));
      return field != null ? Field.declared(field, declaration, _pd) : null;
    }

    if (declaration is EnumDeclaration) {
      final field = declaration.getValues().firstWhereOrNull((f) => f.getName().equals(name));
      return field != null ? Field.declared(field, declaration, _pd) : null;
    }

    if (declaration is EnumDeclaration) {
      final field = declaration.getMembers().whereType<FieldDeclaration>().firstWhereOrNull((f) => f.getName().equals(name));
      return field != null ? Field.declared(field, declaration, _pd) : null;
    }

    if (declaration is RecordDeclaration) {
      final field = declaration.getPositionalFields().firstWhereOrNull((f) => f.getName().equals(name));
      return field != null ? Field.declared(field, declaration, _pd) : null;
    }

    if (declaration is RecordDeclaration) {
      final field = declaration.getNamedFields().values.firstWhereOrNull((f) => f.getName().equals(name));
      return field != null ? Field.declared(field, declaration, _pd) : null;
    }

    return null;
  }
  
  @override
  List<Field> getFields() {
    checkAccess('getFields', DomainPermission.READ_FIELDS);

    final fields = <Field>[];
    
    if (_declaration.asClass() != null) {
      fields.addAll(_declaration.asClass()!.getFields().map((f) => Field.declared(f, _declaration, _pd)));
    }
    
    if (_declaration.asEnum() != null) {
      fields.addAll(_declaration.asEnum()!.getValues().map((f) => Field.declared(f, _declaration, _pd)));
    }

    if (_declaration.asEnum() != null) {
      fields.addAll(_declaration.asEnum()!.getMembers().whereType<FieldDeclaration>().map((f) => Field.declared(f, _declaration, _pd)));
    }
    
    if (_declaration.asRecord() != null) {
      fields.addAll(_declaration.asRecord()!.getPositionalFields().map((f) => Field.declared(f, _declaration, _pd)));
    }
    
    if (_declaration.asRecord() != null) {
      fields.addAll(_declaration.asRecord()!.getNamedFields().values.map((f) => Field.declared(f, _declaration, _pd)));
    }

    final supertype = getSuperClass();
    if (supertype != null) {
      fields.addAll(supertype.getFields());
    }

    final interfaces = getInterfaces();
    for (final interface in interfaces) {
      fields.addAll(interface.getFields());
    }
    
    return fields;
  }

  @override
  List<Field> getEnumValues() {
    checkAccess('getEnumValues', DomainPermission.READ_TYPE_INFO);

    if (!isEnum()) {
      throw InvalidArgumentException('Not an enum type');
    }

    final fields = <Field>[];
    
    final enumType = _declaration.asEnum();
    if (enumType != null) {
      fields.addAll(enumType.getValues().map((f) => Field.declared(f, enumType, _pd)).toList());
    }

    final supertype = getSuperClass();
    if (supertype != null && supertype is _Class && supertype.isEnum()) {
      final en = supertype._declaration.asEnum();
      if (en != null) {
        fields.addAll(en.getValues().map((f) => Field.declared(f, en, _pd)).toList());
      }
    }
    
    return fields;
  }

  @override
  List<Field> getPositionalFields() {
    checkAccess('getPositionalFields', DomainPermission.READ_FIELDS);
    
    final fields = <Field>[];
    
    if (_declaration.asRecord() != null) {
      fields.addAll(_declaration.asRecord()!.getPositionalFields().map((f) => Field.declared(f, _declaration, _pd)));
    }
    
    return fields;
  }
  
  @override
  Map<String, Field> getNamedFields() {
    checkAccess('getNamedFields', DomainPermission.READ_FIELDS);
    final namedFields = <String, Field>{};
    final declaration = _declaration.asRecord();
    
    if (declaration != null) {
      for (final entry in declaration.getNamedFields().entries) {
        namedFields[entry.key] = Field.declared(entry.value, _declaration, _pd);
      }
    }
    
    return namedFields;
  }
  
  @override
  Field? getPositionalField(int index) {
    checkAccess('getPositionalField', DomainPermission.READ_FIELDS);
    final field = _declaration.asRecord()?.getPositionalField(index);
    return field != null ? Field.declared(field, _declaration, _pd) : null;
  }
  
  @override
  Field? getNamedField(String name) {
    checkAccess('getNamedField', DomainPermission.READ_FIELDS);
    final field = _declaration.asRecord()?.getField(name);
    return field != null ? Field.declared(field, _declaration, _pd) : null;
  }
  
  @override
  int getFieldCount() {
    checkAccess('getFieldCount', DomainPermission.READ_FIELDS);
    return getPositionalFieldCount() + getNamedFieldCount();
  }
  
  @override
  int getPositionalFieldCount() {
    checkAccess('getPositionalFieldCount', DomainPermission.READ_FIELDS);
    return _declaration.asRecord()?.getPositionalFields().length ?? 0;
  }
  
  @override
  int getNamedFieldCount() {
    checkAccess('getNamedFieldCount', DomainPermission.READ_FIELDS);
    return _declaration.asRecord()?.getNamedFields().length ?? 0;
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

  // ============================================= METHOD METHODS ==========================================
  
  @override
  Method? getMethod(String name) {
    checkAccess('getMethod', DomainPermission.READ_METHODS);

    final declaration = _declaration.asClass() ?? _declaration.asEnum() ?? _declaration.asMixin();

    if (declaration == null) return null;
    Method? result;
    
    if (declaration is ClassDeclaration) {
      final method = declaration.getMethods().firstWhereOrNull((m) => m.getName().equals(name));
      result = method != null ? Method.declared(method, _pd) : null;
    } else if (declaration is EnumDeclaration) {
      final method = declaration.getMembers().whereType<MethodDeclaration>().firstWhereOrNull((m) => m.getName().equals(name));
      result = method != null ? Method.declared(method, _pd) : null;
    } else if (declaration is MixinDeclaration) {
      final method = declaration.getMethods().firstWhereOrNull((m) => m.getName().equals(name));
      result = method != null ? Method.declared(method, _pd) : null;
    }

    final supertype = getSuperClass();
    if (supertype != null) {
      result ??= supertype.getMethod(name);
    }

    final interfaces = getInterfaces();
    for (final interface in interfaces) {
      final method = interface.getMethod(name);
      if (method != null) {
        result ??= method;
        break;
      }
    }
    
    return result;
  }
  
  @override
  Method? getMethodBySignature(String name, List<Class> parameterTypes) {
    checkAccess('getMethodBySignature', DomainPermission.READ_METHODS);

    final methods = _declaration.asClass()?.getMethods() 
      ?? _declaration.asEnum()?.getMembers().whereType<MethodDeclaration>().toList() 
      ?? _declaration.asMixin()?.getMethods()
      ?? [];
    
    for (final method in methods) {
      if (method.getName() == name) {
        final params = method.getParameters();
        if (params.length == parameterTypes.length) {
          bool matches = true;
          for (int i = 0; i < params.length; i++) {
            if (params[i].getType() != parameterTypes[i].getType()) {
              matches = false;
              break;
            }
          }
          if (matches) {
            return Method.declared(method, _pd);
          }
        }
      }
    }
    
    return null;
  }
  
  @override
  List<Method> getMethods() {
    checkAccess('getMethods', DomainPermission.READ_METHODS);

    final methods = <Method>[];
    
    final result = _declaration.asClass()?.getMethods() 
      ?? _declaration.asEnum()?.getMembers().whereType<MethodDeclaration>().toList() 
      ?? _declaration.asMixin()?.getMethods()
      ?? [];
    methods.addAll(result.map((m) => Method.declared(m, _pd)).toList());

    final supertype = getSuperClass();
    if (supertype != null) {
      methods.addAll(supertype.getMethods());
    }

    final interfaces = getInterfaces();
    for (final interface in interfaces) {
      methods.addAll(interface.getMethods());
    }

    return methods;
  }

  @override
  List<Method> getAllMethodsInHierarchy() {
    checkAccess('getAllMethodsInHierarchy', DomainPermission.READ_METHODS);
    
    final methods = _declaration.asClass()?.getAllMethodsInHierarchy() 
      ?? _declaration.asEnum()?.getMembers().whereType<MethodDeclaration>().toList() 
      ?? _declaration.asMixin()?.getMethods()
      ?? [];
    return methods.map((m) => Method.declared(m, _pd)).toList();
  }
  
  @override
  List<Method> getOverriddenMethods() {
    checkAccess('getOverriddenMethods', DomainPermission.READ_METHODS);
    
    return getMethods().where((m) => m.isOverride()).toList();
  }
  
  @override
  List<Method> getMethodsByName(String name) {
    checkAccess('getMethodsByName', DomainPermission.READ_METHODS);
    
    final methods = _declaration.asClass()?.getMethods() 
      ?? _declaration.asEnum()?.getMembers().whereType<MethodDeclaration>().toList() 
      ?? _declaration.asMixin()?.getMethods()
      ?? [];
    return methods.where((m) => m.getName() == name).map((m) => Method.declared(m, _pd)).toList();
  }

  // =========================================== CONSTRUCTOR METHODS ===========================================
  
  @override
  Constructor? getConstructor(String name) {
    checkAccess('getConstructor', DomainPermission.READ_CONSTRUCTORS);
    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    ConstructorDeclaration? constructor = constructors.firstWhereOrNull((c) => c.getName().equals(name));
    return constructor != null ? Constructor.declared(constructor, _pd) : null;
  }

  @override
  Constructor? getConstructorBySignature(List<Class> parameterTypes) {
    checkAccess('getConstructorBySignature', DomainPermission.READ_CONSTRUCTORS);

    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    
    for (final constructor in constructors) {
      final params = constructor.getParameters();
      if (params.length == parameterTypes.length) {
        bool matches = true;
        for (int i = 0; i < params.length; i++) {
          if (params[i].getType() != parameterTypes[i].getType()) {
            matches = false;
            break;
          }
        }
        if (matches) {
          return Constructor.declared(constructor, _pd);
        }
      }
    }
    
    return null;
  }

  @override
  Constructor? getBestConstructor(List<Class> parameterTypes) {
    checkAccess('getBestConstructor', DomainPermission.READ_CONSTRUCTORS);

    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    Constructor? best;
    int bestScore = -1;

    for (final rawCtor in constructors) {
      final ctor = Constructor.declared(rawCtor, _pd);
      final params = rawCtor.getParameters(); // ParameterDeclaration list
      // Separate positional (including optional positional) and named params
      final positionalParams = <Parameter>[];
      final namedParams = <String, Parameter>{};

      for (final pd in params) {
        final p = Parameter.declared(pd, _pd);
        if (p.isNamed()) {
          namedParams[p.getName()] = p;
        } else {
          positionalParams.add(p);
        }
      }

      // Quick reject: provided positional types must not be less than required positional count
      final requiredPositionalCount = positionalParams.where((p) => p.isPositional() && p.isRequired()).length;
      if (parameterTypes.length < requiredPositionalCount) {
        continue;
      }

      // If constructor has required named params, we cannot satisfy them from positional types alone
      final requiredNamed = namedParams.values.where((p) => p.isRequired()).length;
      if (requiredNamed > 0) {
        // We can't match required named params by type-only call; skip this ctor
        continue;
      }

      // Now try to match provided positional types to positionalParams in-order
      bool fits = true;
      int score = 0;
      for (int i = 0; i < parameterTypes.length; i++) {
        if (i >= positionalParams.length) {
          // Provided more positional args than positional params -> not a fit
          fits = false;
          break;
        }
        final param = positionalParams[i];
        final providedType = parameterTypes[i];

        // Accept if providedType is assignable to param type (or exact)
        // Prefer exact matches with higher score
        try {
          final paramClass = param.getClass();
          if (paramClass == providedType) {
            score += 3; // exact
          } else if (paramClass.isAssignableFrom(providedType)) {
            score += 2; // assignable (subclass)
          } else {
            // If param is nullable (type allows null), still accept but lower score if provided is null-type?
            if (param.isOptional() || param.isPositional() && !param.isRequired()) {
              // optional positional with non-matching type — reject for type mismatch
              fits = false;
              break;
            } else {
              fits = false;
              break;
            }
          }
        } catch (e) {
          // If we can't resolve classes (fallback), perform name-based or raw type equality fallback
          // conservative: treat as mismatch
          fits = false;
          break;
        }
      }

      if (!fits) continue;

      // Check remaining constructor parameters (those not covered by provided positional args)
      for (int j = parameterTypes.length; j < positionalParams.length; j++) {
        final param = positionalParams[j];
        // if leftover param is required -> cannot accept
        if (param.isRequired() && !param.hasDefaultValue()) {
          fits = false;
          break;
        }
        // optional/nullable/default -> acceptable, minor score
        score += 1;
      }

      if (!fits) continue;

      // Named params: if they are all optional/have defaults or nullable then acceptable
      for (final p in namedParams.values) {
        if (p.isRequired() && !p.hasDefaultValue()) {
          fits = false;
          break;
        }
        score +=  (p.hasDefaultValue() ? 1 : 1);
      }
      if (!fits) continue;

      // Prefer constructor with higher score, tie-break with fewer required missing params and fewer params overall
      if (score > bestScore || (score == bestScore && (best == null || params.length < best.getParameters().length))) {
        bestScore = score;
        best = ctor;
      }
    }

    return best;
  }
  
  @override
  List<Constructor> getConstructors() {
    checkAccess('getConstructors', DomainPermission.READ_CONSTRUCTORS);
    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    return constructors.map((c) => Constructor.declared(c, _pd)).toList();
  }

  @override
  Constructor? getDefaultConstructor() {
    checkAccess('getDefaultConstructor', DomainPermission.READ_CONSTRUCTORS);

    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    ConstructorDeclaration? dc = constructors.firstWhereOrNull((c) => c.getName().isEmpty);
    return dc != null ? Constructor.declared(dc, _pd) : null;
  }

  @override
  Constructor? getNoArgConstructor([bool acceptWhenAllParametersAreOptional = false]) {
    checkAccess('getNoArgConstructor', DomainPermission.READ_CONSTRUCTORS);

    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    ConstructorDeclaration? dc = constructors.firstWhereOrNull((c) => c.getParameters().isEmpty);

    if(acceptWhenAllParametersAreOptional && dc == null) {
      dc = constructors.find((c) => c.getParameters().all((p) => p.getIsOptional()));
    }

    return dc != null ? Constructor.declared(dc, _pd) : null;
  }

  // ============================================ INSTANCE METHODS ===========================================
  
  @override
  T newInstance([Map<String, dynamic>? arguments, String? constructorName]) {
    checkAccess('newInstance', DomainPermission.CREATE_INSTANCES);
    if (_declaration.asClass() == null) {
      throw IllegalStateException('Cannot create instance of ${getType()} - no constructor data available');
    }

    // Try with constructor name, if provided
    if(constructorName != null) {
      final constructor = getConstructor(constructorName);
      if (constructor == null) {
        throw IllegalStateException('Constructor $constructorName not found in ${getType()}');
      }
      
      return constructor.newInstance<T>(arguments ?? {});
    }

    // If arguments is not null, try to determine constructor to use.
    if(arguments != null) {
      final constructors = getConstructors();
      final constructor = constructors.firstWhereOrNull((c) => c.canAcceptArguments(arguments));
      if (constructor == null) {
        throw IllegalStateException('Constructor not found in ${getType()}');
      }
      
      return constructor.newInstance<T>(arguments);
    }

    // Resort to last option of default constructor.
    final constructor = getDefaultConstructor();
    if (constructor == null) {
      throw IllegalStateException('Constructor not found in ${getType()}');
    }
    
    return constructor.newInstance<T>(arguments ?? {});
  }
}

/// Extensions for type hierarchy traversal
extension ClassHierarchyExtensions on ClassDeclaration {
  /// Get all methods from this class and its hierarchy
  List<MethodDeclaration> getAllMethodsInHierarchy() {
    final allMethods = <MethodDeclaration>[];
    final visited = <String>{};
    
    _collectMethodsFromHierarchy(this, allMethods, visited);
    
    return allMethods;
  }
  
  /// Recursively collect methods from class hierarchy
  void _collectMethodsFromHierarchy(ClassDeclaration clazz, List<MethodDeclaration> allMethods, Set<String> visited) {
    final className = clazz.getQualifiedName();
    if (visited.contains(className)) return;
    visited.add(className);
    
    // Add methods from current class
    allMethods.addAll(clazz.getMethods());
    
    // Add methods from superclass
    final supertype = clazz.getSuperClass();
    if (supertype != null) {
      final superclass = Class.fromQualifiedName(supertype.getPointerQualifiedName(), ProtectionDomain.system()).getTypeDeclaration().asClass();
      if (superclass != null) {
        _collectMethodsFromHierarchy(superclass, allMethods, visited);
      }
    }
    
    // Add methods from interfaces
    for (final interfaceType in clazz.getInterfaces()) {
      final interfaceClass = Class.fromQualifiedName(interfaceType.getPointerQualifiedName(), ProtectionDomain.system()).getTypeDeclaration().asClass();
      if (interfaceClass != null) {
        _collectMethodsFromHierarchy(interfaceClass, allMethods, visited);
      }
    }
    
    // Add methods from mixins
    for (final mixinType in clazz.getMixins()) {
      final mixinDeclaration = Class.fromQualifiedName(mixinType.getPointerQualifiedName(), ProtectionDomain.system()).getTypeDeclaration().asMixin();
      if (mixinDeclaration != null) {
        allMethods.addAll(mixinDeclaration.getMethods());
      }
    }
  }
}