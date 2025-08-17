# Net Module

## Overview

The Net module provides a high-level interface for working with network resources, including URL handling and network connections. It's designed to simplify common networking tasks while providing flexibility for more advanced use cases.

## Features

- **URL Parsing and Manipulation**: Easy parsing and construction of URLs
- **Unified Connection Interface**: Consistent API for different protocol handlers
- **Stream-Based I/O**: Efficient handling of network data
- **Error Handling**: Comprehensive exception hierarchy for network-related errors
- **Extensible**: Design that allows for custom protocol implementations

## Core Components

### Url

A class that represents a Uniform Resource Locator (URL) and provides methods to parse, construct, and open connections to the referenced resource.

### UrlConnection

An abstract base class for different types of network connections (HTTP, HTTPS, etc.). Provides a consistent interface for working with various protocols.

### UriExtension

An extension on Dart's `Uri` class to enable seamless conversion between `Uri` and `Url` instances.

## Usage

### Basic URL Parsing

```dart
import 'package:jetleaf_lang/net.dart';

// Parse a URL
final url = Url('https://example.com:8080/path?query=value#fragment');

// Access URL components
print('Protocol: ${url.protocol}');  // https
print('Host: ${url.host}');         // example.com
print('Port: ${url.port}');         // 8080
print('Path: ${url.path}');         // /path
print('Query: ${url.query}');       // query=value
print('Fragment: ${url.fragment}'); // fragment

// Convert back to string
print(url.toString()); // https://example.com:8080/path?query=value#fragment
```

### Working with URL Connections

```dart
import 'package:jetleaf_lang/net.dart';

// Create a URL and open a connection
final url = Url('https://example.com');
final connection = await url.openConnection();

try {
  // Connect to the resource
  await connection.connect();
  
  // Get the input stream for reading the response
  final stream = connection.getInputStream();
  
  // Read the response
  final content = StringBuffer();
  int byte;
  while ((byte = await stream.readByte()) != -1) {
    content.writeCharCode(byte);
  }
  
  print('Response: ${content.toString()}');
} catch (e) {
  print('Error: $e');
} finally {
  // Always close the connection
  await connection.close();
}
```

### Using Uri Extension

```dart
import 'dart:core';
import 'package:jetleaf_lang/net.dart';

// Convert between Uri and Url
final uri = Uri.parse('https://example.com');
final url = uri.toUrl();

// Convert back to Uri
final uriAgain = url.toUri();
```

## API Reference

### Url Class

#### Constructors

- `Url(String spec)`: Parses the given string as a URL
- `Url.https(String host, String path, [Map<String, dynamic>? queryParameters])`: Creates an HTTPS URL
- `Url.http(String host, String path, [Map<String, dynamic>? queryParameters])`: Creates an HTTP URL

#### Properties

- `protocol`: The protocol scheme (e.g., 'https')
- `host`: The host component
- `port`: The port number
- `path`: The path component
- `query`: The query string
- `fragment`: The fragment identifier
- `userInfo`: User information (e.g., 'username:password')
- `authority`: The authority component (host:port)

#### Methods

- `Future<UrlConnection> openConnection()`: Opens a connection to the URL
- `Future<InputStream> openStream()`: Opens an input stream to the URL
- `String toString()`: Returns the string representation of the URL
- `Uri toUri()`: Converts to a Dart `Uri` object

### UrlConnection Class

#### Methods

- `Future<void> connect()`: Establishes the connection
- `InputStream getInputStream()`: Gets an input stream for reading from the connection
- `Future<void> close()`: Closes the connection
- `Map<String, String> getHeaders()`: Gets the response headers
- `int getResponseCode()`: Gets the response status code
- `String getResponseMessage()`: Gets the response status message

## Best Practices

### Error Handling

1. **Connection Errors**
   - Always wrap connection code in try-catch blocks
   - Handle specific exceptions like `SocketException` and `HttpException`
   - Implement retry logic for transient failures

2. **Resource Management**
   - Always close connections in a `finally` block
   - Use `try`/`finally` to ensure resources are released
   - Consider using `try-with-resources` pattern with helper functions

### Performance

1. **Connection Pooling**
   - Reuse connections when possible
   - Implement connection pooling for high-throughput applications
   - Set appropriate timeouts

2. **Stream Processing**
   - Process data as a stream rather than loading everything into memory
   - Use buffering for small writes
   - Consider using `Stream`-based APIs for better memory efficiency

## Advanced Usage

### Custom Protocol Handlers

```dart
class CustomUrlConnection extends UrlConnection {
  final Map<String, dynamic> _customHeaders = {};
  
  CustomUrlConnection(Url url) : super(url);
  
  @override
  Future<void> connect() async {
    // Custom connection logic
    // Set up request and response objects
    _connected = true;
  }
  
  void setCustomHeader(String name, String value) {
    _customHeaders[name] = value;
  }
  
  @override
  Future<void> close() async {
    // Custom cleanup logic
    await super.close();
  }
}

// Register the custom handler
Url.registerHandler('custom', (url) => CustomUrlConnection(url));

// Use the custom protocol
final url = Url('custom://example.com/resource');
final connection = await url.openConnection() as CustomUrlConnection;
connection.setCustomHeader('X-Custom-Header', 'value');
```

### Stream Processing

```dart
Future<void> downloadFile(Url url, String savePath) async {
  final connection = await url.openConnection();
  try {
    await connection.connect();
    
    final stream = connection.getInputStream();
    final file = File(savePath).openWrite();
    
    await stream.pipe(file);
    
    await file.close();
  } finally {
    await connection.close();
  }
}
```

## Common Pitfalls

1. **Memory Leaks**
   - Always close connections and streams
   - Be cautious with large responses in memory
   - Use streaming APIs for large downloads

2. **Blocking the Main Thread**
   - Perform network operations in a separate isolate or using async/await
   - Use timeouts for all network operations
   - Handle cancellation properly

3. **Security**
   - Validate URLs before connecting
   - Be cautious with user-provided URLs
   - Use HTTPS by default
   - Validate SSL certificates in production

## See Also

- [Dart HttpClient](https://api.dart.dev/stable/dart-io/HttpClient-class.html)
- [Dart Uri class](https://api.dart.dev/stable/dart-core/Uri-class.html)
- [Java URL](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/net/URL.html)
- [Java URLConnection](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/net/URLConnection.html)
