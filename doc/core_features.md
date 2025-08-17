# Core Features

## Table of Contents

1. [Collections](#collections)
2. [Optionals](#optionals)
3. [I/O Operations](#io-operations)
4. [Concurrency](#concurrency)
5. [Math & Statistics](#math--statistics)
6. [Time & Date](#time--date)
7. [Networking](#networking)
8. [System Interaction](#system-interaction)

## Collections

### List Extensions

```dart
final numbers = [1, 2, 3, 4, 5];

// Get random element
final random = numbers.random();

// Split into chunks
final chunks = numbers.chunk(2);
// [[1, 2], [3, 4], [5]]
```

### Map Extensions

```dart
final map = {'a': 1, 'b': 2, 'c': 3};

// Invert keys and values
final inverted = map.invert();
// {1: 'a', 2: 'b', 3: 'c'}
```

## Optionals

```dart
final name = Optional.of('John');
final empty = Optional.empty();

// Map over optional
final upper = name.map((s) => s.toUpperCase());

// Filter
final filtered = name.where((s) => s.length > 3);
```

## I/O Operations

### File Operations

```dart
final file = File('example.txt');

// Read all lines as a stream
file.readAsLinesStream().listen(print);

// Append to file
file.append('New line\n');
```

## Concurrency

### Synchronized

```dart
final lock = Lock();

Future<void> safeIncrement() async {
  await lock.synchronized(() async {
    // Critical section
    counter++;
  });
}
```

## Math & Statistics

### Math Extensions

```dart
final num = 5;
print(num.isBetween(1, 10)); // true
print(num.clamp(1, 3)); // 3
```

## Time & Date

### DateTime Extensions

```dart
final now = DateTime.now();

print(now.startOfDay);
print(now.endOfDay);
print(now.isToday);
```

## Networking

### URI Utilities

```dart
final uri = Uri.parse('https://example.com?q=dart');
final params = uri.queryParameters;
// {'q': 'dart'}
```

## System Interaction

### Platform Info

```dart
final info = SystemInfo();
print(info.os);
print(info.processors);
print(info.memory);
```

For more detailed API documentation, see the [API Reference](api_reference.md).
