# InputStream

## Overview

The `InputStream` abstract class serves as the foundation for all input streams in the JetLeaf framework. It provides a unified interface for reading raw bytes from various sources, including files, memory buffers, and network connections.

## Key Features

- **Unified Interface**: Consistent API for reading from different data sources
- **Flexible Reading**: Support for reading bytes, byte arrays, and full streams
- **Stream Control**: Methods for marking, skipping, and checking available data
- **Resource Management**: Proper cleanup through the `Closeable` interface
- **Thread Safety**: Designed with thread safety in mind for concurrent access

## Core Methods

### Reading Data

#### `readByte()`
Reads the next byte of data from the input stream.

```dart
/**
 * Reads the next byte of data from the input stream.
 * 
 * @return The next byte of data, or -1 if the end of the stream is reached.
 * @throws IOException If an I/O error occurs
 * @throws StreamClosedException If the stream has been closed
 */
Future<int> readByte() async {
  checkClosed();
  final buffer = Uint8List(1);
  final bytesRead = await read(buffer);
  return bytesRead == -1 ? -1 : buffer[0] & 0xFF;
}
```

#### `read(List<int> b, [int offset = 0, int? length])`
Reads up to `length` bytes of data into the specified buffer.

```dart
/**
 * Reads up to [length] bytes of data from the input stream into an array of bytes.
 * 
 * @param b The buffer into which the data is read
 * @param offset The start offset in array [b] at which the data is written
 * @param length The maximum number of bytes to read
 * @return The total number of bytes read into the buffer, or -1 if there is no
 *         more data because the end of the stream has been reached
 * @throws InvalidArgumentException If [offset] or [length] is negative, or if
 *         [offset] + [length] is greater than the length of [b]
 * @throws IOException If an I/O error occurs
 * @throws StreamClosedException If the stream has been closed
 */
Future<int> read(List<int> b, [int offset = 0, int? length]);
```

### Bulk Operations

#### `readFully(int length)`
Reads exactly `length` bytes from the input stream.

```dart
/**
 * Reads exactly [length] bytes from the input stream.
 * 
 * @param length The exact number of bytes to read
 * @return A Uint8List containing exactly [length] bytes
 * @throws EndOfStreamException If the end of stream is reached before [length] bytes are read
 * @throws IOException If an I/O error occurs
 * @throws StreamClosedException If the stream has been closed
 */
Future<Uint8List> readFully(int length) async {
  final buffer = Uint8List(length);
  int totalRead = 0;
  
  while (totalRead < length) {
    final bytesRead = await read(buffer, totalRead, length - totalRead);
    if (bytesRead == -1) {
      throw EndOfStreamException('Reached end of stream after reading $totalRead of $length bytes');
    }
    totalRead += bytesRead;
  }
  
  return buffer;
}
```

#### `readAll()`
Reads all remaining bytes from the input stream.

```dart
/**
 * Reads all remaining bytes from the input stream.
 * 
 * @return A Uint8List containing all remaining bytes in the stream
 * @throws IOException If an I/O error occurs
 * @throws StreamClosedException If the stream has been closed
 */
Future<Uint8List> readAll() async {
  final chunks = <Uint8List>[];
  final buffer = Uint8List(8192);
  int totalRead = 0;
  
  while (true) {
    final bytesRead = await read(buffer);
    if (bytesRead == -1) break;
    
    chunks.add(Uint8List.sublistView(buffer, 0, bytesRead));
    totalRead += bytesRead;
  }
  
  final result = Uint8List(totalRead);
  int offset = 0;
  
  for (final chunk in chunks) {
    result.setRange(offset, offset + chunk.length, chunk);
    offset += chunk.length;
  }
  
  return result;
}
```

### Stream Navigation

#### `skip(int n)`
Skips over and discards `n` bytes of data.

```dart
/**
 * Skips over and discards [n] bytes of data from this input stream.
 * 
 * @param n The number of bytes to skip
 * @return The actual number of bytes skipped
 * @throws IOException If an I/O error occurs
 * @throws StreamClosedException If the stream has been closed
 */
Future<int> skip(int n) async {
  if (n <= 0) return 0;
  
  final buffer = Uint8List(min(n, 8192));
  int remaining = n;
  
  while (remaining > 0) {
    final bytesRead = await read(buffer, 0, min(remaining, buffer.length));
    if (bytesRead == -1) break;
    remaining -= bytesRead;
  }
  
  return n - remaining;
}
```

#### `available()`
Returns an estimate of the number of bytes that can be read without blocking.

