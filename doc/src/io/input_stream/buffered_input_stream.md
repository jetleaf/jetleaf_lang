# BufferedInputStream

## Overview

The `BufferedInputStream` class adds buffering capabilities to an existing `InputStream`. It improves performance by reducing the number of I/O operations through an internal buffer. This class also supports the mark/reset functionality, allowing you to re-read portions of the stream.

## Key Features

- **Efficient I/O**: Reduces the number of actual I/O operations by buffering data
- **Mark/Reset Support**: Allows reading ahead and rewinding the stream
- **Flexible Buffer Size**: Configurable buffer size to optimize for different use cases
- **Thread Safety**: Safe for concurrent access from multiple threads

## Constructor

### `BufferedInputStream(InputStream input, {int bufferSize = 8192})`

Creates a new buffered input stream with the specified buffer size.

**Parameters**:
- `input`: The underlying input stream to buffer
- `bufferSize`: The size of the internal buffer in bytes (default: 8192)

**Example**:
```dart
// Create a buffered input stream with default buffer size
final buffered = BufferedInputStream(FileInputStream('data.bin'));

// Create a buffered input stream with custom buffer size
final customBuffered = BufferedInputStream(
  NetworkInputStream(socket),
  bufferSize: 16384, // 16KB buffer
);
```

## Core Methods

### `read(List<int> b, [int offset = 0, int? length])`

Reads up to `length` bytes of data into the specified buffer.

**Parameters**:
- `b`: The buffer into which the data is read
- `offset`: The start offset in array `b` at which the data is written
- `length`: The maximum number of bytes to read (defaults to remaining space in buffer)

**Returns**:
The total number of bytes read into the buffer, or -1 if the end of the stream has been reached.

**Example**:
```dart
final buffered = BufferedInputStream(FileInputStream('data.bin'));
try {
  final buffer = Uint8List(1024);
  final bytesRead = await buffered.read(buffer);
  
  if (bytesRead != -1) {
    processData(buffer.sublist(0, bytesRead));
  }
} finally {
  await buffered.close();
}
```

### `readByte()`

Reads the next byte of data from the input stream.

**Returns**:
The next byte of data, or -1 if the end of the stream is reached.

**Example**:
```dart
final buffered = BufferedInputStream(FileInputStream('data.bin'));
try {
  int byte;
  while ((byte = await buffered.readByte()) != -1) {
    processByte(byte);
  }
} finally {
  await buffered.close();
}
```

### `skip(int n)`

Skips over and discards `n` bytes of data.

**Parameters**:
- `n`: The number of bytes to skip

**Returns**:
The actual number of bytes skipped.

**Example**:
```dart
final buffered = BufferedInputStream(FileInputStream('data.bin'));
try {
  // Skip the first 100 bytes (e.g., header)
  final skipped = await buffered.skip(100);
  
  if (skipped == 100) {
    // Process the remaining data
    final data = await buffered.readAll();
    processData(data);
  }
} finally {
  await buffered.close();
}
```

### Mark/Reset Functionality

#### `mark(int readLimit)`

Marks the current position in this input stream. A subsequent call to the `reset` method repositions this stream at the last marked position.

**Parameters**:
- `readLimit`: The maximum limit of bytes that can be read before the mark becomes invalid

#### `reset()`

Repositions this stream to the position at the time the `mark` method was last called.

**Throws**:
- `IOException` if the stream has not been marked or if the mark has been invalidated

#### `markSupported()`

Tests if this input stream supports the `mark` and `reset` methods.

**Returns**:
`true` since this class supports mark/reset functionality

**Example**:
```dart
final buffered = BufferedInputStream(FileInputStream('data.bin'));
try {
  // Mark the current position
  buffered.mark(1024);
  
  // Read some data
  final header = await buffered.readFully(10);
  
  if (shouldRevert(header)) {
    // Go back to the marked position
    await buffered.reset();
    
    // Process the stream differently
    processAsRawData(buffered);
  } else {
    processStructuredData(buffered);
  }
} finally {
  await buffered.close();
}
```

## Performance Considerations

### Buffer Size

- **Small Buffer (1KB-4KB)**: Good for memory-constrained environments or when reading small amounts of data
- **Medium Buffer (8KB-32KB)**: Good general-purpose size for most use cases
- **Large Buffer (64KB+)**: Better for high-throughput scenarios with large files or network streams

### Best Practices

1. **Reuse Buffers**: When possible, reuse buffer arrays to reduce garbage collection
2. **Choose Appropriate Size**: Select a buffer size that matches your I/O characteristics
3. **Close Streams**: Always close streams in a finally block
4. **Batch Operations**: Read larger chunks when possible to minimize I/O operations

## Error Handling

```dart
Future<void> processWithRetry(BufferedInputStream input) async {
  try {
    // Process the stream
    await processStream(input);
  } on IOException catch (e) {
    // Handle I/O errors
    if (input.markSupported()) {
      // Reset and retry
      await input.reset();
      await processStreamWithFallback(input);
    } else {
      rethrow;
    }
  } finally {
    await input.close();
  }
}
```

## Advanced Usage

### Implementing a Peek Function

```dart
extension PeekableInputStream on BufferedInputStream {
  /// Peeks at the next byte without consuming it.
  Future<int> peek() async {
    mark(1);
    final byte = await readByte();
    await reset();
    return byte;
  }
  
  /// Peeks at the next [count] bytes without consuming them.
  Future<Uint8List> peekBytes(int count) async {
    mark(count);
    final bytes = await readFully(count);
    await reset();
    return bytes;
  }
}
```

### Reading Delimited Data

```dart
/// Reads data until the specified delimiter is encountered.
Future<Uint8List> readUntilDelimiter(
  BufferedInputStream input,
  int delimiter,
) async {
  final builder = BytesBuilder();
  
  while (true) {
    final byte = await input.readByte();
    if (byte == -1 || byte == delimiter) {
      break;
    }
    builder.addByte(byte);
  }
  
  return builder.takeBytes();
}
```

## Thread Safety

The `BufferedInputStream` class is not thread-safe by default. If you need to access a single stream from multiple threads, you should synchronize access:

```dart
class ThreadSafeBufferedInputStream {
  final BufferedInputStream _delegate;
  final _lock = Lock();
  
  ThreadSafeBufferedInputStream(InputStream input, {int bufferSize = 8192})
      : _delegate = BufferedInputStream(input, bufferSize: bufferSize);
  
  Future<int> read(List<int> b, [int offset = 0, int? length]) async {
    await _lock.synchronized(() => _delegate.read(b, offset, length));
  }
  
  // Implement other methods similarly...
  
  Future<void> close() => _lock.synchronized(_delegate.close);
}
```

## See Also

- [InputStream](input_stream.md): The base interface for all input streams
- [FileInputStream](file_input_stream.md): For reading from files
- [NetworkInputStream](network_input_stream.md): For reading from network connections
- [ByteArrayInputStream](byte_array_input_stream.md): For reading from in-memory byte arrays
