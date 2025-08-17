# System Module

## Overview

The System module provides a comprehensive interface for interacting with the underlying system environment and runtime information in a cross-platform manner. It serves as a bridge between your Dart application and the host system, offering utilities similar to Java's `System` class while providing additional Dart-specific functionality.

## Features

- **Runtime Information**: Access compilation mode, entry points, and launch configuration
- **Environment Variables**: Read and manage environment variables
- **System Properties**: Access system properties in a platform-agnostic way
- **Standard I/O**: Simplified console output with `System.out` and `System.err` style methods
- **Diagnostics**: Gather detailed system information for debugging and telemetry

## Core Components

### System Context

The main entry point that provides access to:
- System properties
- Environment variables
- Standard I/O streams
- Runtime information

### SystemInfo

An immutable snapshot of the runtime system state, including:
- Compilation mode (JIT/AOT)
- Entry point information
- Dependency and configuration counts
- Launch command and environment details

### AbstractSystemInterface

An abstract interface that defines the contract for system implementations, allowing for different implementations based on the runtime environment.

## Usage

### Accessing System Properties

```dart
import 'package:jetleaf_lang/system.dart';

// Get all system properties
final properties = System.getProperties();
print('Dart version: ${properties['dart.version']}');
print('OS: ${properties['os.name']} ${properties['os.version']}');

// Get a specific property
final homeDir = System.getProperty('user.home');
print('Home directory: $homeDir');
```

### Working with Environment Variables

```dart
import 'package:jetleaf_lang/system.dart';

// Get all environment variables
final env = System.getEnv();
print('PATH: ${env['PATH']}');

// Get a specific environment variable
final home = System.getEnvVar('HOME');
print('Home: $home');
```

### Console Output

```dart
import 'dart:io';
import 'package:jetleaf_lang/system.dart';

// Standard output
System.out.println('Hello, World!');
System.out.print('No newline');
System.out.printf('Formatted: %s, %d, %.2f', ['text', 42, 3.14159]);

// Error output
System.err.println('Error message');

// Using the extension directly on stdout/stderr
stdout.println('This works too!');
stderr.println('Error message');
```

### Getting System Information

```dart
import 'package:jetleaf_lang/system.dart';

// Get system information
final info = System.toSystemInfo();
print('''
System Information:
  Mode: ${info.mode}
  Entrypoint: ${info.entrypoint}
  Launch Command: ${info.launchCommand}
  Dependencies: ${info.dependencies}
  Configurations: ${info.configurations}
  Running from .dill: ${info.isDill}
  IDE Run: ${info.ideRun}
  Watch Mode: ${info.watch}
''');
```

## API Reference

### System Context (Static Methods)

#### Properties
- `mode`: Current compilation mode (`CompiledDesign` enum)
- `isRunningFromDill`: Whether running from a .dill file
- `isRunningWithAot`: Whether running with AOT compilation
- `entrypoint`: Path to the entrypoint file
- `launchCommand`: Full launch command
- `ideRun`: Whether running from an IDE
- `dependencyCount`: Number of dependencies
- `configurationCount`: Number of configurations
- `watch`: Whether in watch mode

#### Methods
- `Map<String, String> getProperties()`: Returns all system properties
- `String? getProperty(String name)`: Gets a specific system property
- `Map<String, String> getEnv()`: Returns all environment variables
- `String? getEnvVar(String name)`: Gets a specific environment variable
- `SystemInfo toSystemInfo()`: Returns a snapshot of system information

### SystemInfo Class

#### Properties
- `mode`: Compilation mode (`CompiledDesign` enum)
- `isDill`: Whether running from a .dill file
- `entrypoint`: Path to the entrypoint file
- `launchCommand`: Full launch command
- `ideRun`: Whether running from an IDE
- `dependencies`: Number of dependencies
- `configurations`: Number of configurations
- `watch`: Whether in watch mode

#### Methods
- `Map<String, dynamic> toJson()`: Converts to a JSON-serializable map
- `String toString()`: String representation of system info

### Standard I/O Extensions

#### Methods on `Stdout`/`Stderr`
- `print(String message)`: Prints without newline
- `println([Object? message = ''])`: Prints with newline
- `printf(String format, List<Object?> args)`: Formatted printing
- `printErr(Object? message)`: Prints to stderr with newline

## Best Practices

### Security Considerations

1. **Sensitive Information**
   - Be cautious when logging or transmitting system properties and environment variables
   - Filter out sensitive information before logging
   - Use `getProperty`/`getEnvVar` instead of accessing the full map when possible

2. **Environment Variables**
   - Prefer configuration files over environment variables for sensitive data
   - Validate environment variables before use
   - Provide sensible defaults for all environment variables

### Performance

1. **Caching**
   - Cache system properties and environment variables if accessed frequently
   - Consider using `SystemInfo` for a snapshot of system state

2. **Lazy Loading**
   - The System module is designed to be lightweight
   - Properties are computed on-demand
   - No need to implement additional lazy loading

### Cross-Platform Development

1. **Platform-Specific Code**
   - Use platform checks for OS-specific logic
   - Test on all target platforms
   - Be aware of differences in environment variables between operating systems

2. **Error Handling**
   - Always handle cases where properties or environment variables might be null
   - Provide fallback values where appropriate

## Advanced Usage

### Custom System Implementation

```dart
class CustomSystem implements AbstractSystemInterface {
  @override
  CompiledDesign get mode => CompiledDesign.release;

  @override
  bool get isRunningFromDill => true;

  @override
  bool get isRunningWithAot => true;

  @override
  String get entrypoint => 'custom_entrypoint.dart';
  
  // Implement other required methods...
}

// Set custom system implementation
System.system = CustomSystem();
```

### Monitoring System Changes

```dart
import 'dart:async';
import 'package:jetleaf_lang/system.dart';

class SystemMonitor {
  final _controller = StreamController<SystemInfo>.broadcast();
  
  Stream<SystemInfo> get onSystemInfoChanged => _controller.stream;
  
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    Timer.periodic(interval, (timer) {
      _controller.add(System.toSystemInfo());
    });
  }
  
  void dispose() {
    _controller.close();
  }
}

// Usage
final monitor = SystemMonitor();
monitor.onSystemInfoChanged.listen((info) {
  print('System info updated: $info');  
});
monitor.startMonitoring();
```

## Common Pitfalls

1. **Platform Differences**
   - Property names and environment variables vary between operating systems
   - Always test on all target platforms
   - Use platform checks when necessary

2. **Performance Impact**
   - Accessing system properties can be expensive
   - Cache values that don't change during runtime
   - Avoid frequent polling of system information

3. **Security**
   - Be cautious with sensitive information in system properties
   - Validate all inputs from system properties and environment variables
   - Don't log sensitive information

## See Also

- [Dart Platform class](https://api.dart.dev/stable/dart-io/Platform-class.html)
- [Dart Environment Variables](https://dart.dev/tools/environment-variables)
- [Java System Class](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/lang/System.html)
