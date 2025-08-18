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

import 'dart:isolate';

import 'package:test/test.dart';
import 'package:jetleaf_lang/lang.dart';

void main() {
  group('ThreadLocal (Isolate-based)', () {
    late ThreadLocal<String> threadLocal;

    setUp(() {
      threadLocal = ThreadLocal<String>();
    });

    test('get returns null when unset', () {
      expect(threadLocal.get(), isNull);
    });

    test('set and get work in main isolate', () {
      threadLocal.set('hello');
      expect(threadLocal.get(), 'hello');
    });

    test('remove clears the value', () {
      threadLocal.set('value');
      threadLocal.remove();
      expect(threadLocal.get(), isNull);
    });

    test('values are isolate-local', () async {
      threadLocal.set('main');

      final receivePort = ReceivePort();
      await Isolate.spawn((SendPort sendPort) {
        final threadLocal = ThreadLocal<String>();
        threadLocal.set('child');
        sendPort.send(threadLocal.get());
      }, receivePort.sendPort);

      final result = await receivePort.first;
      expect(result, 'child');
      expect(threadLocal.get(), 'main');
    });
  });
}