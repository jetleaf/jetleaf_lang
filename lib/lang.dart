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

// ignore_for_file: deprecated_member_use

/// 🍃 **JetLeaf Standard Library**
///
/// This library exposes the core foundational utilities of the JetLeaf
/// framework—providing rich APIs for resource handling, I/O streams,
/// collections, math, reflection, system access, time utilities, and more.
///
/// It functions as the **general-purpose toolkit** for JetLeaf applications,
/// similar to a standard library or runtime utility layer.
///
///
/// ## 🧩 Major Capability Areas
///
/// ### 📦 Resource & Asset Loading
/// Supports resolving and loading resources from:
/// - application bundles
/// - asset paths
/// - classpath locations  
/// Includes loaders, resource abstractions, and path utilities.
///
///
/// ### 🔢 Byte & Stream Utilities
/// Low-level binary and streaming primitives:
/// - `Byte`, `ByteArray`, `ByteStream`
/// - Input & output streams (buffered, file, network, in-memory)
/// - Stream builders and adapters
///
/// Enables efficient data processing and I/O pipelines.
///
///
/// ### 📚 Collections Framework
/// Enhanced data structures beyond core Dart:
/// - `ArrayList`, `LinkedList`, `Stack`, `Queue`
/// - `HashMap`, `HashSet`
/// - case-insensitive maps
/// - collectors (inspired by Java Streams)
///
///
/// ### 🧮 Math & Big Numbers
/// Arbitrary-precision numeric types:
/// - `BigDecimal`
/// - `BigInteger`
///
///
/// ### 🌐 Networking
/// Lightweight networking primitives:
/// - `Url`
/// - `UrlConnection`
/// - extension helpers
///
///
/// ### 🔤 Primitive Wrappers
/// Object-style number and boolean types:
/// - `Integer`, `Long`, `Float`, `Double`, `Short`, `Boolean`, `Character`
///
/// Useful for reflection, typed metadata, and JVM-style APIs.
///
///
/// ### 🖥 System & Properties
/// Runtime system inspection and configuration:
/// - platform detectors
/// - system properties
/// - environment-driven behavior
///
///
/// ### ⏱ Time & Date API
/// Inspired by Java Time:
/// - `ZonedDateTime`
/// - `LocalDateTime`, `LocalDate`, `LocalTime`
/// - `ZoneId`
/// - `DateTimeFormatter`
///
///
/// ### 🧵 Threading & Synchronization
/// Cooperative thread abstractions:
/// - logical thread model
/// - synchronization primitives
/// - locks
///
/// *Note:* hides internal `LocalThreadKey`.
///
///
/// ### 🔍 Reflection & Metadata
/// Full meta-modeling capabilities:
/// - classes, fields, methods, parameters
/// - annotations
/// - class loaders
/// - qualified names & package identifiers
/// - `ResolvableType`
///
/// Powers dependency injection, introspection, and runtime type modeling.
///
///
/// ### 🗂 URI Tools
/// - URI templates
/// - validators and validation rules
///
///
/// ### 🔔 Observability (OBS)
/// Eventing system:
/// - observables
/// - event types & enums
///
///
/// ### 🧰 Common Utilities
/// - `Optional`
/// - `StringBuilder`
/// - regex utilities
/// - typedef helpers
///
///
/// ### 🆔 Other Features
/// - locale & language ranges
/// - currency utilities
/// - UUID generation
/// - exception hierarchy
///
///
/// ### 🏗 Build Integration
/// Re-exports JetLeaf build-time support:
/// - `jetleaf_build` package
///
///
/// ## ✅ Intended Usage
///
/// Import once for broad utility access:
/// ```dart
/// import 'package:jetleaf_lang/lang.dart';
/// ```
///
/// Designed for framework-level and advanced application use.
library;

export 'src/meta/resource/asset_loader/_bundler.dart';
export 'src/meta/resource/asset_loader/bundler.dart';
export 'src/meta/resource/asset_loader/interface.dart';
export 'src/meta/resource/class_path/class_path_resource.dart' hide DefaultClassPathResource;
export 'src/meta/resource/asset_path/asset_resource.dart' hide DefaultAssetBuilder, DefaultAssetPathResource, FileAssetPathResource;

export 'src/byte/byte_array.dart';
export 'src/byte/byte_stream.dart';
export 'src/byte/byte.dart';

export 'src/collections/array_list.dart';
export 'src/collections/linked_list.dart';
export 'src/collections/stack.dart';
export 'src/collections/queue.dart';
export 'src/collections/linked_queue.dart';
export 'src/collections/linked_stack.dart';
export 'src/collections/hash_map.dart';
export 'src/collections/hash_set.dart';
export 'src/collections/adaptable.dart';
export 'src/collections/case_insensitive_map.dart';

export 'src/collectors/collectors.dart';
export 'src/collectors/collector.dart';

export 'src/comparator/comparator.dart';
export 'src/comparator/order_comparator.dart';
export 'src/comparator/ordered.dart';
export 'src/comparator/package_order_comparator.dart';

export 'src/extensions/others/date_time.dart';
export 'src/extensions/others/duration.dart';
export 'src/extensions/others/dynamic.dart';
export 'src/extensions/others/t.dart';
export 'src/extensions/others/type.dart';

export 'src/extensions/primitives/bool.dart';
export 'src/extensions/primitives/double.dart';
export 'src/extensions/primitives/int.dart';
export 'src/extensions/primitives/iterable.dart';
export 'src/extensions/primitives/list.dart';
export 'src/extensions/primitives/map.dart';
export 'src/extensions/primitives/num.dart';
export 'src/extensions/primitives/set.dart';
export 'src/extensions/primitives/string.dart';

