import 'package:jetleaf_lang/lang.dart';

/// {@template qualified_name}
/// Represents an object that can provide a fully qualified name.
///
/// A qualified name is a unique, stable identifier for a type, pod,
/// or configuration element within the JetLeaf framework.
///
/// ### Examples
/// ```dart
/// class MyPod implements QualifiedName {
///   @override
///   String getQualifiedName() =>
///       'package:example/src/my_pod.dart.MyPod';
/// }
///
/// void main() {
///   final pod = MyPod();
///   print(pod.getQualifiedName());
///   // package:example/src/my_pod.dart.MyPod
/// }
/// ```
///
/// ### Usage in the Framework
/// - Pod caches ([PodCache]) use qualified names as keys.
/// - Post-processors may resolve pods by qualified name.
/// - Ensures uniqueness across packages and modules.
/// {@endtemplate}
abstract interface class QualifiedName with EqualsAndHashCode {
  /// {@macro qualified_name}
  const QualifiedName();

  /// {@macro qualified_name}
  String getQualifiedName();
}