# UUID Module

## Overview

The UUID (Universally Unique Identifier) module provides a robust implementation of RFC 4122 compliant UUIDs. It supports multiple UUID versions and offers both cryptographically secure and high-performance generation options.

## Features

- **Multiple UUID Versions**: Support for versions 1, 3, 4, and 5
- **Secure by Default**: Uses cryptographically secure random number generation
- **High Performance**: Optimized for both single and bulk UUID generation
- **Flexible Parsing**: Handles both standard and compact UUID formats
- **Thread-Safe**: Safe for concurrent use across isolates

## Core Components

### Uuid Class

The main class for UUID generation and manipulation. Provides static factory methods for different UUID versions and instance methods for working with UUIDs.

### UuidRangeBuilder

Abstract base class for custom random number generation strategies. Two implementations are provided:

1. **CryptoUuidRangeBuilder**: Uses cryptographically secure random number generation (default)
2. **MathUuidRangeBuilder**: Uses faster, non-cryptographic random number generation

## Usage

### Basic UUID Generation

```dart
import 'package:jetleaf_lang/uuid.dart';

// Generate a random UUID (version 4)
final uuid1 = Uuid.randomUuid();
print(uuid1); // e.g., "550e8400-e29b-41d4-a716-446655440000"

// Parse from string
final uuid2 = Uuid.fromString('550e8400-e29b-41d4-a716-446655440000');

// Generate time-based UUID (version 1)
final uuid3 = Uuid.timeBasedUuid();
```

### Name-based UUIDs

```dart
// Generate name-based UUID (version 3 - MD5)
final namespace = Uuid.NAMESPACE_DNS; // Predefined namespace for DNS names
final name = 'example.com';
final uuid4 = Uuid.nameUuidFromBytes(namespace, name.codeUnits);

// Generate name-based UUID (version 5 - SHA-1)
final uuid5 = Uuid.nameUuidFromBytes(
  namespace,
  name.codeUnits,
  version: 5,
);
```

### Custom Random Number Generation

```dart
// Use non-cryptographic RNG for better performance
Uuid.setUuidRangeBuilder(MathUuidRangeBuilder());
final fastUuid = Uuid.randomUuid();

// Restore default cryptographically secure RNG
Uuid.setUuidRangeBuilder(CryptoUuidRangeBuilder());
```

## API Reference

### Uuid Class

#### Factory Constructors

- `Uuid.randomUuid()`: Generates a random UUID (version 4)
- `Uuid.timeBasedUuid()`: Generates a time-based UUID (version 1)
- `Uuid.nameUuidFromBytes()`: Generates a name-based UUID (version 3 or 5)
- `Uuid.fromString()`: Parses a UUID from string representation
- `Uuid.fromBytes()`: Creates a UUID from a 16-byte array

#### Instance Methods

- `toBytes()`: Converts UUID to 16-byte array
- `toCompactString()`: Returns UUID without hyphens
- `compareTo()`: Compares two UUIDs
- `toString()`: Returns standard UUID string representation

#### Properties

- `version`: UUID version (1, 3, 4, or 5)
- `variant`: UUID variant (0-3)
- `mostSignificantBits`: First 8 bytes as BigInt
- `leastSignificantBits`: Last 8 bytes as BigInt

### UuidRangeBuilder

#### Implementations

1. **CryptoUuidRangeBuilder**
   - Uses cryptographically secure random number generation
   - Slower but secure
   - Default for `Uuid.randomUuid()`

2. **MathUuidRangeBuilder**
   - Uses standard random number generation
   - Faster but not cryptographically secure
   - Suitable for testing and non-security contexts

## Performance Considerations

### UUID Generation

| Operation | Time Complexity | Notes |
|-----------|-----------------|-------|
| Random (v4) | O(1) | Very fast, uses system entropy |
| Time-based (v1) | O(1) | Slightly slower due to timestamp handling |
| Name-based (v3/v5) | O(n) | Depends on input size (hashing) |

### Memory Usage

- Each UUID instance uses exactly 16 bytes of memory
- Temporary buffers are reused when possible
- No significant memory overhead for large numbers of UUIDs

## Best Practices

1. **Security**
   - Use `CryptoUuidRangeBuilder` for security-sensitive applications
   - Never use predictable inputs for name-based UUIDs in security contexts
   - Validate and sanitize UUID inputs from untrusted sources

2. **Performance**
   - Reuse `Uuid` instances when possible
   - Use `MathUuidRangeBuilder` for bulk generation in non-security contexts
   - Cache frequently used name-based UUIDs

3. **Compatibility**
   - Always use standard string representation (lowercase) for interoperability
   - Be aware of version-specific behaviors when parsing/generating
   - Handle parsing errors gracefully

## Examples

### Bulk UUID Generation

```dart
// Generate 1000 random UUIDs efficiently
final uuids = List.generate(1000, (_) => Uuid.randomUuid());

// Sort UUIDs (lexicographical order)
uuids.sort();
```

### Custom UUID Generation

```dart
// Custom UUID range builder with fixed seed
class SeededUuidRangeBuilder extends UuidRangeBuilder {
  final Random _random;
  
  SeededUuidRangeBuilder(int seed) : _random = Random(seed);
  
  @override
  Uint8List _generate() {
    final bytes = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}

// Usage
Uuid.setUuidRangeBuilder(SeededUuidRangeBuilder(42));
final predictableUuid = Uuid.randomUuid(); // Will be the same every time
```

## Security Considerations

1. **Randomness**
   - Version 4 UUIDs rely on cryptographic randomness
   - Always use `CryptoUuidRangeBuilder` for security-sensitive applications
   - Be cautious when substituting the default RNG

2. **Uniqueness**
   - While UUIDs are designed to be unique, collisions are possible
   - Consider additional safeguards for critical systems
   - Monitor collision rates in high-volume applications

3. **Information Leakage**
   - Version 1 UUIDs leak MAC address and timestamp
   - Version 3/5 UUIDs may leak information about the input namespace/name
   - Use version 4 when privacy is a concern

## See Also

- [RFC 4122](https://tools.ietf.org/html/rfc4122): UUID URN Namespace
- [Wikipedia: UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)
