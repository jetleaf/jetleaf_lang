# NetworkInputStream

## Overview

The `NetworkInputStream` class provides an implementation of `InputStream` that reads data from a Dart `Stream<List<int>>`, typically used for handling network responses such as those from `HttpClientResponse`. This class efficiently buffers incoming data chunks and provides methods for non-blocking byte-by-byte reading.

## Key Features

- **Stream Integration**: Seamlessly works with Dart's `Stream<List<int>>`
- **Efficient Buffering**: Automatically handles chunked data from network
- **Non-blocking I/O**: Asynchronous operations for responsive applications
- **Resource Management**: Proper cleanup of network resources
- **Error Handling**: Comprehensive error handling for network issues

## Constructor

### `NetworkInputStream(Stream<List<int>> sourceStream)`

Creates a new network input stream from the provided byte stream.

**Parameters**:
- `sourceStream`: The source stream of byte chunks (typically from a network response)

**Example**:
```dart
// Basic usage with HttpClient
final client = HttpClient();
try {
  final request = await client.getUrl(Uri.parse('https://example.com/data'));
  final response = await request.close();
  
  final input = NetworkInputStream(response);
  try {
    final data = await input.readAll();
    print('Received ${data.length} bytes');
  } finally {
    await input.close();
  }
} finally {
  client.close();
}
```

## Core Methods

### `read(List<int> b, [int offset = 0, int? length])`

Reads up to `length` bytes of data from the network stream into the specified buffer.

**Parameters**:
- `b`: The buffer into which the data is read
- `offset`: The start offset in array `b` at which the data is written
- `length`: The maximum number of bytes to read (defaults to remaining space in buffer)

**Returns**:
A `Future<int>` that completes with the number of bytes read, or -1 if the end of the stream has been reached.

**Example**:
```dart
final input = NetworkInputStream(networkResponse);
try {
  final buffer = Uint8List(4096);
  int bytesRead;
  
  while ((bytesRead = await input.read(buffer)) != -1) {
    // Process the received data
    processData(buffer.sublist(0, bytesRead));
  }
} finally {
  await input.close();
}
```

### `readByte()`

Reads the next byte of data from the input stream.

**Returns**:
A `Future<int>` that completes with the next byte of data, or -1 if the end of the stream is reached.

**Example**:
```dart
final input = NetworkInputStream(response);
try {
  final firstByte = await input.readByte();
  if (firstByte != -1) {
    print('First byte: 0x${firstByte.toRadixString(16).padLeft(2, '0')}');
  }
} finally {
  await input.close();
}
```

### `available()`

Returns the number of bytes that can be read without blocking.

**Returns**:
A `Future<int>` that completes with the number of bytes available in the buffer.

**Example**:
```dart
final input = NetworkInputStream(response);
try {
  final available = await input.available();
  if (available > 0) {
    final data = await input.readFully(available);
    processData(data);
  }
} finally {
  await input.close();
}
```

### `close()`

Closes the input stream and releases any system resources associated with it.

**Example**:
```dart
final input = NetworkInputStream(response);
try {
  // Process the network data
  await processNetworkData(input);
} finally {
  // Always close the stream to release resources
  await input.close();
}
```

## Advanced Usage

### Handling Large Network Responses

```dart
Future<void> downloadLargeFile(String url, String savePath) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    final input = NetworkInputStream(response);
    final file = File(savePath).openWrite();
    
    try {
      final buffer = Uint8List(64 * 1024); // 64KB buffer
      int totalRead = 0;
      int bytesRead;
      
      while ((bytesRead = await input.read(buffer)) != -1) {
        file.add(buffer.sublist(0, bytesRead));
        totalRead += bytesRead;
        print('Downloaded: ${totalRead ~/ 1024} KB');
      }
      
      await file.flush();
      print('Download complete: $totalRead bytes');
    } finally {
      await input.close();
      await file.close();
    }
  } finally {
    client.close();
  }
}
```

### Processing JSON from Network

```dart
Future<Map<String, dynamic>> fetchJson(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    if (response.statusCode != 200) {
      throw HttpException('Request failed with status: ${response.statusCode}');
    }
    
    final input = NetworkInputStream(response);
    try {
      final data = await input.readAll();
      return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
    } finally {
      await input.close();
    }
  } finally {
    client.close();
  }
}
```

## Error Handling

```dart
Future<void> safeNetworkRead(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    final input = NetworkInputStream(response);
    try {
      // Process the response
      final data = await input.readAll();
      processData(data);
    } on SocketException catch (e) {
      print('Network error: ${e.message}');
      // Handle network errors
    } on HttpException catch (e) {
      print('HTTP error: ${e.message}');
      // Handle HTTP errors
    } on IOException catch (e) {
      print('I/O error: $e');
      // Handle other I/O errors
    } finally {
      await input.close();
    }
  } on SocketException catch (e) {
    print('Connection failed: ${e.message}');
  } finally {
    client.close();
  }
}
```

## Performance Considerations

### Buffer Size

- **Small Responses (KB)**: Default buffering is usually sufficient
- **Medium Responses (MB)**: Consider larger read buffers (8KB-32KB)
- **Large Responses (GB+)**: Use even larger buffers (64KB-256KB) and process in chunks

### Connection Management

- **Connection Pooling**: Reuse HTTP clients when making multiple requests
- **Timeouts**: Always set reasonable timeouts for network operations
- **Cancellation**: Support cancellation for long-running downloads

## Best Practices

1. **Always Close Streams**: Use try/finally to ensure streams are closed
2. **Handle Errors**: Implement comprehensive error handling for network issues
3. **Use Compression**: Enable gzip/deflate compression when possible
4. **Monitor Progress**: Provide progress feedback for large downloads
5. **Respect Rate Limits**: Implement backoff for rate-limited APIs

## See Also

- [BufferedInputStream](buffered_input_stream.md): For additional buffering of network streams
- [FileInputStream](file_input_stream.md): For reading from files
- [ByteArrayInputStream](byte_array_input_stream.md): For working with in-memory byte arrays
- [HttpClient](https://api.dart.dev/stable/dart-io/HttpClient-class.html): Dart's HTTP client for making network requests
