# API Reference

## Table of Contents

- [Collections](#collections)
- [Optionals](#optionals)
- [I/O](#io)
- [Concurrency](#concurrency)
- [Math](#math)
- [Time](#time)
- [Networking](#networking)
- [System](#system)

## Collections

### List Extensions

| Method | Description | Example |
|--------|-------------|---------|
| `random()` | Returns a random element | `[1,2,3].random()` |
| `chunk(int size)` | Splits into chunks of given size | `[1,2,3,4].chunk(2)` |
| `count(bool test(T))` | Counts elements matching test | `[1,2,3].count((n) => n > 1)` |

### Map Extensions

| Method | Description | Example |
|--------|-------------|---------|
| `invert()` | Swaps keys and values | `{'a': 1}.invert()` |
| `filter(bool test(K, V))` | Filters entries by test | `{'a':1,'b':2}.filter((k,v) => v > 1)` |

## Optionals

### Optional<T> Class

| Method | Description |
|--------|-------------|
| `of(T value)` | Creates an Optional with value |
| `empty()` | Creates an empty Optional |
| `isPresent` | Returns true if value exists |
| `orElse(T other)` | Returns value or other if empty |
| `map<R>(R f(T))` | Maps value if present |
| `where(bool test(T))` | Filters value if present |

## I/O

### File Extensions

| Method | Description |
|--------|-------------|
| `readAsLinesStream()` | Reads file as stream of lines |
| `append(String content)` | Appends content to file |
| `copyTo(String path)` | Copies file to new location |

## Concurrency

### Lock Class

| Method | Description |
|--------|-------------|
| `synchronized(FutureOr<T> func())` | Executes function exclusively |

## Math

### Number Extensions

| Method | Description | Example |
|--------|-------------|---------|
| `isBetween(num a, num b)` | Checks if number is in range | `5.isBetween(1,10)` |
| `clamp(num min, num max)` | Clamps number to range | `15.clamp(0,10)` |

## Time

### DateTime Extensions

| Property/Method | Description |
|-----------------|-------------|
| `startOfDay` | Start of day (00:00:00) |
| `endOfDay` | End of day (23:59:59.999) |
| `isToday` | Checks if date is today |
| `addDays(int days)` | Adds days to date |

## Networking

### URI Extensions

| Method | Description |
|--------|-------------|
| `addParam(String key, String value)` | Adds query parameter |
| `removeParam(String key)` | Removes query parameter |

## System

### SystemInfo Class

| Property | Description |
|----------|-------------|
| `os` | Operating system info |
| `processors` | Number of processors |
| `memory` | System memory info |

For more detailed documentation, explore the source code or generate API docs with `dart doc`.