export 'src/io/input_stream/buffered_input_stream.dart';
export 'src/io/input_stream/file_input_stream.dart';
export 'src/io/input_stream/input_stream.dart';
export 'src/io/input_stream/network_input_stream.dart';
export 'src/io/input_stream/byte_array_input_stream.dart';
export 'src/io/input_stream/input_stream_source.dart';
export 'src/io/input_stream/string_input_stream.dart';

export 'src/io/output_stream/buffered_output_stream.dart';
export 'src/io/output_stream/byte_array_output_stream.dart';
export 'src/io/output_stream/file_output_stream.dart';
export 'src/io/output_stream/network_output_stream.dart';
export 'src/io/output_stream/output_stream.dart';
export 'src/io/output_stream/sink_output_stream.dart';

export 'src/io/reader/reader.dart';
export 'src/io/reader/file_reader.dart';
export 'src/io/reader/string_reader.dart';
export 'src/io/reader/buffered_reader.dart';

export 'src/io/writer/writer.dart';
export 'src/io/writer/file_writer.dart';
export 'src/io/writer/buffered_writer.dart';

export 'src/io/base_stream/base_stream.dart';
export 'src/io/base_stream/double/double_stream.dart';
export 'src/io/base_stream/double/_double_stream.dart';
export 'src/io/base_stream/int/int_stream.dart';
export 'src/io/base_stream/int/_int_stream.dart';
export 'src/io/base_stream/generic/generic_stream.dart';
export 'src/io/base_stream/generic/_generic_stream.dart';

export 'src/io/print_stream/print_stream.dart';
export 'src/io/print_stream/console_print_stream.dart';

export 'src/io/stream_support.dart';
export 'src/io/stream_builder.dart';
export 'src/io/base.dart';

export 'src/garbage_collector/garbage_collector.dart';

export 'src/math/big_decimal.dart';
export 'src/math/big_integer.dart';

export 'src/net/url.dart';
export 'src/net/url_connection.dart';
export 'src/net/extension.dart';

export 'src/primitives/integer.dart';
export 'src/primitives/long.dart';
export 'src/primitives/float.dart';
export 'src/primitives/double.dart';
export 'src/primitives/character.dart';
export 'src/primitives/boolean.dart';
export 'src/primitives/short.dart';

export 'src/time/zoned_date_time.dart';
export 'src/time/local_date_time.dart';
export 'src/time/local_date.dart';
export 'src/time/local_time.dart';
export 'src/time/zone_id.dart';
export 'src/time/date_time_formatter.dart';

export 'src/thread/thread.dart';
export 'src/thread/local_thread.dart' hide LocalThreadKey;

export 'src/synchronized/synchronized.dart';
export 'src/synchronized/synchronized_lock.dart';

export 'src/commons/optional.dart';
export 'src/commons/string_builder.dart';
export 'src/commons/commons.dart' hide TryWithAction;
export 'src/commons/regex_utils.dart';
export 'src/commons/typedefs.dart';
export 'src/commons/version.dart';
export 'src/commons/version_range.dart';

export 'src/locale/locale.dart';
export 'src/locale/language_range.dart';

export 'src/currency/currency.dart';
export 'src/uuid/uuid.dart';

export 'src/meta/class/class.dart';
export 'src/meta/class/class_gettable.dart';
export 'src/meta/class/class_type.dart';
export 'src/meta/field/field.dart';
export 'src/meta/constructor/constructor.dart';
export 'src/meta/method/method.dart';
export 'src/meta/parameter/parameter.dart';
export 'src/meta/enum/enum_value.dart';
export 'src/meta/annotation/annotation.dart';
export 'src/meta/protection_domain/protection_domain.dart';
export 'src/meta/package_identifier.dart';
export 'src/meta/core.dart';
export 'src/meta/hint/materialized_runtime_hint.dart';
export 'src/meta/record/record_field.dart';

export 'src/meta/executable/executable_argument_resolver.dart';
export 'src/meta/executable/executable_selector.dart';
export 'src/meta/executable/executable_instantiator.dart';

export 'src/uri/uri_template.dart';
export 'src/uri/uri_validators.dart';
export 'src/uri/uri_validator.dart';

export 'src/utils/method_utils.dart';
export 'src/utils/class_utils.dart';

export 'src/obs/obs.dart';
export 'src/obs/obs_enums.dart';
export 'src/obs/obs_event.dart';
export 'src/obs/obs_types.dart';

export 'src/exceptions.dart';
export 'src/nested_runtime_exception.dart';

export 'package:jetleaf_build/jetleaf_build.dart' show
  Constant,
  runScan,
  runTestScan,
  Asset,
  Package,
  Hint,
  RuntimeHint,
  Runtime,
  ExecutableArgument,
  EqualsAndHashCode,
  Generic,
  RuntimeHintDescriptor,
  RuntimeHintProvider,
  GenerativeAsset,
  GenerativePackage,
  BuildException,
  RuntimeException,
  FieldAccessException,
  FieldMutationException,
  MethodNotFoundException,
  RuntimeResolverException,
  GenericResolutionException,
  ArgumentResolutionException,
  PrivateFieldAccessException,
  ConstructorNotFoundException,
  PrivateMethodInvocationException,
  UnresolvedTypeInstantiationException,
  UnsupportedRuntimeOperationException,
  PrivateConstructorInvocationException,
  UnexpectedArgumentException,
  TooFewPositionalArgumentException,
  TooManyPositionalArgumentException,
  MissingRequiredNamedParameterException,
  MissingRequiredPositionalParameterException,
  Throwable,
  PackageNames,
  ReflectableAnnotation,
  Author,
  ToString,
  ToStringOptions,
  QualifiedName,
  System,
  SystemDetector,
  SystemProperties,
  StdExtension,
  SystemExtension
;