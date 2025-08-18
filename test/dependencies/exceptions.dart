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

import 'package:test/test.dart';
import 'package:jetleaf_lang/lang.dart';

const isInvalidArgumentException = TypeMatcher<InvalidArgumentException>();
Matcher throwsInvalidArgumentException = throwsA(isInvalidArgumentException);

const isInvalidFormatException = TypeMatcher<InvalidFormatException>();
Matcher throwsInvalidFormatException = throwsA(isInvalidFormatException);

const isNoGuaranteeException = TypeMatcher<NoGuaranteeException>();
Matcher throwsNoGuaranteeException = throwsA(isNoGuaranteeException);