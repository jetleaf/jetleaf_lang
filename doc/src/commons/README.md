# Commons Module

## Overview

The Commons module provides a collection of essential utility classes and functions that are widely used throughout the JetLeaf framework. These utilities include optional value handling, string building, locale support, and more.

## Features

- **Optional**: Type-safe container for values that may be absent
- **StringBuilder**: Efficient string concatenation
- **Locale**: Internationalization and localization support
- **RegexUtils**: Common regular expression patterns
- **TryWith**: Resource management with automatic cleanup
- **TypeDefs**: Common type definitions
- **ThrowingSupplier**: Exception-throwing function wrapper
- **Instance**: Object instantiation utilities

## Core Components

### Optional
A container object which may or may not contain a non-null value, providing a more explicit way to handle potentially missing values.

### StringBuilder
A mutable sequence of characters designed for efficient string concatenation and manipulation.

### Locale
Represents a specific geographical, political, or cultural region, supporting internationalization (i18n) and localization (l10n).

### RegexUtils
Provides common regular expression patterns and utilities for string validation and manipulation.

### TryWith
A utility for managing resources that need to be closed after use, similar to Java's try-with-resources.

## Usage

### Optional

```dart
// Create an Optional with a value
final name = Optional.of('John');
print(name.isPresent); // true
print(name.get()); // 'John'

// Create an empty Optional
final empty = Optional.empty();
print(empty.isPresent); // false

// Safe value access
final value = name.orElse('Default');

// Conditional execution
name.ifPresent((n) => print('Hello, $n!'));
```

### StringBuilder

```dart
final sb = StringBuilder()
  ..append('Hello')
  ..append(' ')
  .append('World')
  .append('!');

print(sb.toString()); // 'Hello World!'
print(sb.length); // 12
```

### Locale

```dart
// Create locales
final enUs = Locale('en', 'US');
final frFr = Locale('fr', 'FR');

// Get language tags
print(enUs.getLanguageTag()); // 'en-US'
print(frFr.getLanguageTag()); // 'fr-FR'

// Parse from string
final locale = Locale.parse('es-ES');
```

### RegexUtils

```dart
// Email validation
final email = 'test@example.com';
if (RegexUtils.isEmail(email)) {
  print('Valid email');
}

// URL validation
final url = 'https://example.com';
if (RegexUtils.isUrl(url)) {
  print('Valid URL');
}
```

### TryWith

```dart
tryWith(
  () => File('example.txt').openRead(),
  (file) {
    // Use the file
    file.transform(utf8.decoder).listen(print);
  },
  onError: (e) => print('Error: $e'),
  onFinally: () => print('Cleanup complete'),
);
```

## API Reference

### Optional

#### Factory Constructors
- `Optional.of(T value)`: Creates an Optional with the given non-null value.
- `Optional.ofNullable(T? value)`: Creates an Optional from a potentially null value.
- `Optional.empty()`: Returns an empty Optional instance.

#### Instance Methods
- `isPresent`: Returns true if a value is present.
- `isEmpty`: Returns true if no value is present.
- `get()`: Returns the value if present, otherwise throws NoSuchElementException.
- `orElse(T other)`: Returns the value if present, otherwise returns other.
- `orElseGet(T Function() other)`: Returns the value if present, otherwise invokes other and returns its result.
- `orElseThrow(dynamic Function() exceptionSupplier)`: Returns the value if present, otherwise throws the provided exception.
- `ifPresent(void Function(T) consumer)`: If a value is present, performs the given action with the value.
- `map<R>(R Function(T) mapper)`: If a value is present, applies the mapping function to it.
- `flatMap<R>(Optional<R> Function(T) mapper)`: If a value is present, applies the mapping function to it.
- `filter(bool Function(T) predicate)`: If a value is present and matches the predicate, returns an Optional with that value.

### StringBuilder

#### Constructors
- `StringBuilder()`: Creates an empty StringBuilder.
- `StringBuilder.withContent(String initialContent)`: Creates a StringBuilder with initial content.

