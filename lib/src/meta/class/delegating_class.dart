import 'package:jetleaf_build/jetleaf_build.dart';

import '../../commons/version.dart';
import '../annotation/annotation.dart';
import '../constructor/constructor.dart';
import '../core.dart';
import '../enum/enum_value.dart';
import '../field/field.dart';
import '../method/method.dart';
import '../protection_domain/protection_domain.dart';
import 'class.dart';

/// {@template delegating_class}
/// An abstract base implementation of [Class] that **delegates all reflective
/// operations** to an internal [Class] instance.
///
/// `DelegatingClass` is designed for scenarios where additional behavior,
/// metadata, interception, or specialization needs to be layered on top of
/// JetLeaf’s core reflective [Class] model **without re-implementing** the
/// entire API surface.
///
/// This follows the **delegation pattern** rather than inheritance-based
/// extension, allowing subclasses to selectively override behavior while
/// preserving consistent reflection semantics.
///
/// Typical use cases include:
/// - Augmenting class metadata during build-time or runtime analysis
/// - Decorating or proxying reflective behavior
/// - Adapting generated classes to framework-specific abstractions
/// - Injecting cross-cutting concerns such as diagnostics or access control
///
/// Subclasses are free to override any method while relying on the delegate
/// for default behavior.
///
/// {@endtemplate}
@Generic(DelegatingClass)
abstract class DelegatingClass<T> extends Source implements Class<T> {
  /// The underlying [Class] instance to which all reflective operations
  /// are delegated by default.
  ///
  /// This delegate represents the canonical reflection model for the target
  /// type [T]. Subclasses may rely on it for standard behavior or selectively
  /// override methods to alter or enrich reflection results.
  ///
  /// The delegate is eagerly initialized and remains immutable for the
  /// lifetime of this [DelegatingClass] instance.
  final Class<T> _delegate = Class<T>();

  /// {@macro delegating_class}
  DelegatingClass();

  @override
  Class<C>? componentType<C>() => _delegate.componentType<C>();

  @override
  List<Object?> equalizedProperties() => _delegate.equalizedProperties();

  @override
  List<Annotation> getAllAnnotations() => _delegate.getAllAnnotations();

  @override
  List<Class> getAllDeclaredInterfaceArguments() => _delegate.getAllDeclaredInterfaceArguments();

  @override
  List<Class> getAllDeclaredInterfaces() => _delegate.getAllDeclaredInterfaces();

  @override
  List<Class> getAllDeclaredMixins() => _delegate.getAllDeclaredMixins();

  @override
  List<Class> getAllDeclaredMixinsArguments() => _delegate.getAllDeclaredMixinsArguments();

  @override
  List<Annotation> getAllDirectAnnotations() => _delegate.getAllDirectAnnotations();

  @override
  List<Class> getAllInterfaceArguments() => _delegate.getAllInterfaceArguments();

  @override
  List<Class> getAllInterfaces() => _delegate.getAllInterfaces();

  @override
  List<Method> getAllMethodsInHierarchy() => _delegate.getAllMethodsInHierarchy();

  @override
  List<Class> getAllMixins() => _delegate.getAllMixins();

  @override
  List<Class> getAllMixinsArguments() => _delegate.getAllMixinsArguments();

  @override
  A? getAnnotation<A>() => _delegate.getAnnotation<A>();

  @override
  List<A> getAnnotations<A>() => _delegate.getAnnotations<A>();

  @override
  Constructor? getBestConstructor(List<Class> paramTypes) => _delegate.getBestConstructor(paramTypes);

  @override
  String getCanonicalName() => _delegate.getCanonicalName();

  @override
  ClassDeclaration getClassDeclaration() => _delegate.getClassDeclaration();

  @override
  Constructor? getConstructor(String name) => _delegate.getConstructor(name);

  @override
  Constructor? getConstructorBySignature(List<Class> paramTypes) => _delegate.getConstructorBySignature(paramTypes);

  @override
  List<Constructor> getConstructors() => _delegate.getConstructors();

  @override
  Declaration getDeclaration() => _delegate.getDeclaration();

  @override
  Class<I>? getDeclaredInterface<I>() => _delegate.getDeclaredInterface<I>();

  @override
  List<Class> getDeclaredInterfaceArguments<I>() => _delegate.getDeclaredInterfaceArguments<I>();

  @override
  List<Class<I>> getDeclaredInterfaces<I>() => _delegate.getDeclaredInterfaces<I>();

  @override
  List<Member> getDeclaredMembers() => _delegate.getDeclaredMembers();

  @override
  Class<I>? getDeclaredMixin<I>() =>  _delegate.getDeclaredMixin<I>();

  @override
  List<Class<I>> getDeclaredMixins<I>() =>  _delegate.getDeclaredMixins<I>();
  
  @override
  List<Class> getDeclaredMixinsArguments<M>() =>  _delegate.getDeclaredMixinsArguments<M>();
  
  @override
  Class? getDeclaredSuperClass() =>  _delegate.getDeclaredSuperClass();
  
