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

part of '../meta/parameterized_type_reference.dart';

@Generic(_ParameterizedTypeReference)
class _ParameterizedTypeReference<T> with EqualsAndHashCode implements ParameterizedTypeReference<T> {
  _ParameterizedTypeReference();

  @override
  Type getType() => T;

  @override
  ResolvableType getResolvableType() => ResolvableType.forClass(T);

  @override
  List<Object?> equalizedProperties() {
    return [
      T,
      getResolvableType(),
    ];
  }

  @override
  String toString() => 'ParameterizedTypeReference<$T>';
}