# Flushable

## Overview

The `Flushable` interface represents an object that can flush its internal buffers to an underlying target. It's particularly useful for buffered I/O operations where data is accumulated in memory before being written to its final destination.

## Interface Definition

```dart
abstract class Flushable {
  /// Flushes this stream by writing any buffered output to the underlying
  /// stream or device.
  /// 
  /// @throws IOException if an I/O error occurs
  FutureOr<void> flush();
}
```

## Key Features

- **Buffer Management**: Ensures data is written to the target destination
- **Performance Optimization**: Reduces I/O operations by batching writes
- **Flexible Implementation**: Supports both synchronous and asynchronous operations
- **Error Handling**: Properly handles I/O errors during flush operations

## Usage Examples

### Basic Implementation

```dart
import 'dart:io';
import 'package:jetleaf_lang/jetleaf_lang.dart';

class BufferedFileWriter implements Flushable, Closeable {
  final RandomAccessFile _file;
  final List<int> _buffer = [];
  final int bufferSize;
  bool _closed = false;
  
  BufferedFileWriter(String path, {this.bufferSize = 8192}) 
      : _file = File(path).openSync(mode: FileMode.write);
  
  void write(int byte) {
    if (_closed) throw StateError('Writer is closed');
    
    _buffer.add(byte);
    if (_buffer.length >= bufferSize) {
      flush(); // Auto-flush when buffer is full
    }
  }
  
  @override
  Future<void> flush() async {
    if (_buffer.isNotEmpty) {
      await _file.writeFrom(_buffer);
      _buffer.clear();
    }
  }
  
  @override
  Future<void> close() async {
    if (!_closed) {
      await flush(); // Flush any remaining data
      await _file.close();
      _closed = true;
    }
  }
}
```

### Using with try-finally

```dart
Future<void> writeData() async {
  final writer = BufferedFileWriter('output.bin');
  try {
    for (var i = 0; i < 10000; i++) {
      writer.write(i % 256);
    }
    await writer.flush(); // Explicit flush before close
  } finally {
    await writer.close();
  }
}
```

### Using with Extension Methods

```dart
extension FlushableExtensions on Flushable {
  Future<void> writeAll(Iterable<int> bytes) async {
    // Implementation would write all bytes, possibly buffering
    // and flushing as needed
  }
}
```

## Best Practices

1. **Buffer Size**: Choose an appropriate buffer size (typically 4KB-8KB)
2. **Error Handling**: Always handle I/O errors during flush operations
3. **Resource Cleanup**: Ensure buffers are flushed before closing resources
4. **Thread Safety**: Make implementations thread-safe if accessed from multiple threads
5. **Documentation**: Clearly document buffering behavior and when flush is called automatically

## Common Patterns

### Decorator Pattern

```dart
class BufferedOutput implements Flushable {
  final Sink<List<int>> _sink;
  final List<int> _buffer = [];
  final int bufferSize;
  
  BufferedOutput(this._sink, {this.bufferSize = 8192});
  
  void add(List<int> data) {
    _buffer.addAll(data);
    if (_buffer.length >= bufferSize) {
      flush();
    }
  }
  
  @override
  Future<void> flush() async {
    if (_buffer.isNotEmpty) {
      _sink.add(List<int>.from(_buffer));
      _buffer.clear();
    }
    if (_sink is Flushable) {
      await (_sink as Flushable).flush();
    }
  }
  
  Future<void> close() async {
    await flush();
    if (_sink is Closeable) {
      await (_sink as Closeable).close();
    }
  }
}
```

### Auto-Flushing Stream Transformer

```dart
StreamTransformer<List<int>, List<int>> bufferedTransformer(int size) {
  return StreamTransformer<List<int>, List<int>>.fromHandlers(
    handleData: (data, sink) {
      // Implementation would buffer data and flush when buffer is full
    },
    handleDone: (sink) async {
      // Flush any remaining data
      await sink.flush();
      sink.close();
    },
  );
}
```

## Error Handling

When implementing `Flushable`, follow these error handling patterns:

```dart
@override
Future<void> flush() async {
  if (_buffer.isEmpty) return;
  
  try {
    await _sink.add(List<int>.from(_buffer));
    _buffer.clear();
  } on IOException catch (e, stackTrace) {
    _logger.severe('Failed to flush buffer', e, stackTrace);
    // Optionally rethrow or handle the error
    rethrow;
  } catch (e, stackTrace) {
    _logger.severe('Unexpected error during flush', e, stackTrace);
    throw StateError('Failed to flush: $e');
  }
}
```

## Thread Safety

For thread-safe implementations:

```dart
class ThreadSafeBufferedOutput implements Flushable {
  final _lock = Lock();
  final List<int> _buffer = [];
  final Sink<List<int>> _sink;
  
  ThreadSafeBufferedOutput(this._sink);
  
  Future<void> add(List<int> data) async {
    await _lock.synchronized(() {
      _buffer.addAll(data);
    });
  }
  
  @override
  Future<void> flush() async {
    List<int> toFlush;
    await _lock.synchronized(() {
      toFlush = List<int>.from(_buffer);
      _buffer.clear();
    });
    
    if (toFlush.isNotEmpty) {
      _sink.add(toFlush);
    }
  }
}
```

## Performance Considerations

- **Buffer Size**: Larger buffers reduce I/O operations but increase memory usage
- **Auto-Flushing**: Consider auto-flushing based on both size and time
- **Batch Processing**: Group related operations to minimize flush calls
- **Zero-Copy**: When possible, avoid copying data between buffers

## Testing

When testing `Flushable` implementations:

```dart
test('data is flushed when buffer is full', () async {
  final mockSink = MockSink<List<int>>();
  final writer = BufferedOutput(mockSink, bufferSize: 2);
  
  writer.write(1);
  verifyNever(mockSink.add(any));
  
  writer.write(2); // Should trigger auto-flush
  verify(mockSink.add([1, 2])).called(1);
});

test('flush writes all buffered data', () async {
  final mockSink = MockSink<List<int>>();
  final writer = BufferedOutput(mockSink);
  
  writer.write(1);
  writer.write(2);
  
  await writer.flush();
  
  verify(mockSink.add([1, 2])).called(1);
  expect(writer.bufferLength, 0);
});
```

## See Also

- [Closeable](closeable.md) - For managing resource cleanup
- [I/O Utilities](../io/README.md) - For additional I/O related utilities
- [Stream Support](../streams/README.md) - For stream-based I/O operations
