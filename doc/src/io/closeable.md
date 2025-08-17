# Closeable

## Overview

The `Closeable` interface represents an object that holds resources until it is explicitly closed. It's specifically designed for I/O operations that might throw `IOException` during close operations.

## Interface Definition

```dart
abstract class Closeable {
  /// Closes this stream and releases any system resources associated
  /// with it. If the stream is already closed, this method has no effect.
  /// 
  /// @throws IOException if an I/O error occurs
  FutureOr<void> close();
}
```

## Key Features

- **Resource Management**: Ensures proper cleanup of I/O resources
- **Idempotent**: Safe to call multiple times
- **Exception Handling**: Specifically designed to handle I/O exceptions
- **Asynchronous Support**: Returns `FutureOr<void>` for flexible implementation

## Usage Examples

### Basic Implementation

```dart
import 'dart:io';
import 'package:jetleaf_lang/jetleaf_lang.dart';

class BufferedFileReader implements Closeable {
  final RandomAccessFile _file;
  final _buffer = <int>[];
  bool _closed = false;
  
  BufferedFileReader(String path) : _file = File(path).openSync();
  
  List<int> readBytes(int count) {
    if (_closed) throw StateError('Reader is closed');
    
    while (_buffer.length < count) {
      final chunk = _file.readSync(4096);
      if (chunk.isEmpty) break;
      _buffer.addAll(chunk);
    }
    
    final result = _buffer.take(count).toList();
    _buffer.removeRange(0, result.length);
    return result;
  }
  
  @override
  Future<void> close() async {
    if (!_closed) {
      _closed = true;
      await _file.close();
    }
  }
}
```

### Using with try-finally

```dart
Future<void> readFile(String path) async {
  final reader = BufferedFileReader(path);
  try {
    final data = reader.readBytes(1024);
    // Process data
  } finally {
    await reader.close();
  }
}
```

### Using with Extension Methods

```dart
extension CloseableExtensions on Closeable {
  Future<T> use<T>(FutureOr<T> Function() action) async {
    try {
      return await action();
    } finally {
      await close();
    }
  }
}

// Usage
Future<void> example() async {
  await BufferedFileReader('data.bin').use((reader) async {
    final data = reader.readBytes(1024);
    // Process data
  });
}
```

## Best Practices

1. **Always Close Resources**: Use try-finally or the `use` pattern
2. **Idempotent Close**: Ensure `close()` can be called multiple times safely
3. **Error Handling**: Properly handle `IOException` in close operations
4. **Documentation**: Clearly document resource ownership and cleanup responsibilities
5. **Testing**: Test close behavior, including error conditions

## Common Patterns

### Resource Acquisition Is Initialization (RAII)

```dart
Future<void> processFile() async {
  final resource = DatabaseConnection();
  try {
    await resource.connect();
    // Use resource
  } finally {
    await resource.close();
  }
}
```

### Using with Streams

```dart
class StreamResource implements Closeable {
  final StreamController<String> _controller = StreamController();
  bool _closed = false;
  
  Stream<String> get stream => _controller.stream;
  
  void add(String data) {
    if (_closed) throw StateError('Resource closed');
    _controller.add(data);
  }
  
  @override
  Future<void> close() async {
    if (!_closed) {
      _closed = true;
      await _controller.close();
    }
  }
}
```

## Error Handling

When implementing `Closeable`, follow these error handling patterns:

```dart
@override
Future<void> close() async {
  if (_closed) return;
  
  try {
    // Release resources
    await _releaseResources();
    _closed = true;
  } on IOException catch (e, stackTrace) {
    // Log I/O specific errors
    _logger.severe('I/O error while closing resource', e, stackTrace);
    rethrow;
  } catch (e, stackTrace) {
    // Log unexpected errors
    _logger.severe('Unexpected error while closing resource', e, stackTrace);
    throw StateError('Failed to close resource: $e');
  }
}
```

## Thread Safety

For thread-safe implementations:

```dart
class ThreadSafeResource implements Closeable {
  final _lock = Lock();
  bool _closed = false;
  
  @override
  Future<void> close() async {
    await _lock.synchronized(() async {
      if (!_closed) {
        _closed = true;
        // Release resources
      }
    });
  }
}
```

## Integration with Other APIs

### With Streams

```dart
Stream<List<int>> readFileInChunks(File file) {
  final resource = FileResource(file);
  final controller = StreamController<List<int>>(
    onCancel: resource.close,
  );
  
  // Start reading in chunks
  scheduleMicrotask(() async {
    try {
      final stream = file.openRead();
      await for (final chunk in stream) {
        if (controller.isClosed) break;
        controller.add(chunk);
      }
      controller.close();
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    } finally {
      await resource.close();
    }
  });
  
  return controller.stream;
}
```

## Testing

When testing `Closeable` implementations:

```dart
test('resource is properly closed', () async {
  final resource = MockCloseable();
  when(resource.close()).thenAnswer((_) async {});
  
  await resource.use(() => Future.value('test'));
  
  verify(resource.close()).called(1);
});

test('close is called on error', () async {
  final resource = MockCloseable();
  when(resource.close()).thenAnswer((_) async {});
  
  expect(
    () => resource.use(() => throw Exception('Test')),
    throwsA(isA<Exception>()),
  );
  
  verify(resource.close()).called(1);
});
```

## Performance Considerations

- **Buffering**: Use buffering for small, frequent I/O operations
- **Resource Pooling**: Consider connection pooling for expensive resources
- **Finalization**: Use `Finalizer` for additional cleanup guarantees
- **Leak Detection**: Implement leak detection in debug builds

## See Also

- [AutoCloseable](auto_closeable.md) - For general resource cleanup
- [Flushable](flushable.md) - For objects that need explicit flushing
- [I/O Utilities](../io/README.md) - For additional I/O related utilities
