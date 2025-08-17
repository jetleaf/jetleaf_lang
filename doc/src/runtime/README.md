# Runtime Module

## Overview

The Runtime module provides a powerful reflection and runtime type information system for the JetLeaf framework. It enables dynamic code analysis, type resolution, and metadata access in both JIT and AOT compilation environments.

## Features

- **Unified Reflection API**: Consistent interface for reflection operations
- **AOT Support**: Works in both JIT and AOT compilation modes
- **Type Discovery**: Find and inspect types at runtime
- **Dependency Injection**: Support for runtime dependency injection
- **Code Generation**: Utilities for code generation tasks
- **Metadata Management**: Access and manipulate type metadata

## Core Components

### RuntimeProvider

The main entry point for runtime reflection operations. It provides access to:
- Libraries and packages
- Type information
- Annotations and metadata
- Runtime resolver

### RuntimeResolver

Handles dynamic instantiation and method invocation:
- Create class instances dynamically
- Invoke methods reflectively
- Access and modify fields
- Handle constructor parameters

### MetaTable

Manages type metadata and provides fast lookups for:
- Type declarations
- Method signatures
- Field information
- Annotation data

## Usage

### Basic Setup

```dart
import 'package:jetleaf_lang/runtime.dart';

void main() {
  // Initialize the runtime
  final provider = StandardRuntimeProvider();
  Runtime.setRegistry(StandardRuntimeRegistry.create(provider));
  
  // Now you can use runtime features
  final typeInfo = Runtime.getTypeInfo<MyClass>();
  print('Type: ${typeInfo.name}');
}
```

### Type Inspection

```dart
// Get type information
final typeInfo = Runtime.getTypeInfo<MyClass>();

// Get all methods
final methods = typeInfo.methods;
for (final method in methods) {
  print('Method: ${method.name}');
  print('  Return type: ${method.returnType}');
  print('  Parameters: ${method.parameters}');
}

// Get all fields
final fields = typeInfo.fields;
for (final field in fields) {
  print('Field: ${field.name} (${field.type})');
}
```

### Dynamic Instantiation

```dart
// Create instance with constructor parameters
final instance = Runtime.newInstance<MyClass>(
  'MyClass',  // Constructor name (empty string for default)
  [42, 'test'],  // Positional arguments
  {'debug': true}  // Named arguments
);

// Invoke methods dynamically
final result = Runtime.invokeMethod(
  instance,
  'calculate',
  args: [10, 20],
  namedArgs: {'multiplier': 2}
);
```

### Working with Annotations

```dart
// Check for annotations
if (typeInfo.hasAnnotation<MyAnnotation>()) {
  final annotation = typeInfo.getAnnotation<MyAnnotation>();
  print('Found annotation: $annotation');
}

// Find all types with a specific annotation
final annotatedTypes = Runtime.findTypesWithAnnotation<MyAnnotation>();
```

## Advanced Usage

### Custom Runtime Resolver

```dart
class CustomRuntimeResolver extends RuntimeResolver {
  @override
  T newInstance<T>(
    String name, [
    List<Object?> args = const [], 
    Map<String, Object?> namedArgs = const {}
  ]) {
    // Custom instantiation logic
    if (T == MyClass) {
      return MyClass(args[0] as int, args[1] as String) as T;
    }
    throw UnsupportedError('Cannot create instance of $T');
  }
  
  // Implement other required methods...
}

// Register custom resolver
Runtime.setResolver(CustomRuntimeResolver());
```

### Code Generation

```dart
// Generate code for a class
void generateClass(ClassDeclaration classDecl) {
  final buffer = StringBuffer();
  
  buffer.writeln('class ${classDecl.name} {');
  
  // Generate fields
  for (final field in classDecl.fields) {
    buffer.writeln('  ${field.type} ${field.name};');
  }
  
  // Generate constructor
  buffer.write('  ${classDecl.name}({');
  buffer.write(classDecl.fields.map((f) => 'this.${f.name}').join(', '));
  buffer.writeln('});');
  
  buffer.writeln('}');
  
  print(buffer.toString());
}
```

## Best Practices

### Performance Considerations

1. **Cache Reflection Results**
   - Store and reuse `TypeInfo` and other reflection objects
   - Avoid repeated lookups for the same type

2. **Use Compile-Time Constants**
   - Define frequently used type names as constants
   - Use `const` constructors when possible

3. **Lazy Loading**
   - Load types and metadata on demand
   - Use `isAheadOfTime` to optimize for AOT

### Error Handling

```dart
try {
  final instance = Runtime.newInstance<MyClass>('NonExistentConstructor');
} on ReflectionException catch (e) {
  print('Reflection failed: ${e.message}');
  // Handle error
}
```

## Integration with Other Modules

### Dependency Injection

```dart
class Injector {
  final Map<Type, dynamic> _instances = {};
  
  T get<T>() {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }
    
    final typeInfo = Runtime.getTypeInfo<T>();
    
    // Find injectable constructor
    final constructor = typeInfo.constructors
        .firstWhere((c) => c.hasAnnotation<Inject>());
    
    // Resolve dependencies
    final args = constructor.parameters
        .map((p) => get<dynamic>(p.type))
        .toList();
    
    // Create instance
    final instance = Runtime.newInstance<T>(
      constructor.name,
      args,
    );
    
    _instances[T] = instance;
    return instance;
  }
}
```

## Common Patterns

### Plugin System

```dart
abstract class Plugin {
  String get name;
  void initialize();
}

class PluginManager {
  final List<Plugin> _plugins = [];
  
  void loadPlugins() {
    final pluginTypes = Runtime.findSubtypesOf<Plugin>();
    
    for (final type in pluginTypes) {
      if (type.hasAnnotation<Enabled>()) {
        final plugin = Runtime.newInstance<Plugin>(type.name);
        _plugins.add(plugin);
      }
    }
  }
  
  void initializeAll() {
    for (final plugin in _plugins) {
      plugin.initialize();
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Type Not Found**
   - Ensure the type is imported
   - Check for typos in type names
   - Verify the type is not excluded from reflection

2. **AOT Limitations**
   - Some reflection features may be limited in AOT mode
   - Use code generation for AOT-optimized reflection

3. **Performance Problems**
   - Cache reflection results
   - Avoid excessive dynamic lookups
   - Use `@reflectable` selectively

## See Also

- [Dart Reflection](https://api.dart.dev/stable/dart-mirrors/dart-mirrors-library.html)
- [Java Reflection](https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/index.html)
- [Kotlin Reflection](https://kotlinlang.org/docs/reflection.html)
