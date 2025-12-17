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
class _Class<T> extends Source with EqualsAndHashCode implements Class<T> {
  String _name;
  final String? _package;
  final ProtectionDomain _pd;
  final LinkDeclaration? _link;

  late final ClassDeclaration _declaration;
  
  _Class(this._name, this._pd, this._package, this._link) {
    final checker = _name != T.toString() ? _name : T;

    ClassDeclaration? result = _name != T.toString() 
      ? TypeDiscovery.findClassByName(_name, _package) ?? TypeDiscovery.findClassByType(T, _package)
      : TypeDiscovery.findClassByType(T, _package) ?? TypeDiscovery.findClassByName(_name, _package);
    result ??= _predict(checker.toString());

    _declaration = result;
  }

  _Class.fromQualifiedName(this._name, this._pd, this._link) : _package = null {
    ClassDeclaration? result = TypeDiscovery.findClassByQualifiedName(_name);

    if (result == null && _name == "dart:mirrors.void") {
      result = TypeDiscovery.findClassByName("void", _package) ?? TypeDiscovery.findClassByQualifiedName(Void.getQualifiedName());
    }

    if (_name == "dart:mirrors.dynamic" || _name == "dynamic") {
      result = TypeDiscovery.findClassByName("dynamic", _package) ?? TypeDiscovery.findClassByQualifiedName(Dynamic.getQualifiedName());
    }

    result ??= _predict(_name);

    _declaration = result;
    _name = result.getName();
  }

  ClassDeclaration _predict(String name) {
    if (name == "dynamic") {
      return DYNAMIC_CLASS.getClassDeclaration();
    }

    if (name == "void") {
      return VOID_CLASS.getClassDeclaration();
    }

    throw ClassNotFoundException(name);
  } 

  _Class.declared(this._declaration, this._pd) : _link = null, _name = _declaration.getName(), _package = null;

