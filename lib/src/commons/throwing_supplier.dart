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

/// {@template throwing_supplier}
/// A functional interface that supplies a value and may throw an exception.
///
/// This typedef represents a function that takes no parameters and returns
/// a value of type [T], possibly throwing an exception.
///
/// This is especially useful in APIs where you want to defer the execution
/// of a potentially risky or expensive operation, such as file access,
/// database queries, or complex computations.
///
/// ### Example
/// ```dart
/// final supplier = ThrowingSupplier<String>(() {
///   if (DateTime.now().second % 2 == 0) {
///     throw Exception('Random failure');
///   }
///   return 'Success!';
/// });
///
/// try {
///   final result = supplier.get();
///   print('Result: $result');
/// } catch (e) {
///   print('Error occurred: $e');
/// }
/// ```
/// {@endtemplate}
typedef ThrowingSupplier<T> = T Function();

/// {@macro throwing_supplier}
///
/// This extension provides a `.get()` method to call the supplier
/// in a more expressive and object-oriented way.
///
/// Instead of calling `supplier()`, you can write `supplier.get()`,
/// improving readability in functional or builder-style code.
///
/// ### Example
/// ```dart
/// final supplier = ThrowingSupplier<int>(() => 42);
/// print(supplier.get()); // prints 42
/// ```
extension ThrowingSupplierGet<T> on ThrowingSupplier<T> {
  /// Invokes the supplier and returns the result.
  ///
  /// This method may throw any exception that occurs during execution
  /// of the underlying supplier function.
  T get() => this();
}