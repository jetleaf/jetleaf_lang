# FileInputStream

## Overview

The `FileInputStream` class provides a mechanism for reading raw bytes from a file in the file system. It's designed for reading binary data such as images, audio, video, or any other file format where raw byte access is required.

## Key Features

- **File Operations**: Read files from the local file system
- **Binary Data**: Optimized for reading raw binary data
- **Efficient I/O**: Supports both buffered and direct file access
- **Position Control**: Methods for navigating within the file
- **Resource Management**: Proper cleanup of file handles

## Constructor

### `FileInputStream(String path, {int bufferSize = 8192})`

Creates a new file input stream to read from the specified file.

**Parameters**:
- `path`: The path to the file to be opened for reading
- `bufferSize`: The size of the internal buffer (default: 8192 bytes)

**Throws**:
- `FileSystemException` if the file cannot be opened or read

**Example**:
```dart
// Basic usage
final input = FileInputStream('data.bin');

try {
  // Read file contents
  final data = await input.readAll();
  processData(data);
} finally {
  await input.close();
}
```

## Core Methods

### `read(List<int> b, [int offset = 0, int? length])`

Reads up to `length` bytes of data from the file into the specified buffer.

**Parameters**:
- `b`: The buffer into which the data is read
- `offset`: The start offset in array `b` at which the data is written
- `length`: The maximum number of bytes to read (defaults to remaining space in buffer)

**Returns**:
The total number of bytes read into the buffer, or -1 if the end of the file has been reached.

**Example**:
```dart
final input = FileInputStream('large_file.bin');
try {
  final buffer = Uint8List(4096);
  int bytesRead;
  
  while ((bytesRead = await input.read(buffer)) != -1) {
    // Process the chunk of data
    processChunk(buffer.sublist(0, bytesRead));
  }
} finally {
  await input.close();
}
```

### `readByte()`

Reads the next byte of data from the input stream.

**Returns**:
The next byte of data, or -1 if the end of the file is reached.

**Example**:
```dart
final input = FileInputStream('data.bin');
try {
  final firstByte = await input.readByte();
  if (firstByte != -1) {
    print('First byte: 0x${firstByte.toRadixString(16).padLeft(2, '0')}');
  }
} finally {
  await input.close();
}
```

### `skip(int n)`

Skips over and discards `n` bytes of data from the file.

**Parameters**:
- `n`: The number of bytes to skip

**Returns**:
The actual number of bytes skipped.

**Example**:
```dart
final input = FileInputStream('binary_data.bin');
try {
  // Skip the file header (first 100 bytes)
  final skipped = await input.skip(100);
  
  if (skipped == 100) {
    // Read the actual data
    final data = await input.readAll();
    processData(data);
  }
} finally {
  await input.close();
}
```

### `available()`

Returns an estimate of the number of bytes that can be read without blocking.

**Returns**:
The number of remaining bytes that can be read.

**Example**:
```dart
final input = FileInputStream('data.bin');
try {
  final remaining = await input.available();
  print('File size: $remaining bytes');
  
  // Read first half of the file
  final halfSize = remaining ~/ 2;
  final firstHalf = await input.readFully(halfSize);
  
  print('Read ${firstHalf.length} bytes');
  print('Remaining: ${await input.available()} bytes');
} finally {
  await input.close();
}
```

### `close()`

Closes the file input stream and releases any system resources associated with the stream.

**Example**:
```dart
final input = FileInputStream('data.bin');
try {
  // Process the file
  await processFile(input);
} finally {
  // Always close the stream to release resources
  await input.close();
}
```

## Advanced Usage

### Reading Structured Binary Data

```dart
class BinaryReader {
  final InputStream _input;
  
  BinaryReader(this._input);
  
  Future<int> readInt32() async {
    final bytes = await _input.readFully(4);
    return bytes.buffer.asByteData().getInt32(0, Endian.little);
  }
  
  Future<double> readDouble() async {
    final bytes = await _input.readFully(8);
    return bytes.buffer.asByteData().getFloat64(0, Endian.little);
  }
  
  // Add more methods for other data types as needed
}

// Usage
final input = FileInputStream('data.bin');
try {
  final reader = BinaryReader(input);
  final magicNumber = await reader.readInt32();
  final version = await reader.readDouble();
  
  if (magicNumber == 0x4A4C4646) { // JLFF
    print('JetLeaf File Format v$version');
  }
} finally {
  await input.close();
}
```

### Reading a File in Chunks

```dart
Future<void> processLargeFile(String filePath) async {
  final input = FileInputStream(filePath);
  try {
    const chunkSize = 64 * 1024; // 64KB chunks
    int totalRead = 0;
    
    while (true) {
      final chunk = await input.readFully(chunkSize);
      if (chunk.isEmpty) break;
      
      totalRead += chunk.length;
      processChunk(chunk);
      
      print('Processed $totalRead bytes');
    }
  } finally {
    await input.close();
  }
}
```

## Performance Considerations

### Buffer Size

- **Small Files (KB)**: Default buffer size (8KB) is usually sufficient
- **Medium Files (MB)**: Consider 16KB-64KB buffer size
- **Large Files (GB+)**: Use larger buffers (128KB-1MB) for better throughput

### File Access Patterns

- **Sequential Access**: For reading files sequentially, the default implementation is optimal
- **Random Access**: For random access patterns, consider using `RandomAccessFile` directly
- **Memory Mapping**: For very large files, memory mapping might be more efficient

## Error Handling

```dart
Future<void> safeFileRead(String filePath) async {
  final input = FileInputStream(filePath);
  try {
    // Attempt to read the file
    final data = await input.readAll();
    processData(data);
  } on FileSystemException catch (e) {
    // Handle file-related errors
    print('Failed to read file: ${e.message}');
  } on IOException catch (e) {
    // Handle I/O errors
    print('I/O error occurred: $e');
  } finally {
    // Ensure the stream is always closed
    await input.close().catchError((_) {
      // Handle any errors during close
      print('Warning: Error while closing file');
    });
  }
}
```

## Best Practices

1. **Always Close Streams**: Use try/finally to ensure streams are closed
2. **Use Buffering**: For better performance with small reads
3. **Check Return Values**: Always check the number of bytes read
4. **Handle Errors**: Implement proper error handling for file operations
5. **Resource Management**: Be mindful of system resource limits when working with many files

## See Also

- [BufferedInputStream](buffered_input_stream.md): For buffered reading from another input stream
- [NetworkInputStream](network_input_stream.md): For reading from network connections
- [ByteArrayInputStream](byte_array_input_stream.md): For reading from in-memory byte arrays
- [File](https://api.dart.dev/stable/dart-io/File-class.html): Dart's built-in File class for file operations
