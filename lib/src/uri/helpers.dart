// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

/// Extracts variable names from a URI template.
///
/// A URI template may contain variables in the format `{variableName}`.
/// This function scans the template and returns a list of all variable names.
///
/// ### Example:
/// ```dart
/// final template = '/users/{userId}/posts/{postId}';
/// final vars = extractVariableNames(template);
/// print(vars); // ['userId', 'postId']
/// ```
///
/// - `{}` must contain only alphanumeric or underscore characters.
/// - Duplicates are preserved.
///
/// [template] — The URI template string to scan.
///
/// Returns a list of variable names (without braces).
List<String> extractVariableNames(String template) {
  final names = <String>[];
  final regex = RegExp(r'\{([a-zA-Z0-9_]+)\}');
  for (final match in regex.allMatches(template)) {
    names.add(match.group(1)!);
  }
  return names;
}

/// Builds a regular expression from a URI template.
///
/// This function takes a URI template and converts it into a regular expression
/// that can be used to match against paths. It handles variable extraction and
/// proper regex construction.
///
/// ### Example:
/// ```dart
/// final template = '/users/{userId}/posts/{postId}';
/// final regex = buildRegex(template);
/// print(regex.pattern); // '^/users/([^/]+)/posts/([^/]+)$'
/// ```
///
/// - Variables are converted to capture groups (e.g., `{userId}` -> `([^/]+)`).
/// - Dots in the template are escaped.
/// - The regex ensures it matches the entire path.
///
/// [template] — The URI template string to convert.
///
/// Returns a regular expression object that can be used to match paths.
RegExp buildRegex(String template) {
  // Escape dots and replace variables with capture groups
  String regexPattern = template.replaceAll('.', '\\.');
  regexPattern = regexPattern.replaceAllMapped(RegExp(r'\{[a-zA-Z0-9_]+\}'), (match) => r'([^/]+)');
  // Ensure it matches the whole path
  return RegExp('^$regexPattern\$');
}