# Mock Module

## Overview

The Mock module provides testing utilities for the JetLeaf framework, enabling efficient testing of reflection-dependent code without requiring a full runtime scan. It's particularly useful for unit testing and development scenarios where lightweight reflection is needed.

## Features

- **Lightweight Reflection**: Uses Dart's mirrors API for runtime type inspection
- **Selective Loading**: Load only specific libraries or classes for testing
- **Configurable Logging**: Built-in support for info, warning, and error logging
- **Isolation**: Operates within the current Dart isolate by default
- **Extensible**: Supports custom library generators and runtime configurations
- **No Filesystem Dependencies**: Works entirely in-memory

## Core Components

### MockRuntimeScanner
A lightweight implementation of `RuntimeScanner` that provides reflection capabilities without filesystem operations.

### MockLibraryGenerator
Generates reflection metadata using Dart's mirrors API, designed for testing scenarios.

### InternalMockLibraryGenerator
An internal class used for framework testing, not intended for direct use by applications.

## Usage

### Basic Setup

```dart
import 'package:jetleaf_lang/mock.dart';
import 'package:test/test.dart';

void main() {
  late MockRuntimeScanner mockScanner;
  
  setUp(() {
    mockScanner = MockRuntimeScanner(
      onInfo: (msg) => print('INFO: $msg'),
      onError: (err) => print('ERROR: $err'),
      forceLoadFiles: [
        File('lib/src/my_service.dart'),
        File('lib/models/user.dart'),
      ],
    );
  });
  
  test('should scan and provide runtime metadata', () async {
    final summary = await mockScanner.scan(
      'test_output',
      RuntimeScanLoader(
        scanClasses: [User, MyService],
      ),
    );
    
    expect(summary.libraries, isNotEmpty);
    expect(summary.findClass('User'), isNotNull);
    expect(summary.findClass('MyService'), isNotNull);
  });
}
```

### Custom Library Generation

```dart
void main() {
  final customGenerator = MockLibraryGenerator(
    mirrorSystem: currentMirrorSystem(),
    forceLoadedMirrors: [
      reflectClass(MyClass)!.owner as LibraryMirror,
      reflectClass(MyOtherClass)!.owner as LibraryMirror,
    ],
    onInfo: print,
    onError: (e) => print('Generator Error: $e'),
    configuration: RuntimeScanLoader(
      scanClasses: [MyClass, MyOtherClass],
    ),
  );
  
  test('should generate library metadata', () async {
    final libraries = await customGenerator.generate();
    expect(libraries, hasLength(2));
    
    final myClassLib = libraries.firstWhere(
      (lib) => lib.classes.any((c) => c.name == 'MyClass')
    );
    
    expect(myClassLib, isNotNull);
  });
}
```

## API Reference

### MockRuntimeScanner

#### Constructors
- `MockRuntimeScanner({OnLogged? onInfo, OnLogged? onWarning, OnLogged? onError, List<File>? forceLoadFiles, MockLibraryGeneratorFactory? generatorFactory})`

#### Methods
- `Future<RuntimeScannerSummary> scan(String outputFolder, RuntimeScannerConfiguration configuration, {Directory? source})`: Performs the runtime scan
- `void dispose()`: Cleans up resources

### MockLibraryGenerator

#### Constructors
- `MockLibraryGenerator({required MirrorSystem mirrorSystem, Iterable<LibraryMirror> forceLoadedMirrors = const [], OnLogged? onInfo, OnLogged? onError, required RuntimeScannerConfiguration configuration, List<Package> packages = const []})`

#### Methods
- `Future<List<LibraryDeclaration>> generate()`: Generates library declarations

## Testing Patterns

### Unit Testing Services

```dart
class UserService {
  final UserRepository repository;
  
  UserService(this.repository);
  
  Future<User> getUser(int id) async {
    return await repository.findById(id);
  }
}

void main() {
  late MockRuntimeScanner mockScanner;
  late UserRepository mockRepository;
  
  setUp(() {
    mockScanner = MockRuntimeScanner(
      forceLoadFiles: [File('lib/services/user_service.dart')],
    );
    
    mockRepository = MockUserRepository();
    when(mockRepository.findById(any)).thenAnswer(
      (_) async => User(id: 1, name: 'Test User')
    );
  });
  
  test('should get user from repository', () async {
    // Arrange
    await mockScanner.scan(
      'test_output',
      RuntimeScanLoader(scanClasses: [UserService]),
    );
    
    final userService = UserService(mockRepository);
    
    // Act
    final user = await userService.getUser(1);
    
    // Assert
    expect(user.id, 1);
    expect(user.name, 'Test User');
    verify(mockRepository.findById(1)).called(1);
  });
}
```

