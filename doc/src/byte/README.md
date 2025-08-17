# Byte Module

## Overview

The Byte module provides comprehensive support for working with binary data, bytes, and byte arrays in Dart. It's designed to offer Java-like byte manipulation capabilities while maintaining idiomatic Dart practices.

## Features

- **Byte Class**: Wrapper for single byte values with arithmetic and bitwise operations
- **ByteArray**: Mutable sequence of bytes with Java-like API
- **ByteStream**: Efficient sequential access to byte data
- **Type Conversions**: Between signed/unsigned bytes and other numeric types
- **Hex/Binary**: Conversion to/from hexadecimal and binary representations
- **Endianness**: Support for both big and little endian operations
- **Checksums**: Common checksum algorithms
- **Base64**: Encoding and decoding of binary data

## Core Classes

### Byte
A wrapper class for byte values with methods for conversion, manipulation, and bitwise operations.

### ByteArray
A mutable sequence of bytes with Java-like methods for manipulation.

### ByteStream
Provides sequential access to binary data with methods for reading various data types.

## Usage

### Creating Bytes

```dart
// Single byte
final b1 = Byte(127);
final b2 = Byte(-128);
final b3 = Byte.parseByte('42');
final b4 = Byte.parseByte('FF', 16);

// From hex string
final hexBytes = Byte.fromHexString('48656C6C6F'); // 'Hello'

// From string
final strBytes = Byte.fromString('Hello');
```

### Working with Byte Arrays

```dart
// Create byte array
final bytes = ByteArray(4); // [0, 0, 0, 0]
bytes[0] = 0x41; // 'A'
bytes[1] = 0x42; // 'B'

// Or from existing data
final data = ByteArray.fromList([65, 66, 67]); // 'ABC'

// Convert to string
print(data.toString()); // 'ABC'

// Get hex representation
print(data.toHexString()); // '414243'
```

### Bitwise Operations

```dart
final a = Byte(0x0F); // 00001111
final b = Byte(0xF0); // 11110000

// Bitwise AND
final and = a & b; // 00000000

// Bitwise OR
final or = a | b; // 11111111

// Bitwise XOR
final xor = a ^ b; // 11111111

// Bitwise NOT
final not = ~a; // 11110000

// Shifts
final leftShift = a << 2; // 00111100
final rightShift = a >> 2; // 00000011
```

### Reading Binary Data

```dart
final stream = ByteStream(Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]));

// Read bytes
final byte1 = stream.readByte(); // 0x48
final bytes = stream.readBytes(2); // [0x65, 0x6C]

// Read multi-byte values
final int16 = stream.readInt16(); // 0x6C6C (little endian by default)
```

## API Reference

### Byte

#### Factory Constructors
- `Byte(int value)`: Creates a Byte from an integer value (-128 to 127)
- `Byte.fromInt(int value)`: Creates a Byte from an integer value
- `Byte.parse(String str, [int radix = 10])`: Parses a string to a Byte
- `Byte.fromHexString(String hex)`: Creates a Byte from a hex string
- `Byte.fromString(String str)`: Creates a Byte from the first character of a string

#### Static Methods
- `isValidByte(int value)`: Checks if a value is a valid signed byte (-128 to 127)
- `isValidUnsignedByte(int value)`: Checks if a value is a valid unsigned byte (0 to 255)
- `toSignedByte(int value)`: Converts an unsigned byte to a signed byte
- `toUnsignedByte(int value)`: Converts a signed byte to an unsigned byte
- `calculateChecksum(List<int> bytes)`: Calculates a simple checksum
- `reverseBytes(List<int> bytes)`: Reverses the order of bytes in a list

#### Instance Methods
- `toInt()`: Returns the byte value as an integer
- `toUnsigned()`: Returns the unsigned value (0 to 255)
- `toHexString()`: Returns the hex string representation
- `toBinaryString()`: Returns the binary string representation
- `toRadixString(int radix)`: Returns the string representation in the given radix

### ByteArray

#### Constructors
- `ByteArray(int size)`: Creates a ByteArray of the given size, filled with zeros
- `ByteArray.fromList(List<int> bytes)`: Creates a ByteArray from a list of bytes
- `ByteArray.fromString(String str)`: Creates a ByteArray from a string
- `ByteArray.fromHexString(String hex)`: Creates a ByteArray from a hex string

#### Properties
- `length`: The number of bytes in the array
- `isEmpty`: Whether the array is empty
- `isNotEmpty`: Whether the array is not empty

#### Methods
- `operator [](int index)`: Gets the byte at the given index
- `operator []=(int index, int value)`: Sets the byte at the given index
- `set(int index, int value)`: Sets the byte at the given index
- `get(int index)`: Gets the byte at the given index
- `setRange(int start, int end, List<int> values)`: Sets a range of bytes
- `getRange(int start, int end)`: Gets a range of bytes
- `copy()`: Creates a copy of the ByteArray
- `toList()`: Converts to a List<int>
- `toUint8List()`: Converts to a Uint8List
- `toString()`: Converts to a string using UTF-8 encoding
- `toHexString()`: Converts to a hex string