  @override
  Constructor? getDefaultConstructor() =>  _delegate.getDefaultConstructor();
  
  @override
  List<EnumValue> getEnumValues() =>  _delegate.getEnumValues();
  
  @override
  List<Field> getEnumValuesAsFields() =>  _delegate.getEnumValuesAsFields();
  
  @override
  Field? getField(String name) =>  _delegate.getField(name);
  
  @override
  List<Field> getFields() =>  _delegate.getFields();
  
  @override
  Class<I>? getInterface<I>() =>  _delegate.getInterface<I>();
  
  @override
  List<Class> getInterfaceArguments<I>() =>  _delegate.getInterfaceArguments<I>();
  
  @override
  List<Class<I>> getInterfaces<I>() =>  _delegate.getInterfaces<I>();
  
  @override
  Method? getMethod(String name) => _delegate.getMethod(name);
  
  @override
  Method? getMethodBySignature(String name, List<Class> parameterTypes) => _delegate.getMethodBySignature(name, parameterTypes);
  
  @override
  List<Method> getMethods() => _delegate.getMethods();
  
  @override
  List<Method> getMethodsByName(String name) => getMethods().where(((m) => m.getName() == name)).toList();
  
  @override
  Class<I>? getMixin<I>() =>  _delegate.getMixin<I>();
  
  @override
  List<Class<I>> getMixins<I>() =>  _delegate.getMixins<I>();
  
  @override
  List<Class> getMixinsArguments<M>() => [];
  
  @override
  List<String> getModifiers() => _delegate.getModifiers();
  
  @override
  String getName() => _delegate.getName();
  
  @override
  Constructor? getNoArgConstructor([bool acceptWhenAllParametersAreOptional = false]) => null;
  
  @override
  Type getOriginal() => T;
  
  @override
  List<Method> getOverriddenMethods() => [];
  
  @override
  Package? getPackage() => _delegate.getPackage();
  
  @override
  String getPackageUri() => _delegate.getPackageUri();

  @override
  ProtectionDomain getProtectionDomain() => _delegate.getProtectionDomain();
  
  @override
  String getQualifiedName() => _delegate.getQualifiedName();
  
  @override
  String getSignature() => _delegate.getSignature();
  
  @override
  String getSimpleName() => _delegate.getSimpleName();
  
  @override
  Class<S>? getSubClass<S>() => _delegate.getSubClass<S>();
  
  @override
  List<Class> getSubClasses() => _delegate.getSubClasses();
  
  @override
  Class<S>? getSuperClass<S>() => _delegate.getSuperClass<S>();
  
  @override
  List<Class> getSuperClassArguments() => _delegate.getSuperClassArguments();
  
  @override
  Type getType() => _delegate.getType();

  @override
  List<LinkDeclaration> getTypeArgumentLinks() => _delegate.getTypeArgumentLinks();

  @override
  List<Class<Object>> getTypeArguments() => _delegate.getTypeArguments();
  
  @override
  List<Class> getTypeParameters() => _delegate.getTypeParameters();

  @override
  Version? getVersion() => _delegate.getVersion();

  @override
  bool hasAnnotation<A>() => _delegate.hasAnnotation<A>();
  
  @override
  bool hasGenerics() => _delegate.hasGenerics();
  
  @override
  bool isAbstract() => _delegate.isAbstract();
  
  @override
  bool isArray() => _delegate.isArray();
  
  @override
  bool isAssignableFrom(Class other) => _delegate.isAssignableFrom(other);
  
  @override
  bool isAssignableTo(Class other) => _delegate.isAssignableTo(other);
  
  @override
  bool isAsync() => _delegate.isAsync();
  
  @override
  bool isBase() => _delegate.isBase();
  
  @override
  bool isCanonical() => _delegate.isCanonical();
  
  @override
  bool isClass() => _delegate.isClass();
  
  @override
  bool isEnum() => _delegate.isEnum();
  
  @override
  bool isFinal() => _delegate.isFinal();

  @override
  bool isFunction() => _delegate.isFunction();

  @override
  bool isVoid() => _delegate.isVoid();

  @override
  bool isDynamic() => _delegate.isDynamic();
  
  @override
  bool isInstance(Object? obj) => _delegate.isInstance(obj);
  
  @override
  bool isInterface() => _delegate.isInterface();
  
  @override
  bool isInvokable() => _delegate.isInvokable();
  
  @override
  bool isKeyValuePaired() => _delegate.isKeyValuePaired();
  
  @override
  bool isMixin() => _delegate.isMixin();
  
  @override
  bool isPrimitive() => _delegate.isPrimitive();
  
  @override
  bool isPublic() => _delegate.isPublic();
  
  @override
  bool isRecord() => _delegate.isRecord();
  
  @override
  bool isSealed() => _delegate.isSealed();
  
  @override
  bool isSubclassOf(Class other) => _delegate.isSubclassOf(other);
  
  @override
  Class<K>? keyType<K>() => _delegate.keyType<K>();
  
  @override
  T newInstance([Map<String, dynamic>? arguments, String? constructorName]) => _delegate.newInstance(arguments, constructorName);
}