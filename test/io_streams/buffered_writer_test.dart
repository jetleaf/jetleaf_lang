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

import 'dart:io';

import 'package:jetleaf_lang/jetleaf_lang.dart';
import 'package:test/test.dart';

void main() {
  group('BufferedWriter', () {
    late File file;
    late BufferedWriter writer;

    setUp(() {
      file = File('test/io/tmp_buffered_output.txt');
      if (file.existsSync()) file.deleteSync();
    });

    tearDown(() async {
      await writer.close();
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('writeChar writes and flushes single char', () async {
      writer = BufferedWriter(FileWriter.fromFile(file));
      await writer.writeChar('H'.codeUnitAt(0));
      await writer.flush();
      final content = await file.readAsString();
      expect(content, 'H');
    });

    test('write writes string with flush', () async {
      writer = BufferedWriter(FileWriter.fromFile(file));
      await writer.write('Hello, Dart!');
      await writer.flush();
      final content = await file.readAsString();
      expect(content, 'Hello, Dart!');
    });

    test('writeLine appends newline', () async {
      writer = BufferedWriter(FileWriter.fromFile(file));
      await writer.writeLine('Line 1');
      await writer.flush();
      final content = await file.readAsString();
      expect(content, 'Line 1\n');
    });

    test('writeLine with null writes newline only', () async {
      writer = BufferedWriter(FileWriter.fromFile(file));
      await writer.writeLine();
      await writer.flush();
      final content = await file.readAsString();
      expect(content, '\n');
    });

    test('writeChars writes partial char list', () async {
      writer = BufferedWriter(FileWriter.fromFile(file));
      await writer.writeChars('Buffered'.codeUnits, 0, 5); // Buffe
      await writer.flush();
      final content = await file.readAsString();
      expect(content, 'Buffe');
    });

    test('handles large writes with small buffer size', () async {
      writer = BufferedWriter(FileWriter.fromFile(file), bufferSize: 4);
      await writer.write('ABCDEFG'); // Will require flushing mid-way
      await writer.flush();
      final content = await file.readAsString();
      expect(content, 'ABCDEFG');
    });

    test('close flushes and closes', () async {
      writer = BufferedWriter(FileWriter.fromFile(file));
      await writer.write('Final');
      await writer.close();
      final content = await file.readAsString();
      expect(content, 'Final');
    });
  });
}