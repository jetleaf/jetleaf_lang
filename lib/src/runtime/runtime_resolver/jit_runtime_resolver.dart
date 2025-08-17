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

import 'dart:mirrors' as mirrors;

import '../../exceptions.dart';
import 'runtime_resolver.dart';

/// {@template jit_executable_resolver}
/// A reflection-based implementation of [RuntimeResolver] using `dart:mirrors`.
///
/// This class provides dynamic instantiation, method invocation, and field access
/// for types at runtime, leveraging the Dart mirrors API. It is intended for use
/// in JIT (Just-In-Time) environments where `dart:mirrors` is available (e.g., VM,
/// not AOT-compiled code).
///
/// ### Example: Instantiating a class
/// ```dart
/// final resolver = JitExecutableResolver();
/// final person = resolver.newInstance<Person>('named', ['Eve']);
/// ```
///
/// ### Example: Invoking a method
/// ```dart
/// resolver.invokeMethod(person, 'greet'); // calls person.greet()
/// ```
///
/// ### Example: Getting and setting a field
/// ```dart
/// final name = resolver.getValue(person, 'name');
/// resolver.setValue(person, 'name', 'Alice');
/// ```
///
/// This is especially useful in frameworks that need to instantiate objects or
/// call methods based on metadata, annotations, or configuration at runtime.
/// {@endtemplate}
class JitRuntimeResolver implements RuntimeResolver {
  /// {@macro jit_executable_resolver}
  const JitRuntimeResolver();

  String _message<T>() => '''
This might be happening because the requesting $T was received as an unresolved generic type, which JetLeaf
runtime resolved with its `@Sealed()` annotation provision. For an effective resolution, as at v1.0.0,
we require developers to create `RuntimeHint` for the generic type.
''';

  @override
  T newInstance<T>(String name, [List<Object?> args = const [], Map<String, Object?> namedArgs = const {}]) {
    try {
      final mirror = mirrors.reflectClass(T);
      final constructorName = name.isEmpty ? Symbol('') : Symbol(name);
      
      if(namedArgs.isNotEmpty) {
        return mirror.newInstance(constructorName, args, namedArgs.map((key, value) => MapEntry(Symbol(key), value))).reflectee as T;
      }

      return mirror.newInstance(constructorName, args).reflectee as T;
    } on UnImplementedResolverException catch (_) {
      rethrow;
    } catch (e, stack) {
      throw IllegalStateException('Failed to create new instance of $T using constructor "$name". ${_message<T>()}. $e\n$stack');
    }
  }

  @override
  Object? invokeMethod<T>(T instance, String method, {List<Object?> args = const [], Map<String, Object?> namedArgs = const {}}) {
    try {
      final mirror = mirrors.reflect(instance);
      final methodSymbol = Symbol(method);
      final methodMirror = mirror.type.declarations[methodSymbol] as mirrors.MethodMirror?;
      
      if (methodMirror == null || methodMirror.isConstructor || methodMirror.isGetter || methodMirror.isSetter) {
        throw UnImplementedResolverException(T, 'Method "$method" not found or is not an invokable method for type $T');
      }
      
      return mirror.invoke(methodSymbol, args, namedArgs.map((key, value) => MapEntry(Symbol(key), value))).reflectee as T?;
    } on UnImplementedResolverException catch (_) {
      rethrow;
    } catch (e, stack) {
      throw IllegalStateException('Failed to invoke method "$method" on instance of $T. ${_message<T>()}. $e\n$stack');
    }
  }

  @override
  Object? getValue<T>(T instance, String name) {
    try {
      final mirror = mirrors.reflect(instance);
      final fieldSymbol = Symbol(name);
      final fieldMirror = mirror.type.declarations[fieldSymbol] as mirrors.VariableMirror?;
      
      if (fieldMirror == null) {
        // Could be a getter method
        final getterMethod = mirror.type.declarations[fieldSymbol] as mirrors.MethodMirror?;
        if (getterMethod != null && getterMethod.isGetter) {
          return mirror.invoke(fieldSymbol, []).reflectee;
        }
        throw UnImplementedResolverException(T, 'Field or getter "$name" not found for type $T');
      }
      
      return mirror.getField(fieldSymbol).reflectee;
    } on UnImplementedResolverException catch (_) {
      rethrow;
    } catch (e, stack) {
      throw IllegalStateException('Failed to get value of field "$name" on instance of $T. ${_message<T>()}. $e\n$stack');
    }
  }

  @override
  void setValue<T>(T instance, String name, Object? value) {
    try {
      final mirror = mirrors.reflect(instance);
      final fieldSymbol = Symbol(name);
      final fieldMirror = mirror.type.declarations[fieldSymbol] as mirrors.VariableMirror?;
      
      if (fieldMirror == null) {
        // Could be a setter method
        final setterMethod = mirror.type.declarations[Symbol('$name=')] as mirrors.MethodMirror?;
        if (setterMethod != null && setterMethod.isSetter) {
          mirror.invoke(Symbol('$name='), [value]);
          return;
        }
        throw UnImplementedResolverException(T, 'Field or setter "$name" not found for type $T');
      }
      
      if (fieldMirror.isFinal || fieldMirror.isConst) {
        throw UnImplementedResolverException(T, 'Cannot set value on final or const field "$name" of type $T');
      }
      
      mirror.setField(fieldSymbol, value);
    } on UnImplementedResolverException catch (_) {
      rethrow;
    } catch (e, stack) {
      throw IllegalStateException('Failed to set value of field "$name" on instance of $T. ${_message<T>()}. $e\n$stack');
    }
  }
}