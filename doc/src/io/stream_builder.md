# Stream Builder

## Overview

The `StreamBuilder` class provides a mutable builder for creating `GenericStream` instances. It's designed for efficiently building streams by adding elements individually, avoiding the overhead of using a `List` as a temporary buffer.

## Features

- **Efficient Construction**: Build streams without intermediate collections
- **Fluent API**: Chain method calls for concise code
- **Type Safety**: Strongly typed stream elements
- **Immutable Result**: Produces an immutable stream
- **Lifecycle Management**: Clear transition from building to built state

## Basic Usage

### Creating and Building a Stream

```dart
import 'package:jetleaf_lang/jetleaf_lang.dart';

void main() {
  // Create a new builder
  final builder = StreamBuilder<String>();
  
  // Add elements
  builder
    ..add('Hello')
    ..add(' ')
    ..add('World!');
    
  // Build the stream
  final stream = builder.build();
  
  // Use the stream
  stream.forEach(print); // Prints: Hello World!
}
```

### Building from an Existing Collection

```dart
List<String> names = ['Alice', 'Bob', 'Charlie'];

// Using addAll()
final builder1 = StreamBuilder<String>();
builder1.addAll(names);
final stream1 = builder1.build();

// Using collection-for
final builder2 = StreamBuilder<String>();
for (final name in names) {
  builder2.add(name);
}
final stream2 = builder2.build();
```

## API Reference

### Constructors

#### `StreamBuilder<T>()`
Creates a new, empty stream builder.

**Type Parameters**:
- `T`: The type of elements in the stream

**Example**:
```dart
final builder = StreamBuilder<int>();
```

### Methods

#### `add(T element)`
Adds a single element to the stream being built.

**Parameters**:
- `element`: The element to add

**Throws**:
- `NoGuaranteeException`: If the builder has already been built

**Example**:
```dart
builder.add(42);
builder.add('value');
```

#### `addAll(Iterable<T> elements)`
Adds all elements from the given iterable to the stream being built.

**Parameters**:
- `elements`: The elements to add

**Throws**:
- `NoGuaranteeException`: If the builder has already been built

**Example**:
```dart
builder.addAll([1, 2, 3, 4, 5]);
```

#### `build()`
Builds the stream, transitioning this builder to the built state.

**Returns**:
- A `GenericStream<T>` containing the added elements

**Throws**:
- `NoGuaranteeException`: If the builder has already been built

**Example**:
```dart
final stream = builder.build();
```

## Advanced Usage

### Building Complex Streams

```dart
Stream<int> createNumberStream(int count) {
  final builder = StreamBuilder<int>();
  
  for (int i = 0; i < count; i++) {
    if (i.isEven) {
      builder.add(i * 2);
    } else {
      builder.add(-i);
    }
  }
  
  return builder.build();
}

// Usage
final stream = createNumberStream(5);
// Stream contains: [0, -1, 4, -3, 8]
```

### Combining Multiple Data Sources

```dart
Stream<String> combineSources(
  Stream<String> source1, 
  Stream<String> source2
) async* {
  final builder = StreamBuilder<String>();
  
  // Process first source
  await for (final item in source1) {
    builder.add(item.toUpperCase());
  }
  
  // Process second source
  await for (final item in source2) {
    builder.add(item.toLowerCase());
  }
  
  yield* builder.build();
}
```

## Error Handling

### Handling Builder State Errors

```dart
void addIfValid(StreamBuilder<int> builder, int? value) {
  try {
    if (value != null) {
      builder.add(value);
    }
  } on NoGuaranteeException catch (e) {
    print('Cannot add to built stream: $e');
    // Handle the error (e.g., create a new builder)
  }
}
```

### Resource Cleanup

```dart
Future<Stream<int>> processWithResource() async {
  final resource = await acquireResource();
  final builder = StreamBuilder<int>();
  
  try {
    // Process resource and add to builder
    for (var i = 0; i < 10; i++) {
      final result = await resource.process(i);
      builder.add(result);
    }
    
    return builder.build();
  } finally {
    await resource.dispose();
  }
}
```

## Performance Considerations

1. **Memory Efficiency**:
   - More efficient than collecting elements in a list first
   - Reduces memory pressure for large datasets

2. **Builder Lifecycle**:
   - Reusing builders after calling `build()` throws an exception
   - Create a new builder for each stream you need to build

3. **Batch Operations**:
   - Prefer `addAll()` for adding multiple elements
   - Reduces method call overhead

## Testing

### Unit Testing Stream Builders

```dart
void main() {
  test('StreamBuilder builds correct stream', () async {
    // Arrange
    final builder = StreamBuilder<int>();
    
    // Act
    builder
      ..add(1)
      ..add(2)
      ..add(3);
    final stream = builder.build();
    
    // Assert
    expect(await stream.toList(), [1, 2, 3]);
  });
  
  test('Cannot add to built stream', () {
    final builder = StreamBuilder<String>();
    builder.build();
    
    expect(
      () => builder.add('test'),
      throwsA(isA<NoGuaranteeException>()),
    );
  });
}
```

## Best Practices

1. **Single Use**:
   - Each `StreamBuilder` instance should be used to build exactly one stream
   - Create a new builder for each stream you need to build

2. **Error Handling**:
   - Always handle potential `NoGuaranteeException`
   - Consider wrapping builder operations in try-catch blocks

3. **Resource Management**:
   - Ensure resources are properly cleaned up
   - Use try-finally blocks when working with resources

4. **Immutability**:
   - The built stream is immutable
   - Any changes require creating a new stream

## See Also

- [Stream Support](stream_support.md) - For creating streams from various sources
- [Generic Stream](../streams/generic_stream.md) - For the type of stream produced by the builder
- [Error Handling](../exceptions.md) - For information about `NoGuaranteeException`
