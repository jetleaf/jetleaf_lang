# Meta Module

## Overview

The Meta module provides advanced reflection, type resolution, and annotation processing capabilities for the JetLeaf framework. It enables runtime type introspection, generic type handling, and dynamic code analysis, making it a powerful tool for building frameworks and libraries that require runtime type information.

## Features

- **Runtime Type Discovery**: Find and inspect types at runtime
- **Generic Type Resolution**: Handle complex generic type hierarchies
- **Annotation Processing**: Define and process custom annotations
- **Type Safety**: Maintain type safety during reflection operations
- **AOT Support**: Designed to work with Ahead-Of-Time compilation
- **Performance Optimized**: Includes comprehensive caching for fast lookups

## Core Components

### Type Discovery

The `TypeDiscovery` class provides powerful type lookup capabilities, allowing you to find declarations by type, name, or analyzer element. It supports inheritance hierarchies and generic type patterns.

### ResolvableType

`ResolvableType` is a comprehensive type resolution system that wraps Dart's native type system, providing enhanced functionality for working with generic types, type variables, and complex type hierarchies.

### Annotations

Base annotation classes and utilities for defining and processing custom annotations, including support for generic type parameters and AOT compilation.

## Usage

### Basic Type Discovery

```dart
import 'package:jetleaf_lang/meta.dart';

// Find a type by its runtime type
final classDecl = TypeDiscovery.findByType(MyClass);

// Find a type by its name (supports both simple and qualified names)
final enumDecl = TypeDiscovery.findByName('com.example.Status');

// Find all subclasses of a base class
final repositories = TypeDiscovery.findSubclassesOf(Repository);
```

### Working with Generic Types

```dart
import 'package:jetleaf_lang/meta.dart';

// Create a ResolvableType for a generic type
final listType = ResolvableType.forClass(List<int>);
print(listType.hasGenerics()); // true
print(listType.getGeneric().resolve()?.getType()); // int

// Create complex generic types
final mapType = ResolvableType.forClassWithGenerics(
  Map, 
  [String, List<int>]
);

// Check type assignability
final objectType = ResolvableType.forClass(Object);
print(objectType.isAssignableFrom(String)); // true
```

### Defining and Processing Annotations

```dart
import 'package:jetleaf_lang/meta.dart';

// Define a custom annotation
class MyAnnotation extends ReflectableAnnotation {
  final String name;
  final int priority;
  
  const MyAnnotation(this.name, {this.priority = 0});
  
  @override
  Type get annotationType => MyAnnotation;
  
  @override
  bool operator ==(Object other) => 
      identical(this, other) || 
      other is MyAnnotation && 
      name == other.name && 
      priority == other.priority;
      
  @override
  int get hashCode => name.hashCode ^ priority.hashCode;
}

// Use the annotation
@MyAnnotation('example', priority: 1)
class MyClass {
  // ...
}

// Process annotations at runtime
final classInfo = TypeDiscovery.findByType(MyClass);
final annotations = classInfo.getAnnotations();
final myAnnotation = annotations.firstWhere(
  (a) => a is MyAnnotation,
  orElse: () => null,
) as MyAnnotation?;
```

## API Reference

### TypeDiscovery

#### Static Methods

- `findByType(Type type)`: Finds a type declaration by its runtime type
- `findByName(String name)`: Finds a type declaration by its name
- `findByElement(Element element)`: Finds a type declaration by its analyzer element
- `findSubclassesOf(Type superType)`: Finds all direct subclasses of a type
- `findImplementationsOf(Type interface)`: Finds all implementations of an interface
- `findAnnotatedWith(Type annotationType)`: Finds all types annotated with a specific annotation

### ResolvableType

#### Factory Constructors

- `forClass(Type type)`: Creates a ResolvableType for a non-generic type
- `forClassWithGenerics(Type rawType, List<Type> typeArguments)`: Creates a ResolvableType for a generic type
- `forInstance(Object instance)`: Creates a ResolvableType from an instance
- `forTypeVariable(TypeVariable variable)`: Creates a ResolvableType for a type variable

#### Instance Methods

- `resolve()`: Resolves the type to its declaration
- `isAssignableFrom(Type type)`: Checks if a type is assignable to this type
- `isAssignableFromType(ResolvableType type)`: Type-safe version of isAssignableFrom
- `isGeneric()`: Checks if the type is generic
- `getGenericArguments()`: Gets the generic type arguments
- `isArray()`: Checks if the type is an array
- `getComponentType()`: Gets the component type of an array
- `isPrimitive()`: Checks if the type is a primitive type
- `isInterface()`: Checks if the type is an interface
- `isFinal()`: Checks if the type is final
- `isAbstract()`: Checks if the type is abstract

### Annotations

#### ReflectableAnnotation

Base class for all reflectable annotations. Provides basic equality and hashing.

#### @Generic

Annotation for marking generic classes for type reflection.

#### @Resolved

Annotation for marking classes that should have AOT-compatible runtime resolvers generated.

## Best Practices

### Performance Considerations

1. **Caching**
   - Reuse `ResolvableType` instances when possible
   - Cache the results of expensive type lookups
   - Use `TypeDiscovery` methods that return cached results

2. **Lazy Loading**
   - Load types on demand
   - Use `TypeDiscovery` methods that support lazy loading
   - Avoid scanning the entire classpath unnecessarily

### Type Safety

1. **Null Safety**
   - Always handle null cases when working with type resolution
   - Use null-aware operators and null checks
   - Provide sensible defaults for optional type parameters

2. **Type Checking**
   - Use `isAssignableFrom` for type compatibility checks
   - Prefer `resolveGeneric()` over raw type access
   - Validate type arguments before using them

### Error Handling

1. **Graceful Degradation**
   - Handle `TypeNotPresentException` and similar errors
   - Provide meaningful error messages
   - Fall back to default behavior when reflection fails

2. **Validation**
   - Validate type parameters before using them
   - Check for null values
   - Verify type constraints and bounds

## Advanced Usage

### Custom Type Handlers

```dart
class CustomTypeHandler implements TypeHandler {
  @override
  bool canHandle(Type type) {
    return type == MyCustomType;
  }
  
  @override
  dynamic convert(Object value, Type targetType) {
    // Custom conversion logic
    return MyCustomType.from(value);
  }
}

// Register the handler
TypeDiscovery.registerTypeHandler(CustomTypeHandler());
```

### Dynamic Proxy Generation

```dart
class DynamicProxy implements InvocationHandler {
  final Object target;
  
  DynamicProxy(this.target);
  
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Intercept method calls
    print('Method called: ${invocation.memberName}');
    
    // Forward the call to the target
    return invocation.invokeOn(target);
  }
}

// Create a proxy instance
final proxy = Proxy.newProxyInstance(
  MyInterface,
  DynamicProxy(MyImplementation()),
) as MyInterface;
```

## Common Pitfalls

1. **Type Erasure**
   - Generic type information is erased at runtime in Dart
   - Use `@Generic` annotation to preserve type information
   - Be aware of limitations with complex generic types

2. **AOT Compilation**
   - Reflection has limitations in AOT-compiled code
   - Use `@Resolved` annotation for AOT support
   - Test thoroughly in AOT mode

3. **Performance**
   - Reflection operations can be expensive
   - Cache results when possible
   - Avoid reflection in performance-critical paths

## See Also

- [Dart Reflection](https://api.dart.dev/stable/dart-mirrors/dart-mirrors-library.html)
- [Java Reflection](https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/index.html)
- [Kotlin Reflection](https://kotlinlang.org/docs/reflection.html)