#### Methods
- `append(Object? obj)`: Appends the string representation of the argument.
- `appendAll(Iterable<Object?> objects, [String separator = ''])`: Appends all objects separated by the given separator.
- `insert(int index, Object? obj)`: Inserts the string representation of the argument at the specified position.
- `delete(int start, int? end)`: Removes characters between the specified indices.
- `replace(int start, int? end, String replacement)`: Replaces characters between the specified indices with the given string.
- `reverse()`: Reverses the characters in the buffer.
- `clear()`: Removes all characters from the buffer.
- `length`: Returns the length of the string.
- `isEmpty`: Returns true if the buffer is empty.
- `isNotEmpty`: Returns true if the buffer is not empty.
- `toString()`: Returns the string representation of the buffer.

### Locale

#### Constructors
- `Locale(String language, [String? country, String? variant])`: Creates a new Locale with the given language, country, and variant.
- `Locale.parse(String localeString)`: Parses a locale string in the format "language[-country][-variant]".

#### Methods
- `getLanguage()`: Returns the language code of this locale.
- `getCountry()`: Returns the country/region code of this locale, or null if none.
- `getVariant()`: Returns the variant code of this locale, or null if none.
- `getLanguageTag()`: Returns a string representation of this locale.
- `toLanguageTag()`: Returns a BCP 47 language tag representation.
- `toString()`: Returns a string representation of this locale.

## Best Practices

### Optional
- Use `Optional` instead of null to explicitly indicate that a value might be absent.
- Prefer method chaining for complex operations.
- Use `orElse` or `orElseGet` to provide default values.
- Use `ifPresent` for side effects only when a value is present.

### StringBuilder
- Use `StringBuilder` when building large strings through multiple concatenations.
- Reuse `StringBuilder` instances when possible to reduce allocations.
- Use method chaining for cleaner code.
- Consider using string interpolation for simple cases.

### Locale
- Always validate locale strings before creating Locale objects.
- Use the static `forLanguageTag` factory for parsing language tags.
- Cache Locale instances when used frequently.
- Be aware of the difference between language tags and locale strings.

## Common Patterns

### Null-Safe Value Access

```dart
class User {
  final String name;
  final String? email;
  
  User(this.name, this.email);
  
  Optional<String> getEmail() {
    return Optional.ofNullable(email);
  }
}

final user = User('John', null);
final email = user.getEmail()
    .map((e) => e.toUpperCase())
    .orElse('no-email@example.com');
```

### Efficient String Building

```dart
String buildCsv(List<Map<String, dynamic>> data) {
  if (data.isEmpty) return '';
  
  final sb = StringBuilder();
  final headers = data.first.keys;
  
  // Add headers
  sb.appendAll(headers, ',').append('\n');
  
  // Add rows
  for (final row in data) {
    sb.appendAll(
      headers.map((h) => '"${row[h]?.toString().replaceAll('"', '""') ?? ''}"'),
      ','
    ).append('\n');
  }
  
  return sb.toString();
}
```

### Locale-Aware Formatting

```dart
String formatDate(DateTime date, Locale locale) {
  final format = DateFormat.yMMMMd(locale.toLanguageTag());
  return format.format(date);
}

final date = DateTime(2023, 1, 1);
print(formatDate(date, Locale('en', 'US'))); // January 1, 2023
print(formatDate(date, Locale('de', 'DE'))); // 1. Januar 2023
```

## Error Handling

### Optional
- `NoSuchElementException`: Thrown by `get()` when no value is present.
- `NullPointerException`: Thrown by `of()` if the value is null.

### Locale
- `InvalidFormatException`: Thrown when parsing an invalid locale string.
- `IllegalArgumentException`: Thrown for invalid language, country, or variant codes.

## Performance Considerations

### Optional
- Minimal overhead compared to null checks.
- Avoid nesting Optionals as it can lead to complex and hard-to-read code.

### StringBuilder
- More efficient than string concatenation in loops.
- Pre-allocate capacity when the final size is known.

### Locale
- Parsing locale strings is relatively expensive, so cache results when possible.
- Be aware of the memory footprint of storing many Locale instances.

## See Also

- [Dart Optional](https://pub.dev/packages/optional)
- [Dart intl](https://pub.dev/packages/intl)
- [BCP 47 Language Tags](https://tools.ietf.org/html/bcp47)
- [ISO 639 Language Codes](https://www.loc.gov/standards/iso639-2/php/code_list.php)
- [ISO 3166 Country Codes](https://www.iso.org/iso-3166-country-codes.html)