  @override
  Declaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_TYPE_INFO);
    return _declaration;
  }
  
  @override
  ClassDeclaration getClassDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_TYPE_INFO);
    return _declaration;
  }

  @override
  String getSignature() {
    checkAccess('getSignature', DomainPermission.READ_TYPE_INFO);

    // Handle enums
    if (_declaration is EnumDeclaration) {
      final values = _declaration.getValues().map((v) => v.getName()).join(', ');
      return 'enum ${_declaration.getName()} { $values }';
    }

    // Handle mixins
    if (_declaration is MixinDeclaration) {
      final typeParams = getTypeArgumentLinks().isNotEmpty
          ? '<${getTypeArgumentLinks().join(', ')}>'
          : '';

      final onClause = _declaration.getConstraints().isNotEmpty
          ? ' on ${_declaration.getConstraints().map((t) => t.getName()).join(', ')}'
          : '';

      final interfaces = _declaration.getInterfaces().isNotEmpty
          ? ' implements ${_declaration.getInterfaces().map((i) => i.getName()).join(', ')}'
          : '';

      return 'mixin ${_declaration.getName()}$typeParams$onClause$interfaces';
    }

    final typeParams = getTypeArgumentLinks().isNotEmpty
        ? '<${getTypeArgumentLinks().join(', ')}>'
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

  @override
  Author? getAuthor() => super.getAuthor() ?? getAnnotation<Author>();

  @override
  List<LinkDeclaration> getTypeArgumentLinks() {
    checkAccess("getTypeArgumentLinks", DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(_link?.getTypeArguments() ?? _declaration.getTypeArguments());
  }

  @override
  List<Class<Object>> getTypeArguments() {
    checkAccess("getTypeArguments", DomainPermission.READ_TYPE_INFO);

    final args = <Class<Object>>[];

    for (final link in getTypeArgumentLinks()) {
      final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
      args.add(Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link));
    }

    return UnmodifiableListView(args);
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
    if (obj is FunctionClass || obj is RecordClass) return false;

    if (obj == null) return false;

    if (getQualifiedName() == Dynamic.getQualifiedName()) {
      return true;
    }

    if (getQualifiedName() == Void.getQualifiedName()) {
      return true;
    }

    if(obj is Class) {
      if (obj.getQualifiedName() == Dynamic.getQualifiedName() || obj == DYNAMIC_CLASS) {
        return true;
      }

      if (obj.getQualifiedName() == Void.getQualifiedName() || obj == VOID_CLASS) {
        return true;
      }

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
    if (other is FunctionClass || other is RecordClass) return false;

    if(_declaration.isAssignableFrom(other.getClassDeclaration())) {
      return true;
    }

    return other.isAssignableTo(this);
  }

  @override
  bool isAssignableTo(Class other) {
    if (other is FunctionClass || other is RecordClass) return false;

    if(_declaration.isAssignableTo(other.getClassDeclaration())) {
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
    if (other is FunctionClass || other is RecordClass) return false;

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
  List<String> getModifiers() {
    checkAccess('getModifiers', DomainPermission.READ_TYPE_INFO);

    return [
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
      if (isClass()) 'CLASS',
    ];
  }

  @override
  bool isAsync() {
    checkAccess('isAsync', DomainPermission.READ_TYPE_INFO);

    if (_declaration.getDartType() case final dartType?) {
      if (dartType.isDartAsyncFuture || dartType.isDartAsyncFutureOr) {
        return true;
      }
    }

    if (Class<Future>(null, "dart").isAssignableFrom(this) || Class<FutureOr>(null, "dart").isAssignableFrom(this)) {
      return true;
    }

    return false;
  }

  @override
  bool isAbstract() {
    checkAccess('isAbstract', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsAbstract();
  }

  @override
  bool isPublic() {
    checkAccess('isPublic', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsPublic();
  }
  
  @override
  bool isBase() {
    checkAccess('isBase', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsBase();
  }
  
  @override
  bool isEnum() {
    checkAccess('isEnum', DomainPermission.READ_TYPE_INFO);
    return _declaration.asEnum() != null;
  }
  
  @override
  bool isFinal() {
    checkAccess('isFinal', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsFinal();
  }

  @override
  bool isFunction() {
    checkAccess('isFunction', DomainPermission.READ_TYPE_INFO);
    return false;
  }
  
  @override
  bool isInterface() {
    checkAccess('isInterface', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsInterface();
  }
  
  @override
  bool isMixin() {
    checkAccess('isMixin', DomainPermission.READ_TYPE_INFO);
    return _declaration is MixinDeclaration;
  }
  
  @override
  bool isRecord() {
    checkAccess('isRecord', DomainPermission.READ_TYPE_INFO);
    return false;
  }

  @override
  bool isVoid() {
    checkAccess('isVoid', DomainPermission.READ_TYPE_INFO);
    return this == VOID_CLASS || getQualifiedName() == Void.getQualifiedName();
  }

  @override
  bool isDynamic() {
    checkAccess('isDynamic', DomainPermission.READ_TYPE_INFO);
    return this == DYNAMIC_CLASS || getQualifiedName() == Dynamic.getQualifiedName();
  }
  
  @override
  bool isSealed() {
    checkAccess('isSealed', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsSealed();
  }

  @override
  bool isClass() {
    checkAccess('isClass', DomainPermission.READ_TYPE_INFO);
    return true;
  }

  @override
  bool isSynthetic() {
    checkAccess('isSynthetic', DomainPermission.READ_TYPE_INFO);
    return _declaration.getIsSynthetic();
  }

  @override
  bool hasGenerics() {
    checkAccess('hasGenerics', DomainPermission.READ_TYPE_INFO);
    return GenericTypeParser.isGeneric(T.toString()) || GenericTypeParser.isGeneric(_name);
  }

  @override
  bool isArray() {
    checkAccess('isArray', DomainPermission.READ_TYPE_INFO);
    return _declaration.getKind() == TypeKind.listType 
      || (getTypeArgumentLinks().isNotEmpty && getTypeArgumentLinks().length == 1)
      || T.toString().startsWith("List<") || T.toString().startsWith("Iterable")
      || T is List || T is Iterable || T == List || T == Set || T == Iterable 
      || isAssignableTo(Class.of<List>())
      || isAssignableTo(Class.of<Set>()) 
      || isAssignableTo(Class.of<Iterable>());
  }

  @override
  bool isKeyValuePaired() {
    checkAccess('isKeyValuePaired', DomainPermission.READ_TYPE_INFO);
    return (getTypeArgumentLinks().isNotEmpty && getTypeArgumentLinks().length >= 2) 
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
  Type getType() {
    checkAccess('getType', DomainPermission.READ_TYPE_INFO);
    return _declaration.getType();
  }

  @override
  Type getOriginal() {
    checkAccess('getOriginal', DomainPermission.READ_TYPE_INFO);
    return T;
  }

  @override
  Package? getPackage() {
    checkAccess('getPackage', DomainPermission.READ_TYPE_INFO);
    return _declaration.getDeclaration()?.getParentLibrary().getPackage();
  }

  @override
  Version? getVersion() {
    checkAccess("getVersion", DomainPermission.READ_TYPE_INFO);

    if (getPackage() case final package?) {
      return Version.parse(package.getVersion());
    }

    return null;
  }

  @override
  List<Class> getTypeParameters() {
    checkAccess('getTypeParameters', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findTypeParameters(this));
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
    
    final type = MetaClassLoader.extractKeyType(this);
    if (MetaClassLoader.findKeyType<K>(this, type) case final key?) {
      return key;
    }

    if (isKeyValuePaired() && (K.toString() == "dynamic" || K.toString() == "Object")) {
      return Class<Object>() as Class<K>;
    }

    return null;
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

    final type = MetaClassLoader.extractComponentType(this);
    if (MetaClassLoader.findComponentType<C>(this, type) case final component?) {
      return component;
    }

    if (isArray() && (C.toString() == "dynamic" || C.toString() == "Object")) {
      return Class<Object>() as Class<C>;
    }

    return null;
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
    return UnmodifiableListView(MetaClassLoader.findSuperClassArguments(this));
  }

  // =========================================== SUB CLASS METHODS ===========================================

  @override
  List<Class> getSubClasses() {
    checkAccess('getSubClasses', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findSubclasses(this));
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
      return UnmodifiableListView(MetaClassLoader.findAllConstraints(this, false));
    }

    return UnmodifiableListView(MetaClassLoader.findAllInterfaces(this, false));
  }

  @override
  List<Class> getAllDeclaredInterfaces() {
    checkAccess('getAllDeclaredInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return UnmodifiableListView(MetaClassLoader.findAllConstraints(this));
    }

    return UnmodifiableListView(MetaClassLoader.findAllInterfaces(this));
  }

  @override
  List<Class<I>> getInterfaces<I>() {
    checkAccess('getInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return UnmodifiableListView(MetaClassLoader.findConstraints<I>(this, false));
    }

    return UnmodifiableListView(MetaClassLoader.findInterfaces<I>(this, false));
  }

  @override
  List<Class<I>> getDeclaredInterfaces<I>() {
    checkAccess('getDeclaredInterfaces', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return UnmodifiableListView(MetaClassLoader.findConstraints<I>(this));
    }

    return UnmodifiableListView(MetaClassLoader.findInterfaces<I>(this));
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
      return UnmodifiableListView(MetaClassLoader.findConstraintArguments<I>(this, false));
    }

    return UnmodifiableListView(MetaClassLoader.findInterfaceArguments<I>(this, false));
  }

  @override
  List<Class> getDeclaredInterfaceArguments<I>() {
    checkAccess('getDeclaredInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return UnmodifiableListView(MetaClassLoader.findConstraintArguments<I>(this));
    }

    return UnmodifiableListView(MetaClassLoader.findInterfaceArguments<I>(this));
  }

  @override
  List<Class> getAllInterfaceArguments() {
    checkAccess('getAllInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return UnmodifiableListView(MetaClassLoader.findAllConstraintArguments(this, false));
    }

    return UnmodifiableListView(MetaClassLoader.findAllInterfaceArguments(this, false));
  }

  @override
  List<Class> getAllDeclaredInterfaceArguments() {
    checkAccess('getAllDeclaredInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    
    if(_declaration.asMixin() != null) {
      return UnmodifiableListView(MetaClassLoader.findAllConstraintArguments(this));
    }

    return UnmodifiableListView(MetaClassLoader.findAllInterfaceArguments(this));
  }

  // =========================================== MIXIN ACCESS METHODS ==========================================

  @override
  List<Class> getAllMixins() {
    checkAccess('getAllMixins', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findAllMixins(this, false));
  }

  @override
  List<Class> getAllDeclaredMixins() {
    checkAccess('getAllMixins', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findAllMixins(this));
  }
  
  @override
  List<Class> getMixinsArguments<M>() {
    checkAccess('getMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findMixinArguments<M>(this, false));
  }

  @override
  List<Class> getDeclaredMixinsArguments<M>() {
    checkAccess('getDeclaredMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findMixinArguments<M>(this));
  }
  
  @override
  List<Class> getAllMixinsArguments() {
    checkAccess('getAllMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findAllMixinArguments(this, false));
  }

  @override
  List<Class> getAllDeclaredMixinsArguments() {
    checkAccess('getAllDeclaredMixinsArguments', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findAllMixinArguments(this));
  }
  
  @override
  List<Class<I>> getMixins<I>() {
    checkAccess('getMixins', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findMixins<I>(this, false));
  }

  @override
  List<Class<I>> getDeclaredMixins<I>() {
    checkAccess('getDeclaredMixins', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(MetaClassLoader.findMixins<I>(this));
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
  List<Annotation> getAllDirectAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);

    final annotations = _declaration.getAnnotations();
    return UnmodifiableListView(annotations.map((a) => Annotation.declared(a, getProtectionDomain())));
  }

  @override
  List<Annotation> getAllAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);
    return UnmodifiableListView(_getAllAnnotations());
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
      if (annotation.getDeclaringClass().getType() == A) {
        return annotation.getInstance<A>();
      }
    }

    return null;
  }
  
  @override
  List<A> getAnnotations<A>() {
    checkAccess('getAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = getAllAnnotations();
    return UnmodifiableListView(annotations.where((a) => a.matches<A>()).map((a) => a.getInstance<A>()));
  }

  @override
  bool hasAnnotation<A>() {
    checkAccess('hasAnnotation', DomainPermission.READ_ANNOTATIONS);
    return getAnnotation<A>() != null;
  }

  // ========================================== DECLARED MEMBERS ========================================
  
  @override
  List<Member> getDeclaredMembers() {
    checkAccess('getDeclaredMembers', DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView([...getMethods(), ...getConstructors(), ...getFields()]);
  }

  // ============================================ FIELD METHODS ===============================================
  
  @override
  Field? getField(String name) {
    checkAccess('getField', DomainPermission.READ_TYPE_INFO);

    if (_declaration is EnumDeclaration) {
      final field = getEnumValuesAsFields().firstWhereOrNull((f) => f.getName().equals(name));
      if (field != null) {
        return field;
      }
    }

    return getFields().firstWhereOrNull((f) => f.getName().equals(name));
  }
  
  @override
  List<Field> getFields() {
    checkAccess('getFields', DomainPermission.READ_FIELDS);

    final fields = <Field>[..._declaration.getFields().map((field) => Field.declared(field, _declaration, _pd))];
    
    if (_declaration case EnumDeclaration declaration) {
      fields.addAll(declaration.getValues().map((f) => Field.declared(f, _declaration, _pd)));
    }

    final supertype = getSuperClass();
    if (supertype != null) {
      fields.addAll(supertype.getFields());
    }

    final interfaces = getInterfaces();
    for (final interface in interfaces) {
      fields.addAll(interface.getFields());
    }
    
    return UnmodifiableListView(fields);
  }

  @override
  List<Field> getEnumValuesAsFields() {
    checkAccess('getEnumValues', DomainPermission.READ_TYPE_INFO);

    if (!isEnum()) {
      throw InvalidArgumentException('Not an enum type. Always check `isEnum` before accessing this method');
    }

    final fields = <Field>[];
    
    if (_declaration case EnumDeclaration declaration) {
      fields.addAll(declaration.getValues().map((f) => Field.declared(f, declaration, _pd)).toList());
    }

    final supertype = getSuperClass();
    if (supertype != null && supertype is _Class && supertype.isEnum()) {
      try {
        fields.addAll(supertype.getEnumValuesAsFields());
      } on InvalidArgumentException catch (_) {}
    }
    
    return UnmodifiableListView(fields);
  }

  @override
  List<EnumValue> getEnumValues() {
    checkAccess('getEnumValues', DomainPermission.READ_TYPE_INFO);

    if (!isEnum()) {
      throw InvalidArgumentException('Not an enum type. Always check `isEnum` before accessing this method');
    }

    final fields = <EnumValue>[];
    
    if (_declaration case EnumDeclaration declaration) {
      fields.addAll(declaration.getValues().map((f) => EnumValue.declared(declaration, f, _pd)).toList());
    }

    final supertype = getSuperClass();
    if (supertype != null && supertype is _Class && supertype.isEnum()) {
      try {
        fields.addAll(supertype.getEnumValues());
      } on InvalidArgumentException catch (_) {}
    }
    
    return UnmodifiableListView(fields);
  }

  // ============================================= METHOD METHODS ==========================================
  
  @override
  Method? getMethod(String name) {
    checkAccess('getMethod', DomainPermission.READ_METHODS);
    return getMethods().firstWhereOrNull((m) => m.getName().equals(name));
  }
  
  @override
  Method? getMethodBySignature(String name, List<Class> parameterTypes) {
    checkAccess('getMethodBySignature', DomainPermission.READ_METHODS);

    final methods = getMethods();
    
    for (final method in methods) {
      if (method.getName() == name) {
        final params = method.getParameters();

        if (params.length == parameterTypes.length) {
          bool matches = true;

          for (int i = 0; i < params.length; i++) {
            final param = params[i];
            final parameterType = parameterTypes[i];

            if (!param.getReturnClass().isInstance(parameterType) || param.getReturnClass() != parameterType || param.getReturnClass().getType() != parameterType.getType()) {
              matches = false;
              break;
            }
          }

          if (matches) {
            return method;
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
    
    methods.addAll(_declaration.getMethods().map((m) => Method.declared(m, _pd)).toList());

    if (_declaration case MixinDeclaration mixin) {
      methods.addAll(
        mixin.getConstraints()
          .map((link) => _Class.fromQualifiedName(link.getPointerQualifiedName(), _pd, link).getMethods())
          .flatMap((m) => m.toList()).toList()
      );
    }

    final supertype = getSuperClass();
    if (supertype != null) {
      methods.addAll(supertype.getMethods());
    }

    final interfaces = getInterfaces();
    for (final interface in interfaces) {
      methods.addAll(interface.getMethods());
    }

    return UnmodifiableListView(methods);
  }

  @override
  List<Method> getAllMethodsInHierarchy() {
    checkAccess('getAllMethodsInHierarchy', DomainPermission.READ_METHODS);
    
    final methods = _declaration.getAllMethodsInHierarchy();
    return UnmodifiableListView(methods.map((m) => Method.declared(m, _pd)));
  }
  
  @override
  List<Method> getOverriddenMethods() {
    checkAccess('getOverriddenMethods', DomainPermission.READ_METHODS);
    return getMethods().where((m) => m.isOverride()).toList();
  }
  
  @override
  List<Method> getMethodsByName(String name) {
    checkAccess('getMethodsByName', DomainPermission.READ_METHODS);
    return getMethods().where((m) => m.getName() == name).toList();
  }

  // =========================================== CONSTRUCTOR METHODS ===========================================
  
  @override
  Constructor? getConstructor(String name) {
    checkAccess('getConstructor', DomainPermission.READ_CONSTRUCTORS);
    final constructors = getConstructors();
    return constructors.firstWhereOrNull((c) => c.getName().equals(name));
  }

  @override
  Constructor? getConstructorBySignature(List<Class> parameterTypes) {
    checkAccess('getConstructorBySignature', DomainPermission.READ_CONSTRUCTORS);

    final constructors = getConstructors();
    
    for (final constructor in constructors) {
      final params = constructor.getParameters();

      if (params.length == parameterTypes.length) {
        bool matches = true;

        for (int i = 0; i < params.length; i++) {
          final param = params[i];
          final parameterType = parameterTypes[i];

          if (!param.getReturnClass().isInstance(parameterType) || param.getReturnClass() != parameterType || param.getReturnClass().getType() != parameterType.getType()) {
            matches = false;
            break;
          }
        }

        if (matches) {
          return constructor;
        }
      }
    }
    
    return null;
  }

  @override
  Constructor? getBestConstructor(List<Class> parameterTypes) {
    checkAccess('getBestConstructor', DomainPermission.READ_CONSTRUCTORS);

    final constructors = getConstructors();
    Constructor? best;
    int bestScore = -1;

    for (final constructor in constructors) {
      final params = constructor.getParameters();
      final positionalParams = constructor.getPositionalParameters();
      final namedParams = constructor.getNamedParameters();

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
          final paramClass = param.getReturnClass();
          if (paramClass == providedType) {
            score += 3; // exact
          } else if (paramClass.isAssignableFrom(providedType)) {
            score += 2; // assignable (subclass)
          } else {
            // If param is nullable (type allows null), still accept but lower score if provided is null-type?
            if (param.isNullable() || param.isPositional() && !param.isRequired()) {
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
        if (param.mustBeResolved() && !param.hasDefaultValue()) {
          fits = false;
          break;
        }
        // optional/nullable/default -> acceptable, minor score
        score += 1;
      }

      if (!fits) continue;

      // Named params: if they are all optional/have defaults or nullable then acceptable
      for (final p in namedParams) {
        if (p.mustBeResolved() && !p.hasDefaultValue()) {
          fits = false;
          break;
        }
        score +=  (p.hasDefaultValue() ? 1 : 1);
      }
      if (!fits) continue;

      // Prefer constructor with higher score, tie-break with fewer required missing params and fewer params overall
      if (score > bestScore || (score == bestScore && (best == null || params.length < best.getParameters().length))) {
        bestScore = score;
        best = constructor;
      }
    }

    return best;
  }
  
  @override
  List<Constructor> getConstructors() {
    checkAccess('getConstructors', DomainPermission.READ_CONSTRUCTORS);
    final constructors = _declaration.getConstructors();
    return UnmodifiableListView(constructors.map((c) => Constructor.declared(c, _pd)));
  }

  @override
  Constructor? getDefaultConstructor() {
    checkAccess('getDefaultConstructor', DomainPermission.READ_CONSTRUCTORS);

    final constructors = getConstructors();
    return constructors.firstWhereOrNull((c) => c.getName().isEmpty);
  }

  @override
  Constructor? getNoArgConstructor([bool acceptWhenAllParametersAreOptional = false]) {
    checkAccess('getNoArgConstructor', DomainPermission.READ_CONSTRUCTORS);

    final constructors = getConstructors();
    Constructor? constructor = constructors.firstWhereOrNull((c) => c.getParameters().isEmpty);

    if(acceptWhenAllParametersAreOptional && constructor == null) {
      constructor = constructors.find((c) => c.getParameters().all((p) => p.isNullable()));
    }

    return constructor;
  }

  // ============================================ INSTANCE METHODS ===========================================
  
  @override
  T newInstance([Map<String, dynamic>? arguments, String? constructorName]) {
    checkAccess('newInstance', DomainPermission.CREATE_INSTANCES);

    // Try with constructor name, if provided
    if(constructorName != null) {
      final constructor = getConstructor(constructorName);
      if (constructor == null) {
        throw ConstructorNotFoundException(getName(), constructorName);
      }
      
      return constructor.newInstance<T>(arguments ?? {});
    }

    // If arguments is not null, try to determine constructor to use.
    if(arguments case final arguments?) {
      final constructors = getConstructors();
      final constructor = constructors.firstWhereOrNull((c) => c.canAcceptArguments(arguments));
      if (constructor case final constructor?) {
        return constructor.newInstance<T>(arguments);
      }
    }

    // Resort to last option of default constructor.
    final constructor = getDefaultConstructor();
    if (constructor == null) {
      throw ConstructorNotFoundException(getName(), "");
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

    if (clazz case MixinDeclaration mixin) {
      // Add methods from constraints
      for (final constraint in mixin.getConstraints()) {
        final interfaceClass = Class.fromQualifiedName(constraint.getPointerQualifiedName(), ProtectionDomain.system()).getClassDeclaration().asClass();
        if (interfaceClass != null) {
          _collectMethodsFromHierarchy(interfaceClass, allMethods, visited);
        }
      }
    }
    
    // Add methods from superclass
    final supertype = clazz.getSuperClass();
    if (supertype != null) {
      final superclass = Class.fromQualifiedName(supertype.getPointerQualifiedName(), ProtectionDomain.system()).getClassDeclaration().asClass();
      if (superclass != null) {
        _collectMethodsFromHierarchy(superclass, allMethods, visited);
      }
    }
    
    // Add methods from interfaces
    for (final interfaceType in clazz.getInterfaces()) {
      final interfaceClass = Class.fromQualifiedName(interfaceType.getPointerQualifiedName(), ProtectionDomain.system()).getClassDeclaration().asClass();
      if (interfaceClass != null) {
        _collectMethodsFromHierarchy(interfaceClass, allMethods, visited);
      }
    }
    
    // Add methods from mixins
    for (final mixinType in clazz.getMixins()) {
      final mixinDeclaration = Class.fromQualifiedName(mixinType.getPointerQualifiedName(), ProtectionDomain.system()).getClassDeclaration().asMixin();
      if (mixinDeclaration != null) {
        allMethods.addAll(mixinDeclaration.getMethods());
      }
    }
  }
}