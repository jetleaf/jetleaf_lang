part of 'function_class.dart';

final class _FunctionClass extends FunctionClass with EqualsAndHashCode {
  final ProtectionDomain _pd;
  final FunctionLinkDeclaration _functionLinkDeclaration;

  _FunctionClass(this._functionLinkDeclaration, this._pd);

  @override
  Class<C>? componentType<C>() {
    checkAccess("componentType", DomainPermission.READ_TYPE_INFO);

    final args = _functionLinkDeclaration.getTypeArguments();
    if (args.isNotEmpty) {
      final link = args.length == 1 ? args[0] : args[1];
      final component = MetaClassLoader.getFromLink(link, _pd);
      return Class.fromQualifiedName(component.getQualifiedName(), _pd, link);
    }

    final componentDeclaration = MetaClassLoader.extractComponentType(this);
    return MetaClassLoader.findComponentType<C>(this, componentDeclaration);
  }

  @override
  List<Object?> equalizedProperties() => [...super.equalizedProperties(), _functionLinkDeclaration];

  @override
  FunctionLinkDeclaration getFunctionDeclaration() {
    checkAccess("getFunctionDeclaration", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration;
  }
  
  @override
  bool getIsNullable() {
    checkAccess("isNullable", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration.isNullable();
  }
  
  @override
  Method? getMethod(String name) => super.getMethod(name) ?? getMethodCall();
  
  @override
  Method? getMethodBySignature(String name, List<Class> parameterTypes) => super.getMethodBySignature(name, parameterTypes) ?? getMethodCall();
  
  @override
  Method? getMethodCall() {
    checkAccess("getMethodCall", DomainPermission.READ_METHODS);

    if (_functionLinkDeclaration.getMethodCall() case final method?) {
      return Method.declared(method, _pd);
    }
    
    return null;
  }
  
  @override
  List<Method> getMethods() {
    checkAccess("getMethods", DomainPermission.READ_METHODS);
  
    if (getMethodCall() case final method?) {
      return [method, ...super.getMethods()];
    }

    return super.getMethods();
  }
  
  @override
  String getName() {
    checkAccess("getName", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration.getName();
  }
  
  @override
  List<Class<Object>> getParameters() {
    checkAccess("getParameters", DomainPermission.READ_TYPE_INFO);

    final params = <Class<Object>>[];

    for (final link in _functionLinkDeclaration.getParameters()) {
      final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
      params.add(Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link));
    }

    return UnmodifiableListView(params);
  }
  
  @override
  String getQualifiedName() => _functionLinkDeclaration.getPointerQualifiedName();
  
  @override
  Class<Object> getReturnType() {
    checkAccess("getReturnType", DomainPermission.READ_TYPE_INFO);
  
    final returnType = _functionLinkDeclaration.getReturnType();
    final keyDeclaration = MetaClassLoader.getFromLink(returnType, _pd);
    return Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, returnType);
  }
  
  @override
  String getSignature() {
    checkAccess("getSignature", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration.getSignature();
  }
  
  @override
  List<Class<Object>> getTypeParameters() {
    checkAccess("getTypeParameters", DomainPermission.READ_TYPE_INFO);

    final params = <Class<Object>>[];

    for (final link in _functionLinkDeclaration.getTypeParameters()) {
      final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
      params.add(Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link));
    }

    return UnmodifiableListView(params);
  }
  
  @override
  bool hasGenerics() {
    checkAccess("hasGenerics", DomainPermission.READ_TYPE_INFO);
    return getTypeArgumentLinks().isNotEmpty;
  }
  
  @override
  bool isAssignableFrom(Class other) {
    if (other is! FunctionClass) {
      return false;
    }

    bool isAssignableFrom = true;
    final params = getParameters();
    final otherParams = other.getParameters();

    if (params.length != otherParams.length) return false;

    for (int i = 0; i < params.length; i++) {
      final thisParam = params[i];
      final otherParam = otherParams[i];

      if (!thisParam.isAssignableFrom(otherParam)) {
        isAssignableFrom = false;
      }
    }

    return getReturnType().isAssignableFrom(other.getReturnType()) && isAssignableFrom;
  }
  
  @override
  bool isAssignableTo(Class other) {
    if (other is! FunctionClass) {
      return false;
    }

    return other.isAssignableFrom(this);
  }
  
  @override
  bool isKeyValuePaired() {
    checkAccess('isKeyValuePaired', DomainPermission.READ_TYPE_INFO);
    return getTypeArgumentLinks().isNotEmpty && getTypeArgumentLinks().length >= 2;
  }

  @override
  bool isFunction() {
    checkAccess("isFunction", DomainPermission.READ_TYPE_INFO);
    return true;
  }

  @override
  bool isCanonical() {
    checkAccess("isCanonical", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration.getIsCanonical();
  }

  @override
  bool isPublic() {
    checkAccess("isPublic", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration.getIsPublic();
  }

  @override
  bool isSynthetic() {
    checkAccess("isSynthetic", DomainPermission.READ_TYPE_INFO);
    return _functionLinkDeclaration.getIsSynthetic();
  }

  @override
  List<LinkDeclaration> getTypeArgumentLinks() {
    checkAccess("getTypeArgumentLinks", DomainPermission.READ_TYPE_INFO);
    return UnmodifiableListView(_functionLinkDeclaration.getTypeArguments());
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
  
  @override
  Class<K>? keyType<K>() {
    checkAccess('keyType', DomainPermission.READ_TYPE_INFO);

    if (!isKeyValuePaired()) return null;

    final args = _functionLinkDeclaration.getTypeArguments();
    if (args.isNotEmpty && args.length < 2) {
      final link = args[0];
      final keyDeclaration = MetaClassLoader.getFromLink(link, _pd);
      return Class.fromQualifiedName(keyDeclaration.getQualifiedName(), _pd, link);
    }
    
    final keyDeclaration = MetaClassLoader.extractKeyType(this);
    return MetaClassLoader.findKeyType<K>(this, keyDeclaration);
  }
}