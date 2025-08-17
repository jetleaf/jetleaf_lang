# Input Streams

## Overview

The Input Stream module provides a flexible and efficient system for reading data from various sources. It offers a unified interface for handling different types of input streams, including file, memory, and network-based streams.

## Core Components

- [InputStream](input_stream.md) - The base interface for all input streams
- [BufferedInputStream](buffered_input_stream.md) - Adds buffering to an existing input stream
- [ByteArrayInputStream](byte_array_input_stream.md) - Reads from a byte array in memory
- [FileInputStream](file_input_stream.md) - Reads from a file
- [NetworkInputStream](network_input_stream.md) - Reads from a network connection
- [InputStreamSource](input_stream_source.md) - A source that can provide an input stream

## Basic Usage

### Reading from a File

```dart
import 'package:jetleaf_lang/jetleaf_lang.dart';

void main() async {
  // Create a file input stream
  final file = File('example.txt');
  final stream = FileInputStream(file);
  
  try {
    // Read data in chunks
    final buffer = Uint8List(1024);
    int bytesRead;
    
    while ((bytesRead = await stream.read(buffer)) > 0) {
      // Process the read data
      processChunk(buffer.sublist(0, bytesRead));
    }
  } finally {
    // Always close the stream
    await stream.close();
  }
}
```

### Using Buffered Input

```dart
void readWithBuffer() async {
  final file = File('large_file.bin');
  final fileStream = FileInputStream(file);
  final bufferedStream = BufferedInputStream(fileStream, bufferSize: 8192);
  
  try {
    // Read data efficiently with buffering
    while (await bufferedStream.available() > 0) {
      final data = await bufferedStream.readBytes(1024);
      processData(data);
    }
  } finally {
    await bufferedStream.close();
  }
}
```

## Stream Types

### Memory-Based Streams
- **ByteArrayInputStream**: Reads from an in-memory byte array
- **BufferedInputStream**: Adds buffering to any input stream

### File-Based Streams
- **FileInputStream**: Reads from a file on the filesystem

### Network Streams
- **NetworkInputStream**: Reads from a network connection

## Common Operations

### Reading Data
- `read()`: Reads a single byte
- `readBytes()`: Reads multiple bytes into a buffer
- `skip()`: Skips a specified number of bytes
- `available()`: Returns the number of bytes available to read

### Stream Control
- `mark()`: Marks the current position
- `reset()`: Resets to the last marked position
- `close()`: Closes the stream and releases resources

## Best Practices

1. **Always Close Streams**: Use try-finally or `use` pattern
2. **Use Buffering**: For better performance with small reads
3. **Check Available Data**: Use `available()` before reading
4. **Handle Errors**: Properly handle I/O exceptions
5. **Resource Management**: Use `Closeable` for automatic resource management

## Performance Considerations

- **Buffer Size**: Choose an appropriate buffer size (typically 4KB-8KB)
- **Direct vs Buffered**: Use buffered streams for small, frequent reads
- **Memory Usage**: Be mindful of memory usage with large in-memory streams
- **Stream Chaining**: Chain streams for complex processing pipelines

## Error Handling

```dart
Future<void> readSafely() async {
  InputStream? stream;
  
  try {
    stream = FileInputStream(File('data.bin'));
    // Process stream
  } on IOException catch (e) {
    print('I/O error: $e');
  } catch (e) {
    print('Unexpected error: $e');
  } finally {
    await stream?.close();
  }
}
```

## Examples

### Copying Data Between Streams

```dart
Future<void> copy(InputStream source, OutputStream destination) async {
  try {
    final buffer = Uint8List(8192);
    int bytesRead;
    
    while ((bytesRead = await source.read(buffer)) > 0) {
      await destination.write(buffer.sublist(0, bytesRead));
    }
    
    await destination.flush();
  } finally {
    await source.close();
    await destination.close();
  }
}
```

### Reading Text Lines

```dart
Stream<String> readLines(InputStream stream) {
  final input = BufferedInputStream(stream);
  final lines = StreamController<String>();
  final decoder = utf8.decoder;
  final buffer = StringBuffer();
  
  void processChunk(List<int> chunk) {
    final text = decoder.convert(chunk);
    final lines = text.split('\n');
    
    if (lines.length == 1) {
      buffer.write(text);
      return;
    }
    
    lines[0] = '${buffer}${lines[0]}';
    buffer.clear();
    
    for (var i = 0; i < lines.length - 1; i++) {
      lines.add(lines[i]);
    }
    
    buffer.write(lines.last);
  }
  
  // Implementation would read chunks and process them
  // ...
  
  return lines.stream;
}
```

## See Also

- [Output Streams](../output_stream/README.md) - For writing data
- [I/O Utilities](../README.md) - For additional I/O related utilities
- [Stream Support](../stream_support.md) - For advanced stream operations
