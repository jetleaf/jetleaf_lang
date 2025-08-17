# Getting Started with JetLeaf Lang

This guide will help you quickly integrate JetLeaf Lang into your Dart project.

## Prerequisites

- Dart SDK: >=3.0.0 <4.0.0
- Flutter (if using with Flutter)

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  jetleaf_lang: ^1.0.0
```

Then run:
```bash
dart pub get
```

## Basic Usage

### Import the Package

```dart
import 'package:jetleaf_lang/jetleaf_lang.dart';
```

### Key Features

#### Optionals

```dart
final name = Optional.of('John');
print(name.orElse('Anonymous')); // John

final empty = Optional.empty();
print(empty.orElse('Anonymous')); // Anonymous
```

#### String Utilities

```dart
final str = 'hello world';
print(str.capitalize()); // 'Hello world'
print(str.isBlank); // false
print(''.isBlank); // true
```

#### Collections

```dcript
final list = [1, 2, 3, 4, 5];
final evenNumbers = list.where((n) => n.isEven);
print(evenNumbers.join(', ')); // 2, 4
```

## Next Steps

- Explore [Core Features](core_features.md) for detailed documentation
- Check out [Examples](examples/) for more usage patterns
- See the [API Reference](api_reference.md) for complete documentation
