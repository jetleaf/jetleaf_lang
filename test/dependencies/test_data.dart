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

class TestData {
  final String name;
  final int age;

  TestData({required this.name, required this.age});

  Map<String, dynamic> toJson() => {'name': name, 'age': age};

  factory TestData.fromJson(Map<String, dynamic> json) => TestData(name: json['name'], age: json['age']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TestData &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}