### Testing Annotated Classes

```dart
@MyAnnotation()
class AnnotatedClass {
  @MyFieldAnnotation()
  String myField;
  
  @MyMethodAnnotation()
  void myMethod() {}
}

void main() {
  test('should process annotations', () async {
    final mockScanner = MockRuntimeScanner(
      forceLoadFiles: [File('lib/annotated_class.dart')],
    );
    
    final summary = await mockScanner.scan(
      'test_output',
      RuntimeScanLoader(
        scanClasses: [AnnotatedClass],
        annotationTypes: [MyAnnotation, MyFieldAnnotation, MyMethodAnnotation],
      ),
    );
    
    final annotatedClass = summary.findClass('AnnotatedClass');
    expect(annotatedClass, isNotNull);
    
    final annotation = annotatedClass!.getAnnotation('MyAnnotation');
    expect(annotation, isNotNull);
    
    final field = annotatedClass.findField('myField');
    expect(field, isNotNull);
    expect(field!.hasAnnotation('MyFieldAnnotation'), isTrue);
    
    final method = annotatedClass.findMethod('myMethod');
    expect(method, isNotNull);
    expect(method!.hasAnnotation('MyMethodAnnotation'), isTrue);
  });
}
```

## Best Practices

### Selective Loading
Only load the classes and files needed for your tests to keep test execution fast:

```dart
// Good: Only load what's needed
final scanner = MockRuntimeScanner(
  forceLoadFiles: [
    File('lib/services/important_service.dart'),
    File('lib/models/important_model.dart'),
  ],
);

// Bad: Loading everything slows down tests
final scanner = MockRuntimeScanner(
  forceLoadFiles: [
    File('lib/**/*.dart'),  // Avoid this in tests
  ],
);
```

### Resource Management
Always dispose of the scanner when done to free resources:

```dart
group('UserService Tests', () {
  late MockRuntimeScanner mockScanner;
  
  setUp(() {
    mockScanner = MockRuntimeScanner(/* ... */);
  });
  
  tearDown(() {
    mockScanner.dispose();
  });
  
  // Tests...
});
```

### Error Handling
Implement proper error handling in your logging callbacks:

```dart
final scanner = MockRuntimeScanner(
  onError: (error) {
    // Log to test output
    print('TEST ERROR: $error');
    // Or fail the test
    fail('Runtime scan failed: $error');
  },
);
```

## Performance Considerations

### Minimize Reflection Scope
Limit the scope of reflection to only what's necessary for your tests:

```dart
// Only scan specific classes
final summary = await mockScanner.scan(
  'test_output',
  RuntimeScanLoader(
    scanClasses: [User, UserService],  // Explicitly list required classes
  ),
);
```

### Cache Results
If you need to run multiple tests against the same scan results, cache the summary:

```dart
RuntimeScannerSummary? cachedSummary;

Future<RuntimeScannerSummary> getTestSummary() async {
  if (cachedSummary == null) {
    final scanner = MockRuntimeScanner(/* ... */);
    cachedSummary = await scanner.scan(
      'test_output',
      RuntimeScanLoader(/* ... */),
    );
  }
  return cachedSummary!;
}
```

## Common Issues

### Missing Dependencies
If you get errors about missing classes, ensure all required files are force-loaded:

```dart
// If User depends on Role, include both
final scanner = MockRuntimeScanner(
  forceLoadFiles: [
    File('lib/models/user.dart'),
    File('lib/models/role.dart'),  // Include dependencies
  ],
);
```

### Annotation Processing
For annotation processing to work, ensure:
1. The annotation classes are included in the scan
2. The annotation classes are marked with `@Reflectable()`
3. The annotation retention policy is set appropriately

## See Also

- [Dart Reflection](https://api.dart.dev/stable/dart-mirrors/dart-mirrors-library.html)
- [Test Package](https://pub.dev/packages/test)
- [Mockito](https://pub.dev/packages/mockito)
- [Build Runner](https://pub.dev/packages/build_runner)