```dart
/**
 * Returns an estimate of the number of bytes that can be read without blocking.
 * 
 * @return An estimate of the number of bytes that can be read, or 0 if at end of stream
 * @throws IOException If an I/O error occurs
 * @throws StreamClosedException If the stream has been closed
 */
Future<int> available() async {
  return 0; // Default implementation for streams with unknown length
}
```

### Mark/Reset Support

#### `markSupported()`
Tests if this input stream supports mark/reset functionality.

```dart
/**
 * Tests if this input stream supports the mark/reset methods.
 * 
 * @return true if this stream instance supports the mark and reset methods
 */
bool markSupported() => false; // Default implementation
```

#### `mark(int readLimit)`
Marks the current position in this input stream.

```dart
/**
 * Marks the current position in this input stream.
 * 
 * @param readLimit The maximum limit of bytes that can be read before the mark becomes invalid
 * @throws IOException If the stream does not support mark
 */
void mark(int readLimit) {
  if (!markSupported()) {
    throw IOException('Mark not supported');
  }
  // Implementation in subclasses
}
```

#### `reset()`
Repositions this stream to the position at the time the `mark` method was called.

```dart
/**
 * Repositions this stream to the position at the time the mark method was called.
 * 
 * @throws IOException If the stream has not been marked or if the mark has been invalidated
 */
Future<void> reset() async {
  if (!markSupported()) {
    throw IOException('Mark/reset not supported');
  }
  // Implementation in subclasses
}
```

## Implementation Guidelines

When implementing a custom `InputStream`, follow these guidelines:

1. **Extend InputStream**: All input stream implementations should extend the `InputStream` class.

2. **Implement Core Methods**: At minimum, implement the `read()` method. Other methods have default implementations but can be overridden for better performance.

3. **Handle Resource Management**: Implement `close()` to release any system resources.

4. **Thread Safety**: Ensure thread safety if the stream will be accessed from multiple threads.

5. **Document Behavior**: Clearly document any special behavior or limitations of your implementation.

## Example Implementation

Here's a simplified example of a custom input stream that generates random data:

```dart
import 'dart:math';
import 'package:jetleaf_lang/jetleaf_lang.dart';

class RandomInputStream extends InputStream {
  final Random _random = Random();
  final int _size;
  int _position = 0;
  bool _closed = false;

  RandomInputStream(this._size);

  @override
  Future<int> read(List<int> b, [int offset = 0, int? length]) async {
    checkClosed();
    
    if (_position >= _size) return -1;
    
    final actualLength = min(length ?? b.length, _size - _position);
    for (var i = 0; i < actualLength; i++) {
      b[offset + i] = _random.nextInt(256);
    }
    
    _position += actualLength;
    return actualLength;
  }

  @override
  Future<int> available() async => _size - _position;

  @override
  Future<void> close() async {
    _closed = true;
  }

  @override
  void checkClosed() {
    if (_closed) {
      throw StreamClosedException('Stream has been closed');
    }
  }
}
```

## Best Practices

1. **Always Check Closed State**: Call `checkClosed()` at the start of methods that require the stream to be open.

2. **Handle Partial Reads**: The `read()` method may read fewer bytes than requested. Always check the return value.

3. **Use Buffering**: For better performance, wrap unbuffered streams with `BufferedInputStream`.

4. **Release Resources**: Always close streams when done to release system resources.

5. **Document Thread Safety**: Clearly document whether your implementation is thread-safe.

## Performance Considerations

1. **Buffer Size**: When reading large amounts of data, use an appropriate buffer size (typically 4KB-8KB).

2. **Avoid Single-Byte Reads**: Prefer reading chunks of data rather than single bytes when possible.

3. **Mark/Reset Overhead**: Be aware that supporting mark/reset may require additional memory.

4. **Native Implementations**: For file and network I/O, consider using platform-specific implementations for better performance.

## Error Handling

Handle these common error cases:

1. **End of Stream**: Check for `-1` return value from `read()`.
2. **Closed Stream**: Throw `StreamClosedException` if operations are attempted on a closed stream.
3. **Invalid Arguments**: Validate method parameters and throw `InvalidArgumentException` if invalid.
4. **I/O Errors**: Wrap platform-specific I/O errors in `IOException`.

## See Also

- [BufferedInputStream](buffered_input_stream.md): For buffered reading from another input stream
- [FileInputStream](file_input_stream.md): For reading from files
- [NetworkInputStream](network_input_stream.md): For reading from network connections
- [ByteArrayInputStream](byte_array_input_stream.md): For reading from in-memory byte arrays
