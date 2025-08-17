# ByteArrayInputStream

## Overview

The `ByteArrayInputStream` class provides an implementation of `InputStream` that reads data from an in-memory byte array (`Uint8List`). It's designed for efficient, non-blocking access to in-memory binary data without the overhead of file or network I/O.

## Key Features

- **In-Memory Operation**: Works directly with `Uint8List` data
- **Zero-Copy Operations**: Efficiently accesses underlying byte data
- **Mark/Reset Support**: Allows rewinding and re-reading data
- **Thread Safety**: Safe for concurrent reads from multiple threads
- **Lightweight**: Minimal overhead compared to file/network streams

## Constructor

### `ByteArrayInputStream(Uint8List bytes, {int offset = 0, int? length})`

Creates a new byte array input stream that reads from the specified byte array.

**Parameters**:
- `bytes`: The input byte array
- `offset`: The offset in the array of the first byte to read (default: 0)
- `length`: The maximum number of bytes to read (default: to end of array)

**Example**:
```dart
// Create from a literal byte array
final bytes = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]); // "Hello"
final input = ByteArrayInputStream(bytes);

// Create with offset and length
final largeBuffer = Uint8List(1024);
// ... fill buffer with data ...
final partialInput = ByteArrayInputStream(largeBuffer, offset: 100, length: 200);
```

## Core Methods

### `read(List<int> b, [int offset = 0, int? length])`

Reads up to `length` bytes of data from the input stream into the specified buffer.

**Parameters**:
- `b`: The buffer into which the data is read
- `offset`: The start offset in array `b` at which the data is written
- `length`: The maximum number of bytes to read (defaults to remaining space in buffer)

**Returns**:
The total number of bytes read into the buffer, or -1 if the end of the stream has been reached.

**Example**:
```dart
final input = ByteArrayInputStream(Uint8List.fromList([1, 2, 3, 4, 5]));
final buffer = Uint8List(3);

// Read first 3 bytes
final bytesRead = await input.read(buffer);
// bytesRead = 3, buffer = [1, 2, 3]

// Read remaining bytes
final remaining = await input.read(buffer);
// remaining = 2, buffer = [4, 5, 3] (last byte is from previous read)
```

### `readByte()`

Reads the next byte of data from the input stream.

**Returns**:
The next byte of data, or -1 if the end of the stream is reached.

**Example**:
```dart
final input = ByteArrayInputStream(Uint8List.fromList([0x41, 0x42, 0x43]));

int byte;
while ((byte = await input.readByte()) != -1) {
  print(String.fromCharCode(byte)); // Prints: A B C
}
```

### `skip(int n)`

Skips over and discards `n` bytes of data from this input stream.

**Parameters**:
- `n`: The number of bytes to skip

**Returns**:
The actual number of bytes skipped.

**Example**:
```dart
final input = ByteArrayInputStream(Uint8List.fromList([1, 2, 3, 4, 5]));

// Skip first 2 bytes
final skipped = await input.skip(2);
// skipped = 2, next read will return 3

final nextByte = await input.readByte();
// nextByte = 3
```

### `available()`

Returns the number of remaining bytes that can be read.

**Returns**:
The number of remaining bytes.

**Example**:
```dart
final input = ByteArrayInputStream(Uint8List(100));

print(await input.available()); // 100
await input.skip(30);
print(await input.available()); // 70
```

### Mark/Reset Functionality

#### `mark(int readLimit)`

Marks the current position in this input stream.

**Parameters**:
- `readLimit`: Maximum limit of bytes that can be read before the mark becomes invalid

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
final input = ByteArrayInputStream(Uint8List.fromList([1, 2, 3, 4, 5]));

// Mark the current position
input.mark(10);

// Read some data
final firstByte = await input.readByte(); // 1
final secondByte = await input.readByte(); // 2

// Reset to marked position
await input.reset();

// Read again from the beginning
final firstByteAgain = await input.readByte(); // 1
```

## Advanced Usage

### Parsing Binary Data

```dart
class BinaryParser {
  final InputStream _input;
  
  BinaryParser(this._input);
  
  Future<int> readInt32() async {
    final bytes = await _input.readFully(4);
    return bytes.buffer.asByteData().getInt32(0, Endian.little);
  }
  
  Future<String> readString(int length) async {
    final bytes = await _input.readFully(length);
    return String.fromCharCodes(bytes);
  }
}

// Usage
final data = Uint8List.fromList([
  0x01, 0x00, 0x00, 0x00, // int32: 1
  0x41, 0x42, 0x43, 0x44  // string: "ABCD"
]);

final input = ByteArrayInputStream(data);
final parser = BinaryParser(input);

final value = await parser.readInt32(); // 1
final text = await parser.readString(4); // "ABCD"
```

### Testing with Mock Data

```dart
test('processData should handle binary input', () async {
  // Arrange
  final testData = Uint8List.fromList([0x01, 0x02, 0x03, 0x04]);
  final input = ByteArrayInputStream(testData);
  
  // Act
  final result = await processData(input);
  
  // Assert
  expect(result, equals('Processed 4 bytes'));
});
```

## Performance Considerations

### Memory Efficiency

- **Small Data**: For small amounts of data, the overhead is minimal
- **Large Data**: For large byte arrays, consider using `Uint8List.sublistView` to avoid copying data

### Buffer Management

- **Reuse Buffers**: When possible, reuse buffer arrays to reduce garbage collection
- **Direct Access**: For maximum performance, access the underlying `Uint8List` directly when possible

## Best Practices

1. **Reuse Instances**: When processing multiple byte arrays, reuse the `ByteArrayInputStream` instance
2. **Check Bounds**: Always check the return value of `read()` for end-of-stream
3. **Use Mark/Reset**: For complex parsing, use mark/reset to backtrack when needed
4. **Close Streams**: Although in-memory, always close streams when done to free resources

## See Also

- [BufferedInputStream](buffered_input_stream.md): For buffered reading from another input stream
- [FileInputStream](file_input_stream.md): For reading from files
- [NetworkInputStream](network_input_stream.md): For reading from network connections
- [Uint8List](https://api.dart.dev/stable/dart-typed_data/Uint8List-class.html): Dart's fixed-length list of 8-bit unsigned integers
