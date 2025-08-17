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
class _Class<T> implements Class<T> {
  String _name;
  final ProtectionDomain _pd;

  late final TypeDeclaration _declaration;
  
  // Lazy-loaded properties
  Type? _componentDeclaration;
  Type? _keyDeclaration;
  
  _Class(this._name, this._pd) {
    final result = TypeDiscovery.findByName(_name) ?? TypeDiscovery.findByType(T);
    if(result == null) {
      throw UnsupportedOperationException("Class of $T was not found in the application's context");
    }

    _declaration = result;
    _componentDeclaration = MetaClassLoader.extractComponentType(this);
    _keyDeclaration = MetaClassLoader.extractKeyType(this);
  }

  _Class.fromSimpleName(this._name, this._pd) {
    final result = TypeDiscovery.findBySimpleName(_name);
    if(result == null) {
      throw UnsupportedOperationException("$_name was not found in the application's context");
    }

    _declaration = result;
    _name = result.getName();
    _componentDeclaration = MetaClassLoader.extractComponentType(this);
    _keyDeclaration = MetaClassLoader.extractKeyType(this);
  }

  _Class.fromQualifiedName(this._name, this._pd) {
    final result = TypeDiscovery.findByQualifiedName(_name);
    if(result == null) {
      throw UnsupportedOperationException("$_name was not found in the application's context");
    }

    _declaration = result;
    _name = result.getName();
    _componentDeclaration = MetaClassLoader.extractComponentType(this);
    _keyDeclaration = MetaClassLoader.extractKeyType(this);
  }

  _Class.declared(TypeDeclaration declaration, ProtectionDomain domain) : _name = declaration.getName(), _pd = domain {
    _declaration = declaration;
    _componentDeclaration = MetaClassLoader.extractComponentType(this);
    _keyDeclaration = MetaClassLoader.extractKeyType(this);
  }

  // ======================================= META OVERRIDDEN METHODS =========================================

  @override
  void checkAccess(String operation, DomainPermission permission) {
    getProtectionDomain().checkAccess(operation, permission);
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
    return annotations.where((a) => a.getClass().getType() == A).map((a) => a.getInstance<A>()).toList();
  }

  @override
  bool hasAnnotation<A>() {
    checkAccess('hasAnnotation', DomainPermission.READ_ANNOTATIONS);
    return getAnnotation<A>() != null;
  }

  @override
  List<Annotation> getAllAnnotations() {
    checkAccess('getAllAnnotations', DomainPermission.READ_ANNOTATIONS);
    final annotations = _declaration.getDeclaration()?.getAnnotations();
    return annotations?.map((a) => Annotation.declared(a, getProtectionDomain())).toList() ?? [];
  }

  // ============================================== NAME METHODS ===============================================

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

  // ========================================== COMPARABLE METHODS ==============================================
  
  @override
  bool isCanonical() => getName() == getCanonicalName();

  @override
  bool isInstance(Object? obj) {
    if (obj == null) return false;

    if(obj is Class && obj.getType() == getType()) {
      return true;
    }

    if(obj is Class && obj.getDeclaration() == getDeclaration()) {
      return true;
    }

    final clazz = obj.getClass();

    if(clazz.getType() == getType()) {
      return true;
    }

    return _declaration.isAssignableFrom(clazz.getDeclaration());
  }
  
  @override
  bool isAssignableFrom(Class other) {
    if(_declaration.isAssignableFrom(other.getDeclaration())) {
      return true;
    }

    return other.isAssignableTo(this);
  }

  @override
  bool isAssignableTo(Class other) {
    if(_declaration.isAssignableTo(other.getDeclaration())) {
      return true;
    }

    if(isSubclassOf(other)) {
      return true;
    }

    if(getAllInterfaces().contains(other) || getAllInterfaces().any((i) => i.getType() == other.getType())) {
      return true;
    }

    return false;
  }
  
  @override
  bool isSubclassOf(Class other) {
    final superClass = getSuperClass();
    if (superClass == null) return false;
    return superClass == other || superClass.isSubclassOf(other) || superClass.getType() == other.getType();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if(other is Class && (other.getName() == this.getName() 
      && other.getSimpleName() == this.getSimpleName()
      && other.getQualifiedName() == this.getQualifiedName()
      && other.getPackageUri() == this.getPackageUri()
      && other.toString() == this.toString()
    )) {
      return true;
    }

    return other is _Class && other._declaration == _declaration;
  }
  