### ByteStream

#### Constructors
- `ByteStream(Uint8List bytes)`: Creates a ByteStream from a Uint8List
- `ByteStream.fromList(List<int> bytes)`: Creates a ByteStream from a list of bytes

#### Properties
- `position`: The current position in the stream
- `length`: The total length of the stream in bytes
- `remaining`: The number of remaining bytes
- `hasRemaining`: Whether there are remaining bytes

#### Methods
- `readByte()`: Reads a single byte
- `readBytes(int count)`: Reads the specified number of bytes
- `readUint8()`: Reads an unsigned 8-bit integer
- `readInt8()`: Reads a signed 8-bit integer
- `readUint16()`: Reads an unsigned 16-bit integer
- `readInt16()`: Reads a signed 16-bit integer
- `readUint32()`: Reads an unsigned 32-bit integer
- `readInt32()`: Reads a signed 32-bit integer
- `readUint64()`: Reads an unsigned 64-bit integer
- `readInt64()`: Reads a signed 64-bit integer
- `readFloat32()`: Reads a 32-bit floating point number
- `readFloat64()`: Reads a 64-bit floating point number
- `readString(int length)`: Reads a string of the specified length
- `readStringUtf8(int length)`: Reads a UTF-8 encoded string
- `skip(int count)`: Skips the specified number of bytes
- `reset()`: Resets the position to the beginning

## Best Practices

### Memory Efficiency

```dart
// Pre-allocate ByteArray when size is known
final buffer = ByteArray(1024); // Allocates exact size needed

// Use ByteArray for large binary data instead of List<int>
final imageData = ByteArray.fromList(file.readAsBytesSync());
```

### Type Safety

```dart
// Always validate byte values
int readByte() {
  final value = someInput();
  if (!Byte.isValidByte(value)) {
    throw ArgumentError('Value out of byte range: $value');
  }
  return value;
}
```

### Efficient String Handling

```dart
// For ASCII strings
final ascii = ByteArray.fromString('Hello');

// For UTF-8 strings
final utf8 = Uint8List.fromList(utf8.encode('こんにちは'));
final decoded = utf8.decode(utf8);
```

## Common Patterns

### Reading Binary Files

```dart
Future<void> readBinaryFile(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  final stream = ByteStream(bytes);
  
  // Read file header
  final magic = stream.readUint32();
  final version = stream.readUint16();
  final flags = stream.readUint16();
  
  // Process file data
  while (stream.hasRemaining) {
    final type = stream.readUint8();
    final length = stream.readUint32();
    final data = stream.readBytes(length);
    
    // Process chunk
    processChunk(type, data);
  }
}
```

### Network Protocol Implementation

```dart
class Packet {
  final int type;
  final int version;
  final Map<String, dynamic> data;
  
  Packet({required this.type, required this.version, required this.data});
  
  factory Packet.fromBytes(ByteStream stream) {
    final type = stream.readUint8();
    final version = stream.readUint8();
    final dataLength = stream.readUint16();
    final data = jsonDecode(utf8.decode(stream.readBytes(dataLength)));
    
    return Packet(
      type: type,
      version: version,
      data: Map<String, dynamic>.from(data),
    );
  }
  
  Uint8List toBytes() {
    final jsonData = utf8.encode(jsonEncode(data));
    final buffer = ByteArray(4 + jsonData.length);
    
    buffer[0] = type;
    buffer[1] = version;
    buffer.setUint16(2, jsonData.length);
    buffer.setRange(4, 4 + jsonData.length, jsonData);
    
    return buffer.toUint8List();
  }
}
```

## Performance Considerations

### Memory Usage
- `ByteArray` uses a `Uint8List` internally for efficient storage
- Creating many small `Byte` objects can increase memory pressure; prefer primitive `int` when possible
- Use `ByteArray` for large binary data instead of `List<int>`

### Processing Speed
- Batch operations are faster than individual byte operations
- Use `setRange`/`getRange` for copying multiple bytes
- Consider using `ByteStream` for sequential access patterns

## Error Handling

### Common Exceptions
- `RangeError`: When accessing out-of-bounds indices
- `ArgumentError`: For invalid arguments (e.g., invalid byte values)
- `FormatException`: When parsing invalid strings or binary data

### Defensive Programming

```dart
try {
  final byte = Byte.parseByte('256'); // Throws FormatException
} on FormatException catch (e) {
  print('Invalid byte value: $e');
}

try {
  final byte = Byte(1000); // Throws ArgumentError
} on ArgumentError catch (e) {
  print('Byte out of range: $e');
}
```

## See Also

- [Dart Typed Data](https://api.dart.dev/stable/dart-typed_data/dart-typed_data-library.html)
- [ByteBuffer in Dart](https://api.dart.dev/stable/dart-typed_data/ByteBuffer-class.html)
- [Endianness](https://en.wikipedia.org/wiki/Endianness)
- [Java Byte Class](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/lang/Byte.html)
