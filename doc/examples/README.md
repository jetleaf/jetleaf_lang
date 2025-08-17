# Examples

This directory contains practical examples of using JetLeaf Lang in various scenarios.

## Table of Contents

1. [Optionals](#optionals)
2. [Collections](#collections)
3. [File Operations](#file-operations)
4. [Concurrency](#concurrency)
5. [Date/Time](#datetime)

## Optionals

### Basic Usage

```dart
import 'package:jetleaf_lang/jetleaf_lang.dart';

void main() {
  // Creating Optionals
  final name = Optional.of('John');
  final empty = Optional.empty();

  // Getting values
  print(name.get()); // 'John'
  print(empty.orElse('Anonymous')); // 'Anonymous'

  // Chaining operations
  final result = name
      .where((n) => n.length > 3)
      .map((n) => 'Hello, $n!')
      .orElse('Name too short');
  print(result); // 'Hello, John!'
}
```

## Collections

### List Operations

```dart
void main() {
  final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Get a random element
  print('Random number: ${numbers.random()}');

  // Split into chunks
  print('Chunks of 3: ${numbers.chunk(3)}');
  // [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]
}
```

## File Operations

### Reading and Writing Files

```dart
import 'dart:io';
import 'package:jetleaf_lang/jetleaf_lang.dart';

Future<void> main() async {
  final file = File('example.txt');
  
  // Write to file
  await file.writeAsString('Line 1\nLine 2\nLine 3');
  
  // Read all lines as a stream
  await file.readAsLinesStream().forEach(print);
  
  // Append to file
  await file.append('Line 4\n');
}
```

## Concurrency

### Using Locks

```dart
import 'package:jetleaf_lang/jetleaf_lang.dart';

final lock = Lock();
int counter = 0;

Future<void> increment() async {
  await lock.synchronized(() async {
    final current = counter;
    await Future.delayed(Duration(milliseconds: 100));
    counter = current + 1;
  });
}

Future<void> main() async {
  // Run multiple increments in parallel
  await Future.wait([
    for (var i = 0; i < 10; i++) increment(),
  ]);
  
  print('Final counter: $counter'); // Should be 10
}
```

## DateTime

### Date Manipulation

```dart
void main() {
  final now = DateTime.now();
  
  print('Start of day: ${now.startOfDay}');
  print('End of day: ${now.endOfDay}');
  print('Is today: ${now.isToday}');
  
  // Add business days (skips weekends)
  final inFiveBusinessDays = now.addBusinessDays(5);
  print('In 5 business days: $inFiveBusinessDays');
}
```

## More Examples

For more detailed examples, explore the test directory in the source code.