  @override
  int get hashCode => Object.hashAll([
    _declaration.getName(),
    _declaration.getSimpleName(),
    _declaration.getQualifiedName(),
    _declaration.getPackageUri(),
    _declaration.getTypeArguments().map((a) => a.getType()),
    _declaration.asClass()?.getMethods().map((a) => a.getName()),
    _declaration.asClass()?.getConstructors().map((a) => a.getName()),
    _declaration.getKind(),
    _declaration.getDebugIdentifier(),
    _declaration.getType(),
    toString()
  ]);
  
  @override
  String toString() => 'Class<${getName()}>:Class<${getType()}>:${getQualifiedName()}';

  // =========================================== HELPER METHODS ===============================================

  @override
  bool isAbstract() {
    checkAccess('isAbstract', DomainPermission.READ_TYPE_INFO);
    return _declaration.asClass()?.getIsAbstract() ?? false;
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
    return _declaration.asTypeVariable() != null;
  }
  
  @override
  bool isTypedef() {
    checkAccess('isTypedef', DomainPermission.READ_TYPE_INFO);
    return _declaration.asTypedef() != null;
  }

  @override
  bool hasGenerics() => GenericTypeParser.isGeneric(T.toString()) || GenericTypeParser.isGeneric(_name);

  @override
  bool isArray() {
    checkAccess('isArray', DomainPermission.READ_TYPE_INFO);
    return _declaration.getKind() == TypeKind.listType 
      || (_declaration.getTypeArguments().isNotEmpty && _declaration.getTypeArguments().length == 1)
      || T.toString().startsWith("List<") || T.toString().startsWith("Iterable")
      || T is List || T is Iterable || T == List || T == Set || T == Iterable 
      || isAssignableTo(Class.of<List>())
      || isAssignableTo(Class.of<Set>()) 
      || isAssignableTo(Class.of<Iterable>());
  }

  @override
  bool isKeyValuePaired() {
    checkAccess('isKeyValuePaired', DomainPermission.READ_TYPE_INFO);
    return (_declaration.getTypeArguments().isNotEmpty && _declaration.getTypeArguments().length >= 2) 
      || _declaration.getKind() == TypeKind.mapType
      || T == Map 
      || isAssignableTo(Class.of<Map>()) 
      || isAssignableTo(Class.of<MapEntry>());
  }

  @override
  bool isPrimitive() {
    checkAccess('isPrimitive', DomainPermission.READ_TYPE_INFO);
    return _declaration.getKind() == TypeKind.primitiveType;
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
    return MetaClassLoader.findTypeParameters(this);
  }

  @override
  ProtectionDomain getProtectionDomain() => _pd;

  // =========================================== NESTED ACCESSORS ==============================================

  @override
  Class<K>? keyType<K>() {
    checkAccess('keyType', DomainPermission.READ_TYPE_INFO);

    if (!isKeyValuePaired()) return null;
    
    return MetaClassLoader.findKeyType<K>(this, _keyDeclaration);
  }
  
