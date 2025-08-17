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

import 'url.dart';

/// {@template uri_extension}
/// Extension on Dart's [Uri] class to convert it into a [Url] instance.
/// 
/// This allows seamless transition between [Uri] and [Url] for interoperability.
/// 
/// Example:
/// ```dart
/// final uri = Uri.parse('https://example.com');
/// final url = uri.toUrl();
/// ```
/// {@endtemplate}
extension UriExtension on Uri {
  /// {@macro uri_extension}
  Url toUrl() => Url(toString());
}