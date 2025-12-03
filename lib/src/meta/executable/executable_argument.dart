/// {@template executable_argument}
/// Represents the arguments passed to an **executable** (e.g., function, method,
/// or command) in a structured format.
///
/// This abstraction separates **positional** arguments from **named** arguments,
/// allowing consumers to inspect, forward, or manipulate arguments in a
/// generic and type-safe manner.
///
/// ### Responsibilities
/// - Provide access to all positional arguments in order  
/// - Provide access to all named arguments by key  
///
/// ### Example
/// ```dart
/// void execute(ExecutableArgument args) {
///   final first = args.getPositionalArguments()[0];
///   final named = args.getNamedArguments()['option'];
/// }
/// ```
/// {@endtemplate}
abstract interface class ExecutableArgument {
  /// Returns the list of **positional arguments** in the order they were passed.
  ///
  /// The returned list may contain `null` values if arguments are nullable.
  List<Object?> getPositionalArguments();

  /// Returns a map of **named arguments** where:
  /// - The key is the argument name  
  /// - The value is the argument value, possibly `null`
  Map<String, Object?> getNamedArguments();
}