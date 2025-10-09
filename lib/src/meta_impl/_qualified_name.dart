import '../meta/qualified_name.dart';

/// {@template standard_qualified_name}
/// Standard implementation of [QualifiedName] using a string.
///
/// This class provides a simple, efficient way to represent qualified names
/// as strings. It implements the [QualifiedName] interface and provides
/// basic functionality for equality and string representation.
/// {@endtemplate}
class StandardQualifiedName implements QualifiedName {
  final String _qualifiedName;

  /// {@macro standard_qualified_name}
  StandardQualifiedName(this._qualifiedName);

  @override
  String getQualifiedName() => _qualifiedName;

  @override
  List<Object?> equalizedProperties() => [_qualifiedName];

  @override
  String toString() => 'StandardQualifiedName($_qualifiedName)';
}