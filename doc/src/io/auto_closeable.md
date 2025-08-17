# AutoCloseable

## Overview

The `AutoCloseable` interface represents an object that holds resources (such as file or socket handles) until it is closed. It's a fundamental interface for resource management in the JetLeaf framework.

## Interface Definition

```dart
abstract class AutoCloseable {
  /// Closes this resource, releasing any system resources associated with it.
  /// 
  /// If this object is already closed, then invoking this method has no effect.
  /// 
  /// @throws Exception if this resource cannot be closed
  void close();
}
```

## Key Features

- **Resource Management**: Ensures proper cleanup of resources
- **Idempotent**: Multiple calls to `close()` are safe
- **Exception Handling**: Can throw exceptions during close operations
- **Integration**: Works seamlessly with Dart's resource management patterns

## Usage Examples

### Basic Implementation

```dart
class FileResource implements AutoCloseable {
  final File _file;
  bool _closed = false;
  
  FileResource(String path) : _file = File(path);
  
  String readContent() {
    if (_closed) throw StateError('Resource is closed');
    return _file.readAsStringSync();
  }
  
  @override
  void close() {
    if (!_closed) {
      _closed = true;
      // Perform cleanup
      print('File resource closed');
    }
  }
}
```

### Using with try-finally

```dart
void readFile() {
  final resource = FileResource('data.txt');
  try {
    final content = resource.readContent();
    print(content);
  } finally {
    resource.close();
  }
}
```

### Using with Extension Methods

```dart
extension AutoCloseableExtensions on AutoCloseable {
  T use<T>(T Function() action) {
    try {
      return action();
    } finally {
      close();
    }
  }
}

// Usage
void example() {
  FileResource('data.txt').use((resource) {
    return resource.readContent();
  });
}
```

## Best Practices

1. **Always Close Resources**: Use try-finally or the `use` pattern to ensure resources are properly closed
2. **Idempotent Close**: Make `close()` methods idempotent (safe to call multiple times)
3. **Resource Validation**: Check if the resource is closed before operations
4. **Documentation**: Clearly document any exceptions that might be thrown during close operations
5. **Testing**: Test resource cleanup in your unit tests

## Common Patterns

### Resource Acquisition Is Initialization (RAII)

```dart
void processFile() {
  final resource = FileResource('data.txt');
  try {
    // Use resource
    resource.process();
  } finally {
    resource.close();
  }
}
```

### Using with Streams

```dart
class StreamResource implements AutoCloseable, StreamSink<String> {
  final StreamController<String> _controller = StreamController();
  
  @override
  void close() {
    _controller.close();
  }
  
  // Implement other StreamSink methods...
}
```

## Error Handling

When implementing `AutoCloseable`, consider the following error handling patterns:

```dart
void close() {
  if (_closed) return;
  
  try {
    // Release resources
    _releaseResources();
    _closed = true;
  } catch (e, stackTrace) {
    // Log the error
    _logger.severe('Error closing resource', e, stackTrace);
    // Optionally rethrow or handle the error
    throw Exception('Failed to close resource: $e');
  }
}
```

## Thread Safety

If your `AutoCloseable` implementation is accessed from multiple threads, ensure proper synchronization:

```dart
class ThreadSafeResource implements AutoCloseable {
  final _lock = Lock();
  bool _closed = false;
  
  @override
  void close() {
    _lock.synchronized(() {
      if (!_closed) {
        _closed = true;
        // Release resources
      }
    });
  }
}
```

## Integration with Other APIs

### With Futures

```dart
Future<void> processWithResource() async {
  final resource = DatabaseConnection();
  try {
    await resource.connect();
    return await resource.query('SELECT * FROM data');
  } finally {
    await resource.close();
  }
}
```

### With Streams

```dart
Stream<String> readLines(File file) {
  final resource = FileResource(file);
  return resource.openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .transform(StreamTransformer.fromHandlers(
        handleDone: (sink) {
          resource.close();
          sink.close();
        },
      ));
}
```

## Testing

When testing classes that implement `AutoCloseable`:

```dart
test('resource is properly closed', () {
  final resource = MockResource();
  
  // Test that close is called
  resource.use((_) => 'test');
  
  verify(resource.close()).called(1);
});
```

## Performance Considerations

- **Lazy Initialization**: Consider lazy initialization of heavy resources
- **Pooling**: For expensive resources, implement a resource pool
- **Finalizers**: Use `Finalizer` for additional cleanup guarantees
- **Leak Detection**: Consider implementing leak detection in debug mode

## See Also

- [Closeable](closeable.md) - For I/O operations that might throw exceptions
- [Flushable](flushable.md) - For objects that need explicit flushing
- [Stream Support](../streams/README.md) - For stream-based I/O operations
