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

part of 'parameterized_type_reference.dart';

@Generic(_ParameterizedTypeReference)
class _ParameterizedTypeReference<T> implements ParameterizedTypeReference<T> {
  _ParameterizedTypeReference();

  @override
  Type getType() => T;

  @override
  ResolvableType getResolvableType() => ResolvableType.forClass(T);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _ParameterizedTypeReference) return false;
    return toString() == other.toString() || T == other.getType() || getResolvableType() == other.getResolvableType();
  }

  @override
  int get hashCode => toString().hashCode ^ T.hashCode ^ getResolvableType().hashCode;

  @override
  String toString() => 'ParameterizedTypeReference<$T>';
}