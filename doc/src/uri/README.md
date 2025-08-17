# URI Module

## Overview

The URI module provides powerful utilities for working with URIs, including template-based URI generation, parsing, and validation. It's designed to handle complex URI manipulation tasks with a clean, type-safe API.

## Features

- **URI Templates**: Define and expand URI templates with named parameters
- **Validation**: Comprehensive validation of URI components
- **Security**: Built-in security validators for common use cases
- **Compliance**: RFC 6570 URI Template and RFC 3986 URI specification compliant

## Core Components

### UriTemplate

A utility class for working with URI templates that include path variables (e.g., `/users/{id}/orders/{orderId}`). Supports matching paths against templates and expanding templates with variables.

### Validators

A collection of validators for common URI validation scenarios:
- `SchemeValidator`: Validates URI scheme presence
- `HostValidator`: Validates hostname presence
- `AbsolutePathValidator`: Validates absolute paths
- `SecureSchemeValidator`: Validates secure schemes (https/wss)
- `NoCredentialsValidator`: Prevents credentials in URIs
- `AllowedDomainsValidator`: Restricts to specific domains
- `NoIpAddressValidator`: Prevents raw IP addresses
- `NoSpacesValidator`: Prevents spaces in URIs
- `QueryParamValidator`: Validates required query parameters

## Usage

### Basic URI Template

```dart
import 'package:jetleaf_lang/uri.dart';

// Create a template with named parameters
final template = UriTemplate('/users/{userId}/posts/{postId}');

// Match a path against the template
final match = template.match('/users/42/posts/99');
print(match); // {'userId': '42', 'postId': '99'}

// Expand a template with values
final uri = template.expand({
  'userId': '42',
  'postId': '99',
});
print(uri); // '/users/42/posts/99'
```

### URI Validation

```dart
import 'package:jetleaf_lang/uri.dart';

// Create a composite validator
final validators = [
  SchemeValidator(),
  HostValidator(),
  SecureSchemeValidator(),
  NoCredentialsValidator(),
  AllowedDomainsValidator(['example.com', 'api.example.com']),
];

// Validate a URI
final uri = Uri.parse('https://api.example.com/users');
final isValid = validators.every((v) => v.isValid(uri));

if (!isValid) {
  // Get error messages from failed validators
  final errors = validators
      .where((v) => !v.isValid(uri))
      .map((v) => v.errorMessage);
  print('Validation errors: $errors');
}
```

### Custom Validators

```dart
class CustomSchemeValidator implements UriValidator {
  final List<String> allowedSchemes;
  
  CustomSchemeValidator(this.allowedSchemes);
  
  @override
  bool isValid(Uri uri) => allowedSchemes.contains(uri.scheme);
  
  @override
  String get errorMessage => 'Scheme must be one of: ${allowedSchemes.join(', ')}';
}

// Usage
final validator = CustomSchemeValidator(['http', 'https', 'ftp']);
print(validator.isValid(Uri.parse('ftp://example.com'))); // true
print(validator.isValid(Uri.parse('ws://example.com')));  // false
```

## API Reference

### UriTemplate

#### Constructors

- `UriTemplate(String template)`: Creates a new URI template
  - `template`: URI template string with `{param}` placeholders

#### Methods

- `Map<String, String> match(String path)`: Matches a path against the template
  - Returns a map of parameter names to values
  - Returns `null` if the path doesn't match the template
  
- `String expand(Map<String, dynamic> values)`: Expands the template with provided values
  - `values`: Map of parameter names to values
  - Returns the expanded URI string
  
- `bool matches(String path)`: Checks if a path matches the template
  - Returns `true` if the path matches, `false` otherwise

### Validators

#### Common Validator Methods

- `bool isValid(Uri uri)`: Validates the URI
  - Returns `true` if valid, `false` otherwise
  
- `String get errorMessage`: Gets the error message for invalid URIs

#### Built-in Validators

1. **SchemeValidator**
   - Validates that a URI has a scheme (e.g., `https://`)
   
2. **HostValidator**
   - Validates that a URI has a hostname
   
3. **AbsolutePathValidator**
   - Validates that a URI has an absolute path (starts with '/')
   
4. **SecureSchemeValidator**
   - Validates that a URI uses a secure scheme (https/wss by default)
   
5. **NoCredentialsValidator**
   - Validates that a URI doesn't contain user credentials
   
6. **AllowedDomainsValidator**
   - Validates that a URI's host is in the allowed list
   
7. **NoIpAddressValidator**
   - Validates that a URI uses a domain name, not an IP address
   
8. **NoSpacesValidator**
   - Validates that a URI doesn't contain spaces
   
9. **QueryParamValidator**
   - Validates that a URI contains required query parameters

## Best Practices

### URI Template Design

1. **Be Specific**
   - Use descriptive parameter names (e.g., `{userId}` instead of `{id}`)
   - Group related resources in your path structure
   - Keep templates readable and intuitive

2. **Versioning**
   - Consider including API version in the path (e.g., `/v1/users/{id}`)
   - Plan for future API versions in your template design

3. **Parameter Naming**
   - Use consistent naming conventions (camelCase or snake_case)
   - Document expected parameter types and constraints

### Validation Strategy

1. **Security First**
   - Always validate URIs before making requests
   - Use `SecureSchemeValidator` for external API calls
   - Prevent SSRF with `AllowedDomainsValidator`

2. **Input Sanitization**
   - Use `NoSpacesValidator` to prevent malformed URIs
   - Consider URL-encoding dynamic values in templates

3. **Composition**
   - Combine validators for comprehensive validation
   - Create custom validators for domain-specific rules

## Performance Considerations

### URI Template Matching

- Template compilation is done once when the `UriTemplate` is created
- Matching is O(n) where n is the number of path segments
- Consider caching compiled templates for frequently used patterns

### Validation

- Validators are designed to fail fast
- Order validators from most restrictive to least restrictive
- Cache validation results when possible for repeated validations

## Advanced Usage

### Custom Template Syntax

```dart
class CustomUriTemplate extends UriTemplate {
  static final _customPattern = RegExp(r'\[([^\]]+)\]');
  
  CustomUriTemplate(String template) : super._(template, _customPattern);
  
  @override
  String expand(Map<String, dynamic> values) {
    // Custom expansion logic
    return super.expand(values);
  }
}

// Usage: [param] instead of {param}
final template = CustomUriTemplate('/users/[userId]');
```

### Composite Validator

```dart
class CompositeValidator implements UriValidator {
  final List<UriValidator> validators;
  
  CompositeValidator(this.validators);
  
  @override
  bool isValid(Uri uri) => 
      validators.every((v) => v.isValid(uri));
      
  @override
  String get errorMessage => validators
      .map((v) => v.errorMessage)
      .join('\n');
}

// Usage
final validator = CompositeValidator([
  SchemeValidator(),
  HostValidator(),
  SecureSchemeValidator(),
]);
```

## Common Pitfalls

1. **Incomplete Validation**
   - Not validating all URI components can lead to security vulnerabilities
   - Always validate scheme, host, and path at minimum

2. **Overly Permissive Templates**
   - Be specific with template patterns to avoid ambiguous matches
   - Consider using regex constraints for parameters

3. **Performance with Large Templates**
   - Complex templates with many variables may impact performance
   - Profile and optimize critical paths

## See Also

- [RFC 3986 - URI Generic Syntax](https://tools.ietf.org/html/rfc3986)
- [RFC 6570 - URI Template](https://tools.ietf.org/html/rfc6570)
- [Dart Uri class](https://api.dart.dev/stable/dart-core/Uri-class.html)