  @override
  Class<C>? componentType<C>() {
    checkAccess('componentType', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findComponentType<C>(this, _componentDeclaration);
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
    return MetaClassLoader.findAllInterfaces(this, false);
  }

  @override
  List<Class> getAllDeclaredInterfaces() {
    checkAccess('getAllDeclaredInterfaces', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findAllInterfaces(this);
  }

  @override
  List<Class<I>> getInterfaces<I>() {
    checkAccess('getInterfaces', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findInterfaces<I>(this, false);
  }

  @override
  List<Class<I>> getDeclaredInterfaces<I>() {
    checkAccess('getDeclaredInterfaces', DomainPermission.READ_TYPE_INFO);
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
    return MetaClassLoader.findInterfaceArguments<I>(this, false);
  }

  @override
  List<Class> getDeclaredInterfaceArguments<I>() {
    checkAccess('getDeclaredInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findInterfaceArguments<I>(this);
  }

  @override
  List<Class> getAllInterfaceArguments() {
    checkAccess('getAllInterfaceArguments', DomainPermission.READ_TYPE_INFO);
    return MetaClassLoader.findAllInterfaceArguments(this, false);
  }

  @override
  List<Class> getAllDeclaredInterfaceArguments() {
    checkAccess('getAllDeclaredInterfaceArguments', DomainPermission.READ_TYPE_INFO);
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

  // ============================================== ENUM METHODS ============================================

  @override
  List<EnumField> getEnumValues() {
    checkAccess('getEnumValues', DomainPermission.READ_TYPE_INFO);
    if (!isEnum()) {
      throw InvalidArgumentException('Not an enum type');
    }
    
    final enumType = _declaration.asEnum();
    if (enumType != null) {
      return enumType.getValues().map((v) => EnumField.declared(v, _pd)).toList();
    }
    
    throw InvalidArgumentException('Cannot retrieve enum values');
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
    
    if (_declaration.asClass() == null) return null;
    
    final field = _declaration.asClass()!.getFields().firstWhereOrNull((f) => f.getName().equals(name));
    return field != null ? Field.declared(field, _pd) : null;
  }
  
  @override
  List<Field> getFields() {
    checkAccess('getFields', DomainPermission.READ_FIELDS);

    final fields = _declaration.asClass()?.getFields() ?? [];
    return fields.map((f) => Field.declared(f, _pd)).toList();
  }

  // ============================================= METHOD METHODS ==========================================
  
  @override
  Method? getMethod(String name) {
    checkAccess('getMethod', DomainPermission.READ_METHODS);
    
    if (_declaration.asClass() == null) return null;
    
    final method = _declaration.asClass()!.getMethods().firstWhereOrNull((m) => m.getName().equals(name));
    return method != null ? Method.declared(method, _pd) : null;
  }
  
  @override
  Method? getMethodBySignature(String name, List<Class> parameterTypes) {
    checkAccess('getMethodBySignature', DomainPermission.READ_METHODS);

    final methods = _declaration.asClass()?.getMethods() ?? [];
    
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
    
    final methods = _declaration.asClass()?.getMethods() ?? [];
    return methods.map((m) => Method.declared(m, _pd)).toList();
  }
  
  @override
  List<Method> getMethodsByName(String name) {
    checkAccess('getMethodsByName', DomainPermission.READ_METHODS);
    
    final methods = _declaration.asClass()?.getMethods() ?? [];
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
  List<Constructor> getConstructors() {
    checkAccess('getConstructors', DomainPermission.READ_CONSTRUCTORS);
    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    return constructors.map((c) => Constructor.declared(c, _pd)).toList();
  }

  @override
  Constructor? getDefaultConstructor() {
    checkAccess('getDefaultConstructor', DomainPermission.READ_CONSTRUCTORS);
    final constructors = _declaration.asClass()?.getConstructors() ?? [];
    ConstructorDeclaration? defaultConstructor = constructors.firstWhereOrNull((c) => c.getName().isEmpty);
    return defaultConstructor != null ? Constructor.declared(defaultConstructor, _pd) : null;
  }

  // ============================================ INSTANCE METHODS ===========================================
  
  @override
  T newInstance([Map<String, dynamic>? arguments]) {
    checkAccess('newInstance', DomainPermission.CREATE_INSTANCES);
    if (_declaration.asClass() == null) {
      throw IllegalStateException('Cannot create instance of ${getType()} - no constructor data available');
    }

    final constructor = getDefaultConstructor();
    if (constructor == null) {
      throw IllegalStateException('Constructor not found in ${getType()}');
    }
    
    return constructor.newInstance<T>(arguments ?? {});
  }
  
  @override
  T newInstanceWithConstructor(String constructorName, [Map<String, dynamic>? arguments]) {
    checkAccess('newInstanceWithConstructor', DomainPermission.CREATE_INSTANCES);
    final constructor = getConstructor(constructorName);
    if (constructor == null) {
      throw IllegalStateException('Constructor $constructorName not found in ${getType()}');
    }
    
    return constructor.newInstance<T>(arguments ?? {});
  }

  @override
  TypeDeclaration getDeclaration() {
    checkAccess('getDeclaration', DomainPermission.READ_TYPE_INFO);
    return _declaration;
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
      final superclass = Class.forType(supertype.getPointerType(), ProtectionDomain.system()).getDeclaration().asClass();
      if (superclass != null) {
        _collectMethodsFromHierarchy(superclass, allMethods, visited);
      }
    }
    
    // Add methods from interfaces
    for (final interfaceType in clazz.getInterfaces()) {
      final interfaceClass = Class.forType(interfaceType.getPointerType(), ProtectionDomain.system()).getDeclaration().asClass();
      if (interfaceClass != null) {
        _collectMethodsFromHierarchy(interfaceClass, allMethods, visited);
      }
    }
    
    // Add methods from mixins
    for (final mixinType in clazz.getMixins()) {
      final mixinDeclaration = Class.forType(mixinType.getPointerType(), ProtectionDomain.system()).getDeclaration().asMixin();
      if (mixinDeclaration != null) {
        allMethods.addAll(mixinDeclaration.getMethods());
      }
    }
  }
}