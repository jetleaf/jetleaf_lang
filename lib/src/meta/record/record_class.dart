import 'dart:collection';

import 'package:jetleaf_build/jetleaf_build.dart';

import '../class/class.dart';
import '../class/delegating_class.dart';
import '../field/field.dart';
import '../protection_domain/protection_domain.dart';
import 'record_field.dart';

part '_record_class.dart';

/// {@template record_class}
/// Represents a Dart **record type** in the JetLeaf meta-model.
///
/// The `RecordClass` is a **synthetic class** used to model the structure
/// of Dart records `(T1, T2, ...)` or `{name1: T1, name2: T2, ...}`.
/// Unlike typical classes, `RecordClass` instances are **not created** via
/// normal constructors or reflection on user-declared classes. They are
/// generated via meta APIs such as [Parameter] and [Method] to fully
/// describe the shape of parameters, return types, or fields that use
/// records.
///
/// This allows the JetLeaf framework to provide a **complete type model**
/// for:
/// - Parameters typed as records
/// - Methods returning record types
/// - Fields or properties representing records
///
/// Synthetic modeling ensures tools, analyzers, and dependency injection
/// mechanisms can fully inspect record structures.
///
/// ### Example
/// ```dart
/// final method = myClass.getMethod('getUserRecord');
/// final returnType = method.getReturnType();
///
/// if (returnType is RecordClass) {
///   for (final field in returnType.getRecordFields()) {
///     print('Field ${field.getName()} has type ${field.getType().getName()}');
///   }
/// }
/// ```
/// {@endtemplate}
abstract class RecordClass extends DelegatingClass<Record> implements Class<Record> {
  /// Retrieves the record declaration that defines the structure of this record.
  ///
  /// This includes information about each positional or named field, their types,
  /// and any associated metadata.
  RecordLinkDeclaration getRecordDeclaration();

  @override
  Declaration getDeclaration() => getRecordDeclaration();

  /// Returns a list of all fields in this record.
  ///
  /// - Positional fields are listed in order.
  /// - Named fields may appear in any order, but their `RecordField` object
  ///   contains the name for identification.
  List<RecordField> getRecordFields();

  /// Retrieves a single record field by its identifier.
  ///
  /// The [id] can be:
  /// - `int` → for positional fields (zero-based index)
  /// - `String` → for named fields
  ///
  /// Returns the corresponding [RecordField] or `null` if no field matches.
  RecordField? getRecordField(Object id);

  /// Indicates whether the record type is nullable.
  ///
  /// Example:
  /// ```dart
  /// final recordType = method.getReturnType();
  /// if (recordType.getIsNullable()) {
  ///   print('This record may be null at runtime.');
  /// }
  /// ```
  bool getIsNullable();

  /// Links a [RecordLinkDeclaration] to a new `RecordClass` instance.
  ///
  /// This is the **primary factory method** for creating `RecordClass` objects
  /// as part of JetLeaf’s meta-model. Users do not instantiate record classes
  /// directly.
  ///
  /// - [declaration] defines the record structure and metadata.
  /// - [pd] optionally provides the protection domain; defaults to the current domain.
  /// 
  /// {@macro record_class}
  static RecordClass linked(RecordLinkDeclaration declaration, [ProtectionDomain? pd]) {
    return _RecordClass(declaration, pd ?? ProtectionDomain.current());
  }
}