part of 'class_path_resource.dart';

/// {@template default_classpath_resource}
/// Default implementation of [ClassPathResource] that resolves and
/// provides access to classes, methods, fields, and packages from the
/// Dart runtime.
///
/// This class uses the [Runtime] utilities to inspect available
/// declarations and the package URI to scope lookups to a specific
/// package or library. It also supports reading source code as an
/// [InputStream].
///
/// ### Example
/// ```dart
/// void main() {
///   final resource = DefaultClassPathResource('package:my_app/src/user.dart');
///
///   // Get package metadata
///   final pkg = resource.getPackage();
///   print('Package name: ${pkg.name}');
///
///   // Get all classes
///   final classes = resource.getClasses();
///   for (final c in classes) {
///     print('Class: ${c.getSimpleName()}');
///   }
///
///   // Lookup a specific class
///   final userClass = resource.getClass('User');
///   print('Found class: ${userClass.getSimpleName()}');
///
///   // Access top-level methods
///   final methods = resource.getMethods();
///   for (final m in methods) {
///     print('Method: ${m.getName()}');
///   }
///
///   // Stream source file as bytes
///   final inputStream = resource.getInputStream();
///   inputStream.stream.listen((chunk) {
///     print('Read ${chunk.length} bytes');
///   });
/// }
/// ```
///
/// {@endtemplate}
final class DefaultClassPathResource extends ClassPathResource {
  List<TypeDeclaration> _declarations = [];
  List<MethodDeclaration> _methodDeclarations = [];
  LibraryDeclaration? _library;
  Stream<List<int>> _stream = Stream<List<int>>.empty();

  DefaultClassPathResource(super.packageUri) {
    _declarations.addAll(Runtime.getAllClasses().where((c) => _matches(c.getPackageUri())));
    _declarations.addAll(Runtime.getAllEnums().where((c) => _matches(c.getPackageUri())));
    _declarations.addAll(Runtime.getAllMixins().where((c) => _matches(c.getPackageUri())));
    _declarations.addAll(Runtime.getAllRecords().where((c) => _matches(c.getPackageUri())));
    _declarations.addAll(Runtime.getAllTypedefs().where((c) => _matches(c.getPackageUri())));

    final lib = Runtime.getAllLibraries().find((l) => l.getSourceLocation() != null && _matches(l.getSourceLocation()!.toString()));
    if(lib == null) {
      throw _throwIfNotFound();
    }
    
    _methodDeclarations = lib.getDeclarations().whereType<MethodDeclaration>().toList();
    _library = lib;

    _readSourceCodeAsStream(lib.getSourceLocation() ?? Uri.parse(packageUri));
  }

  bool _matches(String uri) => uri == packageUri || uri.endsWith(packageUri);

  Exception _throwIfNotFound([String? name]) => IllegalStateException("${name ?? 'Class'} for $packageUri not found");

  TypeDeclaration? _findFromLibrary([String? name]) {
    // Check for ClassDeclaration type
    TypeDeclaration? declaration = _library?.getDeclarations().whereType<ClassDeclaration>().find((d) => d.getSimpleName() == name);
    if(declaration != null) {
      return declaration;
    }
    
    // Check for EnumDeclaration type
    declaration = _library?.getDeclarations().whereType<EnumDeclaration>().find((d) => d.getSimpleName() == name);
    if(declaration != null) {
      return declaration;
    }
    
    // Check for MixinDeclaration type
    declaration = _library?.getDeclarations().whereType<MixinDeclaration>().find((d) => d.getSimpleName() == name);
    if(declaration != null) {
      return declaration;
    }
    
    // Check for RecordDeclaration type
    declaration = _library?.getDeclarations().whereType<RecordDeclaration>().find((d) => d.getSimpleName() == name);
    if(declaration != null) {
      return declaration;
    }
    
    // Check for TypedefDeclaration type
    declaration = _library?.getDeclarations().whereType<TypedefDeclaration>().find((d) => d.getSimpleName() == name);
    if(declaration != null) {
      return declaration;
    }
    
    return null;
  }

  List<TypeDeclaration> _findFromLibraryAll() {
    List<TypeDeclaration> declarations = [];

    // Check for ClassDeclaration type
    declarations.addAll(_library?.getDeclarations().whereType<ClassDeclaration>().toList() ?? []);
    // Check for EnumDeclaration type
    declarations.addAll(_library?.getDeclarations().whereType<EnumDeclaration>().toList() ?? []);
    // Check for MixinDeclaration type
    declarations.addAll(_library?.getDeclarations().whereType<MixinDeclaration>().toList() ?? []);
    // Check for RecordDeclaration type
    declarations.addAll(_library?.getDeclarations().whereType<RecordDeclaration>().toList() ?? []);
    // Check for TypedefDeclaration type
    declarations.addAll(_library?.getDeclarations().whereType<TypedefDeclaration>().toList() ?? []);
    return declarations;
  }

  void _readSourceCodeAsStream(Uri uri) async {
    try {
      final filePath = (await RuntimeUtils.resolveUri(uri) ?? uri).toFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        // Stream the file as bytes
        _stream = file.openRead();
      } else {
        _stream = Stream<List<int>>.empty();
      }
    } catch (e) {
      _stream = Stream<List<int>>.empty();
    }
  }

  @override
  Class getClass([Type? type]) {
    final className = type?.toString();
    var declaration = _declarations.find((d) => d.getSimpleName() == className);
    declaration ??= _findFromLibrary(className);
    if(declaration == null) {
      throw _throwIfNotFound(className);
    }
    
    return Class.declared(declaration, ProtectionDomain.system());
  }

  @override
  List<Class> getClasses() {
    if(_declarations.isEmpty) {
      _declarations = _findFromLibraryAll();
    }
    return _declarations.map((d) => Class.declared(d, ProtectionDomain.system())).toList();
  }

  @override
  InputStream getInputStream() => NetworkInputStream(_stream);

  @override
  Method getMethod([String? methodName]) {
    var declaration = _methodDeclarations.find((d) => d.getName() == methodName);
    if(declaration == null) {
      throw _throwIfNotFound(methodName);
    }
    
    return Method.declared(declaration, ProtectionDomain.system());
  }

  @override
  List<Method> getMethods() => _methodDeclarations.map((d) => Method.declared(d, ProtectionDomain.system())).toList();

  @override
  Package getPackage() {
    if(_library == null) {
      throw _throwIfNotFound();
    }
    
    return _library!.getPackage();
  }
}