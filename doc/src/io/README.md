# I/O Module

The I/O module provides a comprehensive set of utilities for handling input and output operations in a type-safe and resource-efficient manner. This module includes classes and extensions for working with streams, readers, writers, and other I/O related operations.

## Table of Contents

- [AutoCloseable](#autocloseable)
- [Closeable](#closeable)
- [Flushable](#flushable)
- [Streams](#streams)
- [Readers & Writers](#readers--writers)
- [Stream Support](#stream-support)

## AutoCloseable

The `AutoCloseable` interface represents an object that holds resources (such as file or socket handles) until it is closed. It ensures proper resource management and cleanup.

### Key Features
- Automatic resource cleanup
- Thread-safe close operations
- Integration with Dart's resource management patterns

### Example

```dart
class DatabaseConnection implements AutoCloseable {
  bool _closed = false;
  
  Future<void> query(String sql) async {
    if (_closed) throw StateError('Connection closed');
    // Execute query
  }
  
  @override
  void close() {
    if (!_closed) {
      _closed = true;
      // Release database resources
    }
  }
}

// Usage with try-finally
final connection = DatabaseConnection();
try {
  await connection.query('SELECT * FROM users');
} finally {
  connection.close();
}
```

## Closeable

`Closeable` is a specialized `AutoCloseable` that can throw an `IOException` during close operations.

### When to Use
- When dealing with I/O operations that might fail during close
- When you need to handle close-related exceptions specifically

## Flushable

`Flushable` represents an object that can flush buffered output to the underlying target.

### Example

```dart
class BufferedOutput implements Flushable {
  final StringBuffer _buffer = StringBuffer();
  
  void write(String data) => _buffer.write(data);
  
  @override
  void flush() {
    // Write buffer to actual output
    print(_buffer.toString());
    _buffer.clear();
  }
}
```

## Streams

The I/O module provides various stream-related utilities:

### Base Streams
- `BaseInputStream`/`BaseOutputStream`: Base classes for stream operations
- `BufferedStream`: Adds buffering capabilities to streams
- `CountingStream`: Tracks the number of bytes read/written

### Stream Builders

```dart
final stream = StreamBuilder<int>()
  ..add(1)
  ..add(2)
  ..add(3);

final numbers = await stream.toList(); // [1, 2, 3]
```

## Readers & Writers

### Readers
- `BufferedReader`: Efficient text reading with buffering
- `LineReader`: Reads text line by line

### Writers
- `BufferedWriter`: Efficient text writing with buffering
- `StringWriter`: Writes to an in-memory string buffer

## Stream Support

The `stream_support.dart` provides utility functions for working with streams:
- Stream transformations
- Error handling
- Backpressure management

## Best Practices

1. Always close resources in a `finally` block
2. Use `try-with-resources` pattern when possible
3. Handle I/O exceptions appropriately
4. Be mindful of resource leaks in long-running applications
