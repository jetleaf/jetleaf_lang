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

/// {@template lang_library}
/// 🔡 JetLeaf Language & Utility Core
/// 
/// This library exposes extended Dart primitives, collections, optional types,
/// I/O streams, date/time utilities, math types, regex, and more.
/// 
/// ---
/// 
/// ### 🧩 Key Areas:
/// - Extended primitives and collections
/// - Custom numeric types (Integer, BigDecimal, etc.)
/// - I/O abstractions (InputStream, OutputStream, FileReader)
/// - Streams API similar to Java's Stream
/// - Date and time (LocalDateTime, ZonedDateTime)
/// 
/// {@endtemplate}
/// 
/// @author Evaristus Adimonyemma
/// @emailAddress evaristusadimonyemma@hapnium.com
/// @organization Hapnium
library;

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

export 'src/collectors/collectors.dart';
export 'src/collectors/collector.dart';

export 'src/comparator/comparator.dart';

export 'src/helpers/equals_and_hash_code.dart';
export 'src/helpers/to_string.dart';

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

export 'src/io/output_stream/buffered_output_stream.dart';
export 'src/io/output_stream/byte_array_output_stream.dart';
export 'src/io/output_stream/file_output_stream.dart';
export 'src/io/output_stream/network_output_stream.dart';
export 'src/io/output_stream/output_stream.dart';

export 'src/io/reader/reader.dart';
export 'src/io/reader/file_reader.dart';
export 'src/io/reader/string_reader.dart';
export 'src/io/reader/buffered_reader.dart';

export 'src/io/writer/writer.dart';
export 'src/io/writer/file_writer.dart';
export 'src/io/writer/buffered_writer.dart';

export 'src/io/base_stream/base_stream.dart';
export 'src/io/base_stream/double/double_stream.dart';
export 'src/io/base_stream/int/int_stream.dart';
export 'src/io/base_stream/generic/generic_stream.dart';

export 'src/io/print_stream/print_stream.dart';
export 'src/io/print_stream/console_print_stream.dart';

export 'src/io/auto_closeable.dart';
export 'src/io/stream_support.dart';
export 'src/io/stream_builder.dart';
export 'src/io/closeable.dart';
export 'src/io/flushable.dart';

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

export 'src/system/system.dart';
export 'src/system/detector/system_detector.dart';
export 'src/system/detector/standard_system_detector.dart';
export 'src/system/properties/properties.dart';
export 'src/system/properties/system_properties.dart';

export 'src/time/zoned_date_time.dart';
export 'src/time/local_date_time.dart';
export 'src/time/local_date.dart';
export 'src/time/local_time.dart';
export 'src/time/zone_id.dart';

export 'src/thread/thread.dart';
export 'src/thread/local_thread.dart' hide LocalThreadKey;

export 'src/synchronized/synchronized.dart';
export 'src/synchronized/synchronized_lock.dart';

export 'src/comparator/order_comparator.dart';
export 'src/comparator/ordered.dart';

export 'src/commons/optional.dart';
export 'src/commons/string_builder.dart';
export 'src/commons/instance.dart';
export 'src/commons/try_with.dart' hide TryWithAction;
export 'src/commons/regex_utils.dart';
export 'src/commons/typedefs.dart';
export 'src/commons/runnable.dart';
export 'src/commons/throwing_supplier.dart';
export 'src/locale/locale.dart';

export 'src/currency/currency.dart';
export 'src/uuid/uuid.dart';

export 'src/meta/class.dart';
export 'src/meta/class_type.dart';
export 'src/meta/field.dart';
export 'src/meta/constructor.dart';
export 'src/meta/method.dart';
export 'src/meta/parameter.dart';
export 'src/meta/annotation.dart';
export 'src/meta/protection_domain.dart';
export 'src/meta/parameterized_type_reference.dart';
export 'src/meta/resolvable_type.dart';
export 'src/meta/qualified_name.dart';
export 'src/meta/asset_path_resource.dart';
export 'src/meta/class_path_resource.dart';
export 'src/meta/asset_resource.dart';
export 'src/meta/package_identifier.dart';
export 'src/meta/core.dart';

export 'src/declaration/declaration.dart'
  hide PackageImplementation, StandardAnnotationDeclaration,
  StandardAnnotationFieldDeclaration, StandardClassDeclaration,
  StandardConstructorDeclaration, StandardEnumDeclaration, StandardDeclaration,
  StandardExtensionDeclaration, StandardFieldDeclaration, StandardLibraryDeclaration, 
  StandardMethodDeclaration, StandardMixinDeclaration, StandardParameterDeclaration,
  StandardRecordDeclaration, StandardRecordFieldDeclaration, StandardTypeDeclaration,
  StandardTypeVariableDeclaration, StandardTypedefDeclaration, StandardLinkDeclaration;

export 'src/uri/uri_template.dart';
export 'src/uri/uri_validators.dart';
export 'src/uri/uri_validator.dart';

export 'src/utils/method_utils.dart';
export 'src/utils/class_utils.dart';

export 'src/runtime/runtime_provider/standard_runtime_provider.dart';
export 'src/runtime/runtime_provider/configurable_runtime_provider.dart';
export 'src/runtime/runtime_provider/runtime_metadata_provider.dart';
export 'src/runtime/runtime_provider/runtime_provider.dart';
export 'src/runtime/runtime_resolver/runtime_resolver.dart';
export 'src/runtime/runtime_provider/meta_runtime_provider.dart';
export 'src/runtime/class_loader/class_loader.dart';
export 'src/runtime/utils/generic_type_parser.dart';
export 'src/runtime/runtime_hint/runtime_hint.dart';
export 'src/runtime/runtime_hint/runtime_hint_descriptor.dart';
export 'src/runtime/runtime_hint/runtime_hint_processor.dart';
export 'src/runtime/class_loader/default_class_loader.dart';

export 'src/obs/obs.dart';
export 'src/obs/obs_enums.dart';
export 'src/obs/obs_event.dart';
export 'src/obs/obs_types.dart';

export 'src/exceptions.dart';
export 'src/throwable.dart';
export 'src/constant.dart';
export 'src/annotations.dart';