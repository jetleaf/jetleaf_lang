# Time Module

## Overview

The Time module provides a comprehensive date and time API inspired by Java's `java.time` package. It offers immutable classes for working with dates, times, and time zones in a type-safe and thread-safe manner.

## Features

- **Immutable** - All classes are immutable and thread-safe
- **Type-Safe** - Strong typing for dates, times, and date-times
- **Time Zone Support** - Full time zone handling with daylight saving time awareness
- **Fluent API** - Chainable methods for easy date/time manipulation
- **Parsing/Formatting** - Built-in support for ISO-8601 and custom formats
- **Arithmetic** - Easy date/time arithmetic operations

## Core Classes

### LocalDate
Represents a date without a time or time zone in the ISO-8601 calendar system.

### LocalTime
Represents a time without a date or time zone in the ISO-8601 calendar system.

### LocalDateTime
Represents a date and time without a time zone in the ISO-8601 calendar system.

### ZoneId
Represents a time zone identifier, used to identify the rules used to convert between an Instant and a LocalDateTime.

### ZonedDateTime
Represents a date-time with a time zone in the ISO-8601 calendar system.

## Usage Examples

### Creating Date/Time Objects

```dart
// Current date
final today = LocalDate.now();

// Specific date
final independenceDay = LocalDate.of(2023, 7, 4);

// Current time
final now = LocalTime.now();

// Specific time
final lunchTime = LocalTime.of(12, 30);

// Date and time
final newYear = LocalDateTime.of(2024, 1, 1, 0, 0);

// With time zone
final zoned = ZonedDateTime.now(ZoneId.of('America/New_York'));
```

### Date/Time Manipulation

```dart
// Add/subtract time
final tomorrow = today.plusDays(1);
final nextWeek = today.plusWeeks(1);
final oneHourLater = now.plusHours(1);

// With method chaining
final nextMonthSameDay = today
    .plusMonths(1)
    .withDayOfMonth(today.day);

// Compare dates
final isAfter = tomorrow.isAfter(today); // true
final isBefore = now.isBefore(noon);     // depends on current time
```

### Time Zones

```dart
// Get available time zones
final allZones = ZoneId.availableZoneIds;

// Convert between time zones
final newYorkTime = ZonedDateTime.now(ZoneId.of('America/New_York'));
final londonTime = newYorkTime.withZoneSameInstant(ZoneId.of('Europe/London'));

// Handle daylight saving time
final dstTransition = ZonedDateTime.of(
  LocalDateTime.of(2023, 3, 12, 1, 30),
  ZoneId.of('America/New_York')
);
// Automatically handles DST transition
```

### Formatting and Parsing

```dart
// Format dates
final formatter = DateTimeFormatter.ofPattern('yyyy-MM-dd HH:mm');
final formatted = formatter.format(newYear); // '2024-01-01 00:00'

// Parse dates
final parsed = LocalDate.parse('2023-12-31');
final customParsed = LocalDateTime.parse('2023/12/31 23:59', 'yyyy/MM/dd HH:mm');
```

## Best Practices

1. **Prefer Immutability**
   - All classes are immutable; operations return new instances
   - Store and pass around the most specific type needed

2. **Time Zone Awareness**
   - Always be explicit about time zones
   - Use `ZonedDateTime` when time zone is important
   - Use `LocalDateTime` when the context implies a local time
   - Use `Instant` for machine time or when storing timestamps

3. **Null Safety**
   - All types are non-nullable
   - Use `Optional` from the Commons module for optional date/time values

4. **Performance**
   - Reuse formatters when possible (they're thread-safe)
   - Be aware that creating many `ZonedDateTime` instances can be expensive

## Common Patterns

### Calculate Duration Between Dates

```dart
final start = LocalDate.of(2023, 1, 1);
final end = LocalDate.of(2023, 12, 31);
final daysBetween = start.until(end); // Duration in days
```

### Business Days Calculation

```dart
bool isWeekend(LocalDate date) {
  return date.dayOfWeek == DateTime.saturday || 
         date.dayOfWeek == DateTime.sunday;
}

LocalDate addBusinessDays(LocalDate date, int days) {
  LocalDate result = date;
  int added = 0;
  
  while (added < days) {
    result = result.plusDays(1);
    if (!isWeekend(result)) {
      added++;
    }
  }
  
  return result;
}
```

### Time Zone Conversion

```dart
ZonedDateTime convertToTimeZone(
  ZonedDateTime dateTime,
  String zoneId
) {
  return dateTime.withZoneSameInstant(ZoneId.of(zoneId));
}
```

## Error Handling

- `DateTimeException`: Thrown for invalid date/time values
- `ZoneRulesException`: Thrown for invalid time zone operations
- `DateTimeParseException`: Thrown when parsing fails

## Dependencies

- `intl`: For date formatting and time zone data
- `meta`: For annotations and documentation

## See Also

- [Java Time API](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/time/package-summary.html)
- [Dart DateTime](https://api.dart.dev/stable/dart-core/DateTime-class.html)
- [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
