# Thread Module

## Overview

The Thread module provides Java-style threading abstractions on top of Dart's Isolate system. It offers familiar threading constructs like `Thread` and `ThreadLocal` for managing concurrent execution and thread-local storage in a way that will be familiar to Java developers.

## Features

- **Thread Management**: Create and manage threads with Java-like APIs
- **Thread-Local Storage**: Isolate-scoped storage similar to Java's ThreadLocal
- **Message Passing**: Built-in support for thread communication
- **Thread Synchronization**: Utilities for coordinating between threads
- **Debugging Support**: Thread naming and identification

## Core Components

### Thread Class

A `Thread` represents a separate unit of execution, implemented using Dart's `Isolate`. Each `Thread` runs in its own memory space and executes independently.

### ThreadLocal

`ThreadLocal` provides isolate-scoped storage, allowing you to maintain separate values for each thread/isolate. This is particularly useful for request-scoped data in concurrent applications.

## Usage

### Basic Thread Creation

```dart
import 'package:jetleaf_lang/thread.dart';

void entryPoint(ThreadMessage message) {
  print('Thread started with data: ${message.data}');
  // Send a response back to the main thread
  message.replyPort.send('Processing complete');
}

void main() async {
  // Create a new thread
  final thread = Thread(
    entryPoint,
    initialMessage: 'Initial data',
    debugName: 'worker-1'
  );
  
  // Start the thread
  await thread.start();
  
  // Wait for the thread to complete
  await thread.join();
  print('Thread completed');
}
```

### Thread Communication

```dart
void worker(ThreadMessage message) {
  final data = message.data as Map<String, dynamic>;
  final result = processData(data);
  message.replyPort.send(result);
}

void main() async {
  final thread = Thread(worker);
  final port = await thread.start();
  
  // Send data to the thread and wait for response
  final response = await port.sendReceive({'task': 'process', 'value': 42});
  print('Received: $response');
  
  await thread.join();
}
```

### Thread-Local Storage

```dart
final requestId = ThreadLocal<String>();

void handleRequest(String id) {
  // Set thread-local value
  requestId.set(id);
  
  // This value is only visible in the current thread/isolate
  print('Processing request ${requestId.get()}');
  
  // The value is automatically cleaned up when the request is complete
}

void main() async {
  // In main thread
  requestId.set('main');
  
  // In a new thread, the value is different
  final thread = Thread((_) {
    requestId.set('worker');
    print('In thread: ${requestId.get()}'); // 'worker'
  });
  
  await thread.start();
  await thread.join();
  
  print('Back in main: ${requestId.get()}'); // 'main'
}
```

## API Reference

### Thread Class

#### Constructors

- `Thread(Function(ThreadMessage) entryPoint, {dynamic initialMessage, String? debugName})`
  - `entryPoint`: The function to run in the new thread
  - `initialMessage`: Optional initial data to pass to the thread
  - `debugName`: Optional name for debugging purposes

#### Methods

- `Future<SendPort> start()`: Starts the thread
- `Future<void> join({Duration? timeout})`: Waits for the thread to complete
- `void interrupt()`: Interrupts the thread (sets interrupt flag)
- `static void sleep(Duration duration)`: Sleeps the current thread
- `static Thread currentThread()`: Returns the current thread

#### Properties

- `bool get isAlive`: Whether the thread is currently running
- `String get name`: The thread's name
- `bool get isInterrupted`: Whether the thread has been interrupted

### ThreadLocal Class

#### Constructors

- `ThreadLocal()`: Creates a new thread-local variable
- `ThreadLocal.withInitial(T Function() initialValue)`: Creates with initial value factory

#### Methods

- `T? get()`: Gets the current thread's value
- `void set(T? value)`: Sets the current thread's value
- `void remove()`: Removes the current thread's value

## Best Practices

### Thread Management

1. **Resource Cleanup**
   - Always call `join()` or use `try-finally` to ensure threads are properly cleaned up
   - Use `try-finally` blocks in thread entry points to handle errors

2. **Error Handling**
   - Handle errors in thread entry points to prevent silent failures
   - Use message passing to communicate errors back to the main thread

3. **Thread Pools**
   - For high-throughput applications, consider implementing a thread pool
   - Reuse threads instead of creating new ones for each task

### Thread-Local Storage

1. **Initialization**
   - Use `ThreadLocal.withInitial()` for values that should have a default
   - Initialize thread-locals at the library level

2. **Memory Management**
   - Remove thread-local values when they're no longer needed
   - Be cautious with thread-locals in long-lived threads

3. **Testing**
   - Reset thread-local state between tests
   - Consider using a test fixture to manage thread-local state

## Performance Considerations

### Thread Creation

- Creating threads is expensive; prefer reusing threads when possible
- Consider using a thread pool for high-concurrency scenarios
- Be mindful of the memory overhead of each thread/isolate

### Thread-Local Storage

- Accessing thread-locals is very fast (O(1) lookup)
- Each thread-local variable adds a small amount of memory overhead per thread
- Avoid storing large objects in thread-locals for long periods

## Advanced Usage

### Custom Thread Pools

```dart
class ThreadPool {
  final List<Thread> _threads = [];
  final Queue<Function> _taskQueue = Queue();
  final int _maxThreads;
  
  ThreadPool(this._maxThreads);
  
  void execute(Function task) {
    if (_threads.length < _maxThreads) {
      _createThread();
    }
    _taskQueue.add(task);
  }
  
  void _createThread() {
    final thread = Thread(_worker);
    thread.start().then((_) {
      _threads.add(thread);
    });
  }
  
  void _worker(ThreadMessage message) {
    while (true) {
      final task = _taskQueue.removeFirst();
      if (task == null) break; // Sentinel value to stop
      
      try {
        task();
      } catch (e) {
        print('Task failed: $e');
      }
    }
  }
  
  Future<void> shutdown() async {
    // Add sentinel values to stop threads
    for (var _ in _threads) {
      _taskQueue.add(null);
    }
    
    // Wait for all threads to complete
    await Future.wait(_threads.map((t) => t.join()));
  }
}
```

### Thread-Safe Singleton

```dart
class Singleton {
  static final ThreadLocal<Singleton> _instance = 
      ThreadLocal(() => Singleton._internal());
  
  // Private constructor
  Singleton._internal();
  
  // Factory constructor returns the thread-local instance
  factory Singleton() => _instance.get()!;
  
  // Thread-safe instance access
  static Singleton get instance => _instance.get()!;
}
```

## Common Pitfalls

1. **Memory Leaks**
   - Forgetting to remove thread-local values can lead to memory leaks
   - Always clean up thread-locals when they're no longer needed

2. **Deadlocks**
   - Be careful with synchronization between threads
   - Avoid holding locks while making cross-thread calls

3. **Race Conditions**
   - Use proper synchronization when accessing shared state
   - Consider using message passing instead of shared memory

## See Also

- [Dart Isolates](https://dart.dev/guides/language/concurrency)
- [Java Thread Documentation](https://docs.oracle.com/javase/8/docs/api/java/lang/Thread.html)
- [Java ThreadLocal Documentation](https://docs.oracle.com/javase/8/docs/api/java/lang/ThreadLocal.html)
