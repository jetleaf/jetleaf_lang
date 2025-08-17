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

import 'package:jetleaf_lang/reflection.dart';
import 'package:jetleaf_lang/src/runtime/utils.dart';
import 'package:test/test.dart';

void main() {
  group('getPackageNameFromUri', () {
    test('should extract package name from pub packages', () {
      expect(ReflectUtils.getPackageNameFromUri('package:html'), 'html');
      expect(ReflectUtils.getPackageNameFromUri('package:async'), 'async');
      expect(ReflectUtils.getPackageNameFromUri('package:test'), 'test');
      expect(ReflectUtils.getPackageNameFromUri('package:collection'), 'collection');
    });

    test('should return null for Dart core libraries', () {
      expect(ReflectUtils.getPackageNameFromUri('dart:html'), isNull);
      expect(ReflectUtils.getPackageNameFromUri('dart:async'), isNull);
      expect(ReflectUtils.getPackageNameFromUri('dart:core'), isNull);
      expect(ReflectUtils.getPackageNameFromUri('dart:ui'), isNull);
    });

    test('should handle valid package names regardless of keywords', () {
      expect(ReflectUtils.getPackageNameFromUri('package:class'), 'class');
      expect(ReflectUtils.getPackageNameFromUri('package:void'), 'void');
      expect(ReflectUtils.getPackageNameFromUri('package:for'), 'for');
    });

    test('should handle other edge cases', () {
      expect(ReflectUtils.getPackageNameFromUri('package:_private'), '_private');
      expect(ReflectUtils.getPackageNameFromUri('package:my_pkg/sub/path.dart'), 'my_pkg');
      expect(ReflectUtils.getPackageNameFromUri('package:my_pkg/'), 'my_pkg');
      expect(ReflectUtils.getPackageNameFromUri('package:my_pkg'), 'my_pkg');
    });

    test('should return null for invalid cases', () {
      expect(ReflectUtils.getPackageNameFromUri('package:/'), isNull);
      expect(ReflectUtils.getPackageNameFromUri('https://example.com'), isNull);
      expect(ReflectUtils.getPackageNameFromUri('file:///path.dart'), isNull);
      expect(ReflectUtils.getPackageNameFromUri(''), isNull);
      expect(ReflectUtils.getPackageNameFromUri(null), isNull);
    });
  });

  group('isNonLoadableJetLeafFile', () {
    test('should match jetleaf tool/bin folders', () {
      expect(ReflectUtils.isNonLoadableJetLeafFile(Uri.parse('file:///project/jetleaf/bin')), true);
      expect(ReflectUtils.isNonLoadableJetLeafFile(Uri.parse('file:///jetleaf/tool/')), true);
      expect(ReflectUtils.isNonLoadableJetLeafFile(Uri.parse('file:///some/path/jetleaf/bin/main.dart')), true);
    });

    test('should not match other paths', () {
      expect(ReflectUtils.isNonLoadableJetLeafFile(Uri.parse('file:///jetleaf/src/main.dart')), false);
      expect(ReflectUtils.isNonLoadableJetLeafFile(Uri.parse('file:///bin/jetleaf')), false);
    });
  });

  group('isSkippableJetLeafPackage', () {
    test('should match specific jetleaf packages', () {
      expect(ReflectUtils.isSkippableJetLeafPackage(Uri.parse('package:jetleaf/src/lang/reflect/access')), true);
      expect(ReflectUtils.isSkippableJetLeafPackage(Uri.parse('package:jetleaf/src/logging/logger.dart')), true);
      expect(ReflectUtils.isSkippableJetLeafPackage(Uri.parse('package:jetleaf/test')), true);
    });

    test('should not match other packages', () {
      expect(ReflectUtils.isSkippableJetLeafPackage(Uri.parse('package:jetleaf/src/core')), false);
      expect(ReflectUtils.isSkippableJetLeafPackage(Uri.parse('package:other_package/test')), false);
    });
  });

  group('ReflectUtils.shouldNotIncludeLibrary', () {
    test('should exclude packages in packagesToExclude', () async {
      final loader = RuntimeScannerConfiguration(
        packagesToExclude: ['package:html', 'r:package:.*_test'],
      );
      
      expect(await ReflectUtils.shouldNotIncludeLibrary(Uri.parse('package:html/parser.dart'), loader, print), true);
      expect(await ReflectUtils.shouldNotIncludeLibrary(Uri.parse('package:app_test/core.dart'), loader, print), true);
    });

    test('should include packages in packagesToScan', () async {
      final loader = RuntimeScannerConfiguration(
        packagesToScan: ['package:core', 'r:package:feature_.*'],
      );
      
      expect(await ReflectUtils.shouldNotIncludeLibrary(Uri.parse('package:core/utils.dart'), loader, print), false);
      expect(await ReflectUtils.shouldNotIncludeLibrary(Uri.parse('package:feature_auth/login.dart'), loader, print), false);
    });

    test('should handle non-package URIs', () async {
      final loader = RuntimeScannerConfiguration();
      
      expect(await ReflectUtils.shouldNotIncludeLibrary(Uri.parse('dart:core'), loader, print), true);
      expect(await ReflectUtils.shouldNotIncludeLibrary(Uri.parse('file:///test/main_test.dart'), loader, print), false);
    });
  });

  group('isNonLoadableFile', () {
    test('should match files in excluded directories', () {
      final loader = RuntimeScannerConfiguration(
        filesToExclude: [File('lib/internal')],
      );

      expect(ReflectUtils.isNonLoadableFile(Uri.parse('file:///${Directory.current.path}/lib/internal/utils.dart'), loader), true);
    });

    test('should not match included files', () {
      final loader = RuntimeScannerConfiguration(
        filesToExclude: [File('lib/internal')],
      );
      
      expect(ReflectUtils.isNonLoadableFile(Uri.parse('file:///${Directory.current.path}/lib/main.dart'), loader), false);
    });
  });

  group('Content Analysis', () {
    test('isPartOf should detect part-of directives', () {
      expect(ReflectUtils.isPartOf("part of 'main.dart';"), true);
      expect(ReflectUtils.isPartOf("// part of main.dart"), false); // Commented out
    });

    test('hasMirrorImport should detect mirror imports', () {
      expect(ReflectUtils.hasMirrorImport("import 'dart:mirrors';"), true);
      expect(ReflectUtils.hasMirrorImport("import 'package:test/test.dart';"), false);
    });

    test('isTest should detect test imports', () {
      expect(ReflectUtils.isTest("import 'package:test/test.dart';"), true);
      expect(ReflectUtils.isTest("import 'package:test/scaffolding.dart';"), true);
    });
  });

  // Helper function tests
  group('Helper Functions', () {
    test('matchesAnyPattern should handle regex and string patterns', () {
      expect(ReflectUtils.matchesAnyPattern('package:html', ['package:html']), true);
      expect(ReflectUtils.matchesAnyPattern('package:test', ['r:package:t.*']), true);
      expect(ReflectUtils.matchesAnyPattern('package:core', ['package:html']), false);
    });

    test('matchesAnyFile should match file paths', () {
      final currentDir = Directory.current.path;
      expect(ReflectUtils.matchesAnyFile('$currentDir/lib/main.dart', [File('$currentDir/lib/main.dart')]), true);
      expect(ReflectUtils.matchesAnyFile('$currentDir/lib/utils.dart', [File('$currentDir/lib/main.dart')]), false);
    });
  });
}