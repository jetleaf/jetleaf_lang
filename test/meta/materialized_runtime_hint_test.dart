// ignore_for_file: deprecated_member_use_from_same_package

import 'package:jetleaf_build/jetleaf_build.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:test/test.dart';

// ========================================================================
// TEST DATA CLASSES
// ========================================================================

class BusinessService {
  void processOrder(String orderId, double amount) {
    print('Processing order $orderId for amount \$$amount');
  }
  
  String generateReport(DateTime date) {
    return 'Report for ${date.toIso8601String()}';
  }
}

class MonitoringMaterializedHint extends MaterializedRuntimeHint<BusinessService> {
  final List<String> _log = [];
  
  MonitoringMaterializedHint();
  
  List<String> get logs => List.unmodifiable(_log);
  
  @override
  Hint invokeMethod<T>(T instance, String methodName, ExecutableArgument argument) {
    if (instance is BusinessService) {
      final timestamp = DateTime.now().toIso8601String();
      
      if (methodName == 'processOrder') {
        final orderId = argument.getPositionalArguments()[0] as String;
        final amount = argument.getPositionalArguments()[1] as double;
        
        _log.add('[$timestamp] processOrder called: orderId=$orderId, amount=$amount');
      }
      
      if (methodName == 'generateReport') {
        final date = argument.getPositionalArguments()[0] as DateTime;
        _log.add('[$timestamp] generateReport called: date=${date.toIso8601String()}');
      }
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
}

class RegistrationData {
  final String email;
  final String password;
  
  RegistrationData(this.email, this.password);
}

class ValidationMaterializedHint extends MaterializedRuntimeHint<RegistrationData> {
  const ValidationMaterializedHint();
  
  @override
  Hint createNewInstance<T>(String constructorName, ExecutableArgument argument) {
    if (constructorName == 'RegistrationData') {
      final positional = argument.getPositionalArguments();
      final email = positional[0] as String;
      final password = positional[1] as String;
      
      // Validate before creating
      if (!email.contains('@')) {
        throw ArgumentError('Invalid email format');
      }
      
      if (password.length < 8) {
        throw ArgumentError('Password must be at least 8 characters');
      }
      
      return Hint.executed(RegistrationData(email, password));
    }
    
    return super.createNewInstance(constructorName, argument);
  }
  
  @override
  Hint getFieldValue<T>(T instance, String fieldName) {
    if (instance is RegistrationData) {
      if (fieldName == 'password') {
        // Never return actual password
        return Hint.executed('********');
      }
    }
    
    return super.getFieldValue(instance, fieldName);
  }
}

class ExpensiveService {
  String _expensiveCalculation() {
    // Simulate expensive operation
    return DateTime.now().toIso8601String();
  }
  
  String get cachedResult {
    print('Performing expensive calculation...');
    return _expensiveCalculation();
  }
}

class CachingMaterializedHint extends MaterializedRuntimeHint<ExpensiveService> {
  String? _cache;
  
  CachingMaterializedHint();
  
  @override
  Hint invokeMethod<T>(T instance, String methodName, ExecutableArgument argument) {
    if (instance is ExpensiveService && methodName == 'cachedResult') {
      // Cache the result
      if (_cache == null) {
        print('Cache miss - calculating...');
        _cache = instance.cachedResult;
      } else {
        print('Cache hit!');
      }
      
      return Hint.executed(_cache!);
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
}

class PremiumProduct extends Product {
  final String tier;
  
  PremiumProduct(super.id, super.name, super.price, this.tier);
  
  String get premiumDetails => '$name - $tier Tier';
}

class PremiumProductMaterializedHint extends MaterializedRuntimeHint<PremiumProduct> {
  const PremiumProductMaterializedHint();
  
  @override
  Hint getFieldValue<T>(T instance, String fieldName) {
    if (instance is PremiumProduct && fieldName == 'tier') {
      // Always return uppercase tier
      return Hint.executed(instance.tier.toUpperCase());
    }
    
    return super.getFieldValue(instance, fieldName);
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  
  Product(this.id, this.name, this.price);
  
  factory Product.discounted(String id, String name, double price, double discount) {
    return Product(id, name, price * (1 - discount));
  }
  
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  
  void applyDiscount(double discount) {
    // Note: In real code, you'd create a new instance since fields are final
    print('Discount of ${discount * 100}% applied to $name');
  }
  
  static Product createSample() {
    return Product('sample', 'Sample Product', 99.99);
  }
  
  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}

class User {
  final String username;
  final String email;
  bool isActive;
  
  User(this.username, this.email, {this.isActive = true});
  
  String get profileSummary => '$username ($email) - ${isActive ? "Active" : "Inactive"}';
  
  void activate() {
    isActive = true;
  }
  
  void deactivate() {
    isActive = false;
  }
  
  @override
  String toString() => 'User(username: $username, email: $email, isActive: $isActive)';
}

class Order {
  final String orderId;
  final User user;
  final List<Product> products;
  final DateTime createdAt;
  
  Order(this.orderId, this.user, this.products) : createdAt = DateTime.now();
  
  double get totalAmount => products.fold(0.0, (sum, product) => sum + product.price);
  
  String get summary => 'Order #$orderId for ${user.username}: \$${totalAmount.toStringAsFixed(2)}';
  
  void addProduct(Product product) {
    // Note: In real code, you'd create a new list since products is final
    print('Adding product: ${product.name}');
  }
  
  static Order createTestOrder() {
    final user = User('test_user', 'test@example.com');
    final products = [
      Product('p1', 'Product 1', 19.99),
      Product('p2', 'Product 2', 29.99),
    ];
    return Order('test-123', user, products);
  }
}

// ========================================================================
// MATERIALIZED RUNTIME HINT IMPLEMENTATIONS
// ========================================================================

/// Basic MaterializedRuntimeHint for Product
class ProductMaterializedHint extends MaterializedRuntimeHint<Product> {
  const ProductMaterializedHint();
  
  @override
  Hint createNewInstance<T>(String constructorName, ExecutableArgument argument) {
    print('ProductMaterializedHint.createNewInstance: $constructorName');
    
    if (constructorName == 'Product.discounted') {
      final positional = argument.getPositionalArguments();
      final id = positional[0] as String;
      final name = positional[1] as String;
      final price = positional[2] as double;
      final discount = positional[3] as double;
      
      // Apply 10% extra discount as a hint behavior
      final extraDiscount = discount + 0.1;
      final finalPrice = price * (1 - extraDiscount);
      
      return Hint.executed(Product(id, name, finalPrice));
    }
    
    if (constructorName == 'Product.createSample') {
      // Override the sample product
      return Hint.executed(Product('hinted-sample', 'Hinted Sample', 49.99));
    }

    if (constructorName == "Product") {
      final positional = argument.getPositionalArguments();
      final id = positional[0] as String;
      final name = positional[1] as String;
      final price = positional[2] as double;
      
      return Hint.executed(Product(id, name, price));
    }
    
    return super.createNewInstance(constructorName, argument);
  }
  
  @override
  Hint invokeMethod<T>(T instance, String methodName, ExecutableArgument argument) {
    print('ProductMaterializedHint.invokeMethod: $methodName');
    
    if (instance case Product instance) {
      if (methodName == 'formattedPrice') {
        // Add currency symbol customization
        return Hint.executed('USD ${instance.price.toStringAsFixed(2)}');
      }
      
      if (methodName == 'applyDiscount') {
        final discount = argument.getPositionalArguments().first as double;
        instance.applyDiscount(discount);
        print('Custom discount logic applied: ${discount * 100}%');
        return Hint.executedWithoutResult();
      }
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
  
  @override
  Hint getFieldValue<T>(T instance, String fieldName) {
    if (instance is Product) {
      if (fieldName == 'price') {
        // Apply a 5% markup when price is accessed
        final markedUpPrice = instance.price * 1.05;
        return Hint.executed(markedUpPrice);
      }
      
      if (fieldName == 'name') {
        // Add a prefix to product names
        return Hint.executed('[Featured] ${instance.name}');
      }
    }
    
    return super.getFieldValue(instance, fieldName);
  }
  
  @override
  Hint setFieldValue<T>(T instance, String fieldName, Object? value) {
    print('ProductMaterializedHint.setFieldValue: $fieldName = $value');
    
    // Products are immutable, so we can't actually set fields
    // But we can log the attempt
    if (instance is Product) {
      print('Attempt to modify immutable Product: $fieldName -> $value');
    }
    
    return super.setFieldValue(instance, fieldName, value);
  }
}

/// MaterializedRuntimeHint for User with enhanced behavior
class UserMaterializedHint extends MaterializedRuntimeHint<User> {
  final bool logActivity;
  
  const UserMaterializedHint({this.logActivity = false});
  
  @override
  Hint createNewInstance<T>(String constructorName, ExecutableArgument argument) {
    if (logActivity) {
      print('Creating User instance via hint');
    }
    
    return super.createNewInstance(constructorName, argument);
  }
  
  @override
  Hint invokeMethod<T>(T instance, String methodName, ExecutableArgument argument) {
    if (instance is User) {
      if (methodName == 'profileSummary') {
        // Enhanced profile summary
        final original = instance.profileSummary;
        final status = instance.isActive ? '🟢 Active' : '🔴 Inactive';
        return Hint.executed('$original - Status: $status');
      }
      
      if (methodName == 'activate' || methodName == 'deactivate') {
        if (logActivity) {
          print('User ${instance.username} status change: $methodName');
        }
        
        // Add audit logging
        final timestamp = DateTime.now().toIso8601String();
        print('Audit: User ${instance.username} $methodName at $timestamp');
        
        return super.invokeMethod(instance, methodName, argument);
      }
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
  
  @override
  Hint getFieldValue<T>(T instance, String fieldName) {
    if (instance is User) {
      if (fieldName == 'email') {
        // Mask email for privacy
        final email = instance.email;
        final parts = email.split('@');
        if (parts.length == 2) {
          final maskedLocal = parts[0].length > 2 
            ? '${parts[0].substring(0, 2)}***'
            : '***';
          final maskedEmail = '$maskedLocal@${parts[1]}';
          return Hint.executed(maskedEmail);
        }
      }
    }
    
    return super.getFieldValue(instance, fieldName);
  }
  
  @override
  List<Object?> equalizedProperties() => [super.equalizedProperties(), logActivity];
}

/// MaterializedRuntimeHint for Order with transaction tracking
class OrderMaterializedHint extends MaterializedRuntimeHint<Order> {
  final String transactionPrefix;
  
  const OrderMaterializedHint({this.transactionPrefix = 'TRX-'});
  
  @override
  Hint createNewInstance<T>(String constructorName, ExecutableArgument argument) {
    if (constructorName == 'Order.createTestOrder') {
      // Custom test order creation
      final user = User('hint_user', 'hint@example.com');
      final products = [
        Product('hp1', 'Hinted Product 1', 9.99),
        Product('hp2', 'Hinted Product 2', 14.99),
      ];
      final orderId = '$transactionPrefix${DateTime.now().millisecondsSinceEpoch}';
      return Hint.executed(Order(orderId, user, products));
    }
    
    return super.createNewInstance(constructorName, argument);
  }
  
  @override
  Hint invokeMethod<T>(T instance, String methodName, ExecutableArgument argument) {
    if (instance is Order) {
      if (methodName == 'totalAmount') {
        // Add tax calculation
        final subtotal = instance.products.fold(0.0, (sum, product) => sum + product.price);
        final tax = subtotal * 0.08; // 8% tax
        return Hint.executed(subtotal + tax);
      }
      
      if (methodName == 'summary') {
        final original = instance.summary;
        final itemCount = instance.products.length;
        return Hint.executed('$original ($itemCount items)');
      }
      
      if (methodName == 'addProduct') {
        final product = argument.getPositionalArguments().first as Product;
        print('OrderMaterializedHint: Adding ${product.name} to order ${instance.orderId}');
        
        // Validate product before adding
        if (product.price <= 0) {
          throw ArgumentError('Product price must be positive');
        }
        
        return super.invokeMethod(instance, methodName, argument);
      }
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
  
  @override
  Hint getFieldValue<T>(T instance, String fieldName) {
    if (instance is Order) {
      if (fieldName == 'createdAt') {
        // Format date nicely
        return Hint.executed(instance.createdAt.toLocal().toString());
      }
      
      if (fieldName == 'products') {
        // Return immutable copy
        return Hint.executed(List<Product>.from(instance.products));
      }
    }
    
    return super.getFieldValue(instance, fieldName);
  }
  
  @override
  List<Object?> equalizedProperties() => [super.equalizedProperties(), transactionPrefix];
}

/// Complex hint that uses Class API internally
class ReflectiveMaterializedHint extends MaterializedRuntimeHint<Object> {
  const ReflectiveMaterializedHint();
  
  @override
  Hint createNewInstance<T>(String constructorName, ExecutableArgument argument) {
    // Use Class API to inspect the type
    final classApi = toClass();
    final className = classApi.getSimpleName();
    
    print('ReflectiveMaterializedHint: Creating $className with constructor $constructorName');
    
    // Get constructors to see what's available
    final constructors = classApi.getConstructors();
    if (constructors.any((c) => c.getName() == constructorName)) {
      print('Constructor $constructorName found for $className');
    }
    
    return super.createNewInstance(constructorName, argument);
  }
  
  @override
  Hint invokeMethod<T>(T instance, String methodName, ExecutableArgument argument) {
    // Use Class API to inspect the instance
    final instanceClass = Class.forType(instance);
    final methods = instanceClass.getMethods();
    
    final targetMethod = methods.firstWhereOrNull((m) => m.getName() == methodName);
    if (targetMethod != null) {
      print('ReflectiveMaterializedHint: Invoking $methodName on ${instanceClass.getSimpleName()}');
      
      if (targetMethod.isAsync()) {
        print('  ↳ Method is asynchronous');
      }
      
      if (targetMethod.isVoid()) {
        print('  ↳ Method returns void');
      }
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
}

/// Materialized hint that works with generic collections
class ListMaterializedHint<T> extends MaterializedRuntimeHint<List<T>> {
  const ListMaterializedHint();
  
  @override
  Hint createNewInstance<U>(String constructorName, ExecutableArgument argument) {
    if (constructorName == 'List.none') {
      // Create a pre-populated list
      return Hint.executed(<T>[]);
    }
    
    if (constructorName == 'List.filled') {
      final positional = argument.getPositionalArguments();
      final length = positional[0] as int;
      final fillValue = positional[1] as T;
      
      // Create list with extra capacity
      return Hint.executed(List<T>.filled(length + 10, fillValue));
    }
    
    return super.createNewInstance(constructorName, argument);
  }
  
  @override
  Hint invokeMethod<U>(U instance, String methodName, ExecutableArgument argument) {
    if (instance is List<T>) {
      if (methodName == 'add') {
        final element = argument.getPositionalArguments().first as T;
        print('ListMaterializedHint: Adding $element to list of ${T.toString()}');
        
        // Validate before adding
        if (element == null) {
          throw ArgumentError('Cannot add null to list');
        }
        
        return super.invokeMethod(instance, methodName, argument);
      }
      
      if (methodName == 'length') {
        // Always return at least 1 for non-none lists
        return Hint.executed(instance.isEmpty ? 0 : instance.length + 1);
      }
    }
    
    return super.invokeMethod(instance, methodName, argument);
  }
}

// ========================================================================
// ANNOTATION-BASED MATERIALIZED HINTS
// ========================================================================

/// Annotation that is a MaterializedRuntimeHint
@Deprecated('Use NewProductHint instead')
class ProductMaterializedHintAnnotation extends MaterializedRuntimeHint<Product> {
  final String source;
  
  const ProductMaterializedHintAnnotation({this.source = 'annotation'});
  
  @override
  Hint getFieldValue<T>(T instance, String fieldName) {
    if (instance is Product && fieldName == 'id') {
      // Add source prefix to IDs
      return Hint.executed('$source-${instance.id}');
    }
    
    return super.getFieldValue(instance, fieldName);
  }
  
  @override
  List<Object?> equalizedProperties() => [super.equalizedProperties(), source];
}

/// Class annotated with MaterializedRuntimeHint
@ProductMaterializedHintAnnotation(source: 'annotated-class')
class AnnotatedProduct extends Product {
  AnnotatedProduct(super.id, super.name, super.price);
}

// ========================================================================
// TESTS
// ========================================================================

void main() {
  setUpAll(() async {
    await runTestScan();
  });
  
  group('MaterializedRuntimeHint Basic Tests', () {
    test('toClass() returns Class instance', () {
      final hint = ProductMaterializedHint();
      final classApi = hint.toClass();
      
      expect(classApi, isA<Class<Product>>());
      expect(classApi.getSimpleName(), 'Product');
      expect(classApi.isClass(), isTrue);
    });
    
    test('obtainTypeOfRuntimeHint() returns original type', () {
      final hint = ProductMaterializedHint();
      final type = hint.obtainTypeOfRuntimeHint();
      
      expect(type, Product);
    });
    
    test('Materialized hint provides Class metadata', () {
      final hint = UserMaterializedHint();
      final classApi = hint.toClass();
      
      // Test Class API integration
      expect(classApi.getFields().any((f) => f.getName() == 'username'), isTrue);
      expect(classApi.getFields().any((f) => f.getName() == 'email'), isTrue);
      expect(classApi.getFields().any((f) => f.getName() == 'isActive'), isTrue);
      
      expect(classApi.getMethods().any((m) => m.getName() == 'profileSummary'), isTrue);
      expect(classApi.getMethods().any((m) => m.getName() == 'activate'), isTrue);
    });
    
    test('Equality based on properties', () {
      final hint1 = ProductMaterializedHint();
      final hint2 = ProductMaterializedHint();
      final hint3 = UserMaterializedHint();
      
      expect(hint1.equalizedProperties(), equals(hint2.equalizedProperties()));
      expect(hint1, equals(hint2));
      expect(hint1 == hint2, isTrue);
      expect(hint1, isNot(equals(hint3)));
    });
  });
  
  group('MaterializedRuntimeHint with Class API Integration', () {
    test('Can use Class API within hint implementation', () {
      final hint = ReflectiveMaterializedHint();
      final classApi = hint.toClass();
      
      // Verify Class API is functional
      expect(classApi.getSimpleName(), 'Object');
      expect(classApi.isInstance(Product('1', 'Test', 9.99)), isTrue);
      expect(classApi.isInstance('string'), isTrue);
      expect(classApi.isInstance(123), isTrue);
    });
    
    test('Materialized hint can inspect constructors', () {
      final hint = ProductMaterializedHint();
      final classApi = hint.toClass();
      final constructors = classApi.getConstructors();
      
      expect(constructors.length, greaterThanOrEqualTo(2));
      expect(constructors.any((c) => c.getName().isEmpty), isTrue); // Default
      expect(constructors.any((c) => c.getName() == 'discounted'), isTrue);
    });
    
    test('Materialized hint can inspect methods', () {
      final hint = ProductMaterializedHint();
      final classApi = hint.toClass();
      final methods = classApi.getMethods();
      
      expect(methods.any((m) => m.getName() == 'formattedPrice'), isTrue);
      expect(methods.any((m) => m.getName() == 'applyDiscount'), isTrue);
      expect(methods.any((m) => m.getName() == 'toString'), isTrue);
    });
    
    test('Materialized hint can inspect fields', () {
      final hint = ProductMaterializedHint();
      final classApi = hint.toClass();
      final fields = classApi.getFields();
      
      expect(fields.any((f) => f.getName() == 'id'), isTrue);
      expect(fields.any((f) => f.getName() == 'name'), isTrue);
      expect(fields.any((f) => f.getName() == 'price'), isTrue);
    });
  });
  
  group('MaterializedRuntimeHint Execution Tests', () {
    test('createNewInstance intercepts constructor calls', () {
      final hint = ProductMaterializedHint();
      
      // Test default constructor
      final argument = ExecutableArgument.unmodified({}, ['test-id', 'Test Product', 100.0]);
      
      final hintResult = hint.createNewInstance<Product>('Product', argument);
      expect(hintResult.getIsExecuted(), isTrue);
      
      // Test factory constructor with custom behavior
      final discountArgument = ExecutableArgument.unmodified({}, ['discount-id', 'Discounted Product', 100.0, 0.2]);
      
      final discountResult = hint.createNewInstance<Product>('Product.discounted', discountArgument);
      expect(discountResult.getIsExecuted(), isTrue);
      
      if (discountResult.getIsExecuted()) {
        final product = discountResult.getResult() as Product;
        // Should have 30% discount total (20% + 10% extra from hint)
        expect(product.price, closeTo(70.0, 0.01));
      }
    });
    
    test('invokeMethod intercepts method calls', () {
      final hint = ProductMaterializedHint();
      final product = Product('test', 'Test Product', 99.99);
      
      // Test getter interception
      final formattedPriceHint = hint.invokeMethod(product, 'formattedPrice', ExecutableArgument.none());
      expect(formattedPriceHint.getIsExecuted(), isTrue);
      
      if (formattedPriceHint.getIsExecuted()) {
        expect(formattedPriceHint.getResult(), 'USD 99.99');
      }
      
      // Test void method interception
      final discountArgument = ExecutableArgument.unmodified({}, [0.1]);
      
      final discountHint = hint.invokeMethod(product, 'applyDiscount', discountArgument);
      expect(discountHint.getIsExecuted(), isTrue);
    });
    
    test('getFieldValue intercepts field access', () {
      final hint = ProductMaterializedHint();
      final product = Product('test', 'Test Product', 100.0);
      
      // Test price field with markup
      final priceHint = hint.getFieldValue(product, 'price');
      expect(priceHint.getIsExecuted(), isTrue);
      
      if (priceHint.getIsExecuted()) {
        // Should have 5% markup
        expect(priceHint.getResult(), closeTo(105.0, 0.01));
      }
      
      // Test name field with prefix
      final nameHint = hint.getFieldValue(product, 'name');
      expect(nameHint.getIsExecuted(), isTrue);
      
      if (nameHint.getIsExecuted()) {
        expect(nameHint.getResult(), '[Featured] Test Product');
      }
    });
    
    test('UserMaterializedHint provides enhanced behavior', () {
      final hint = UserMaterializedHint(logActivity: true);
      final user = User('john_doe', 'john@example.com', isActive: false);
      
      // Test enhanced profile summary
      final profileHint = hint.invokeMethod(user, 'profileSummary', ExecutableArgument.none());
      expect(profileHint.getIsExecuted(), isTrue);
      
      if (profileHint.getIsExecuted()) {
        expect(profileHint.getResult(), contains('🔴 Inactive'));
      }
      
      // Test email masking
      final emailHint = hint.getFieldValue(user, 'email');
      expect(emailHint.getIsExecuted(), isTrue);
      
      if (emailHint.getIsExecuted()) {
        expect(emailHint.getResult(), contains('***'));
      }
    });
    
    test('OrderMaterializedHint with transaction tracking', () {
      final hint = OrderMaterializedHint(transactionPrefix: 'TEST-');
      
      // Test custom test order creation
      final testOrderArgument = ExecutableArgument.none();
      final hintResult = hint.createNewInstance<Order>('Order.createTestOrder', testOrderArgument);
      expect(hintResult.getIsExecuted(), isTrue);
      
      if (hintResult.getIsExecuted()) {
        final order = hintResult.getResult() as Order;
        expect(order.orderId, startsWith('TEST-'));
        expect(order.user.username, 'hint_user');
        expect(order.products.length, 2);
      }
      
      // Test total amount with tax
      final order = Order('123', User('test', 'test@example.com'), [
        Product('p1', 'Product 1', 10.0),
        Product('p2', 'Product 2', 20.0),
      ]);
      
      final totalHint = hint.invokeMethod(order, 'totalAmount', ExecutableArgument.none());
      expect(totalHint.getIsExecuted(), isTrue);
      
      if (totalHint.getIsExecuted()) {
        // 30 subtotal + 8% tax = 32.40
        expect(totalHint.getResult(), closeTo(32.40, 0.01));
      }
    });
  });
  
  group('Generic MaterializedRuntimeHint Tests', () {
    test('ListMaterializedHint works with generic types', () {
      final hint = ListMaterializedHint<String>();
      final classApi = hint.toClass();
      
      expect(classApi.getSimpleName(), 'List<String>');
      expect(classApi.hasGenerics(), isTrue);
      
      // Test createNewInstance with List.filled
      final filledArgument = ExecutableArgument.unmodified({}, [3, 'default']);
      
      final hintResult = hint.createNewInstance<List<String>>('List.filled', filledArgument);
      expect(hintResult.getIsExecuted(), isTrue);
      
      if (hintResult.getIsExecuted()) {
        final list = hintResult.getResult() as List<String>;
        // Should have extra capacity (3 + 10)
        expect(list.length, 13);
      }
      
      // Test method interception
      final list = <String>['a', 'b'];
      final lengthHint = hint.invokeMethod(list, 'length', ExecutableArgument.none());
      expect(lengthHint.getIsExecuted(), isTrue);
      
      if (lengthHint.getIsExecuted()) {
        // Should return length + 1 for non-none lists
        expect(lengthHint.getResult(), 3);
      }
    });
    
    test('Materialized hint can handle different generic instantiations', () {
      final stringListHint = ListMaterializedHint<String>();
      final intListHint = ListMaterializedHint<int>();
      
      expect(stringListHint.toClass().componentType<String>()!.getSimpleName(), 'String');
      expect(intListHint.toClass().componentType<int>()!.getSimpleName(), 'int');
    });
  });
  
  group('MaterializedRuntimeHint with Annotations', () {
    test('Annotation-based materialized hint works', () {
      final hint = ProductMaterializedHintAnnotation(source: 'test');
      final product = Product('123', 'Test', 50.0);
      
      // Test field interception
      final idHint = hint.getFieldValue(product, 'id');
      expect(idHint.getIsExecuted(), isTrue);
      
      if (idHint.getIsExecuted()) {
        expect(idHint.getResult(), 'test-123');
      }
      
      // Verify Class API still works
      final classApi = hint.toClass();
      expect(classApi.getSimpleName(), 'Product');
    });
    
    test('Class annotated with MaterializedRuntimeHint', () {
      final annotatedProductClass = Class<AnnotatedProduct>();
      
      // Should have the annotation
      final annotations = annotatedProductClass.getAllAnnotations();
      expect(annotations.any((a) => a.getInstance() is ProductMaterializedHintAnnotation), isTrue);
      
      // Can still use Class API
      expect(annotatedProductClass.getSimpleName(), 'AnnotatedProduct');
      expect(annotatedProductClass.getSuperClass<Product>(), isNotNull);
    });
  });
  
  group('MaterializedRuntimeHint Integration with Reflection', () {
    test('Can be discovered through reflection', () {
      final hintClasses = Class<MaterializedRuntimeHint>().getSubClasses();
      
      expect(hintClasses.length, greaterThanOrEqualTo(4));
      
      // Verify specific hint classes are found
      final classNames = hintClasses.map((c) => c.getName()).toList();
      expect(classNames, contains('ProductMaterializedHint'));
      expect(classNames, contains('UserMaterializedHint'));
      expect(classNames, contains('OrderMaterializedHint'));
      expect(classNames, contains('ReflectiveMaterializedHint'));
    });
    
    test('Materialized hints can be instantiated via reflection', () {
      final productHintClass = Runtime.getAllClasses().firstWhere((c) => c.getName() == 'ProductMaterializedHint');
      
      // Create instance via reflection
      final hintInstance = productHintClass.newInstance({});
      expect(hintInstance, isA<ProductMaterializedHint>());
      
      final hint = hintInstance as ProductMaterializedHint;
      
      // Verify it works
      final classApi = hint.toClass();
      expect(classApi.getSimpleName(), 'Product');
      
      // Test hint functionality
      final product = Product('test', 'Test', 100.0);
      final priceHint = hint.getFieldValue(product, 'price');
      expect(priceHint.getIsExecuted(), isTrue);
    });
    
    test('Integration with RuntimeHintDescriptor', () {
      final descriptor = DefaultRuntimeHintDescriptor();
      
      // Add materialized hints
      descriptor.addHint(const ProductMaterializedHint());
      descriptor.addHint(const UserMaterializedHint());
      descriptor.addHint(const OrderMaterializedHint());
      
      // Retrieve hints
      final productHint = descriptor.getHint<Product>();
      expect(productHint, isNotNull);
      expect(productHint, isA<MaterializedRuntimeHint<Product>>());
      
      final userHint = descriptor.getHint<User>();
      expect(userHint, isNotNull);
      expect(userHint, isA<MaterializedRuntimeHint<User>>());
      
      // Verify Class API integration
      if (productHint is MaterializedRuntimeHint<Product>) {
        final classApi = productHint.toClass();
        expect(classApi.getMethods().any((m) => m.getName() == 'formattedPrice'), isTrue);
      }
      
      // Test hint execution
      if (productHint != null) {
        final product = Product('test', 'Test', 50.0);
        final priceHintResult = productHint.getFieldValue(product, 'price');
        expect(priceHintResult.getIsExecuted(), isTrue);
      }
    });
    
    test('Materialized hints work with ClassDeclaration APIs', () {
      final productClass = Runtime.getAllClasses()
          .firstWhere((c) => c.getName() == 'Product');
      
      // Get fields through ClassDeclaration
      final fields = productClass.getFields();
      expect(fields.length, greaterThanOrEqualTo(3));
      
      // Get methods through ClassDeclaration
      final methods = productClass.getMethods();
      expect(methods.length, greaterThanOrEqualTo(3));
      
      // Create instance through ClassDeclaration
      final instance = productClass.newInstance({
        'id': 'reflection-id',
        'name': 'Reflection Product',
        'price': 75.0,
      });
      expect(instance, isA<Product>());
      
      final product = instance as Product;
      expect(product.id, 'reflection-id');
      expect(product.name, 'Reflection Product');
      expect(product.price, 75.0);
    });
    
    test('Round-trip: Class -> MaterializedRuntimeHint -> Class', () {
      // Start with a Class
      final originalClass = Class<Product>();
      
      // Create a MaterializedRuntimeHint from it
      final hint = ProductMaterializedHint();
      
      // Get Class back from hint
      final hintClass = hint.toClass();
      
      // Should be equivalent
      expect(hintClass.getSimpleName(), originalClass.getSimpleName());
      expect(hintClass.getType(), originalClass.getType());
      
      // Both should have same methods
      final originalMethods = originalClass.getMethods().map((m) => m.getName()).toList();
      final hintMethods = hintClass.getMethods().map((m) => m.getName()).toList();
      
      expect(hintMethods, containsAll(originalMethods));
      
      // Test that hint-modified behavior still works with Class API
      final product = Product('test', 'Test', 100.0);
      
      // Get price field through Class API
      final priceField = originalClass.getField('price');
      expect(priceField, isNotNull);
      
      // Normal field access
      final normalPrice = priceField!.getValue(product);
      expect(normalPrice, 100.0);
      
      // Hint-modified field access
      final hintPriceResult = hint.getFieldValue(product, 'price');
      expect(hintPriceResult.getIsExecuted(), isTrue);
      
      if (hintPriceResult.getIsExecuted()) {
        expect(hintPriceResult.getResult(), closeTo(105.0, 0.01)); // 5% markup
      }
    });
  });
  
  group('MaterializedRuntimeHint Edge Cases', () {
    test('Handles null instances gracefully', () {
      final hint = ProductMaterializedHint();
      
      // Should handle null instance
      final nullHint = hint.getFieldValue(null, 'price');
      expect(nullHint.getIsExecuted(), isFalse);
    });
    
    test('Works with inheritance', () {      
      final hint = PremiumProductMaterializedHint();
      final product = PremiumProduct('p1', 'Premium', 199.99, 'gold');
      
      final tierHint = hint.getFieldValue(product, 'tier');
      expect(tierHint.getIsExecuted(), isTrue);
      
      if (tierHint.getIsExecuted()) {
        expect(tierHint.getResult(), 'GOLD');
      }
      
      // Should still work with parent class methods
      final priceHint = hint.getFieldValue(product, 'price');
      expect(priceHint.getIsExecuted(), isFalse);
    });
    
    test('Handles type mismatches', () {
      final hint = ProductMaterializedHint();
      final wrongInstance = User('test', 'test@example.com');
      
      // Should handle type mismatch gracefully
      final mismatchHint = hint.getFieldValue(wrongInstance, 'price');
      expect(mismatchHint.getIsExecuted(), isFalse);
    });
    
    test('Custom equalizedProperties', () {
      final hint1 = UserMaterializedHint(logActivity: true);
      final hint2 = UserMaterializedHint(logActivity: true);
      final hint3 = UserMaterializedHint(logActivity: false);
      
      expect(hint1, equals(hint2));
      expect(hint1, isNot(equals(hint3)));
      
      final orderHint1 = OrderMaterializedHint(transactionPrefix: 'A');
      final orderHint2 = OrderMaterializedHint(transactionPrefix: 'A');
      final orderHint3 = OrderMaterializedHint(transactionPrefix: 'B');
      
      expect(orderHint1, equals(orderHint2));
      expect(orderHint1, isNot(equals(orderHint3)));
    });
  });
  
  group('Performance and Real-world Scenarios', () {
    test('Materialized hint for caching expensive operations', () {      
      final hint = CachingMaterializedHint();
      final service = ExpensiveService();
      
      // First call should calculate
      final result1 = hint.invokeMethod(service, 'cachedResult', ExecutableArgument.none());
      expect(result1.getIsExecuted(), isTrue);
      
      // Second call should use cache
      final result2 = hint.invokeMethod(service, 'cachedResult', ExecutableArgument.none());
      expect(result2.getIsExecuted(), isTrue);
      
      if (result1.getIsExecuted() && result2.getIsExecuted()) {
        expect(result1.getResult(), equals(result2.getResult()));
      }
    });
    
    test('Materialized hint for validation', () {      
      final hint = ValidationMaterializedHint();
      
      // Valid data should work
      final validArgument = ExecutableArgument.unmodified({}, ['user@example.com', 'securepassword123']);
      
      final validHint = hint.createNewInstance<RegistrationData>('RegistrationData', validArgument);
      expect(validHint.getIsExecuted(), isTrue);
      
      // Invalid email should throw
      final invalidEmailArgument = ExecutableArgument.unmodified({}, ['invalid-email', 'password123']);
      
      expect(
        () => hint.createNewInstance<RegistrationData>('RegistrationData', invalidEmailArgument),
        throwsArgumentError,
      );
    });
    
    test('Materialized hint for logging and monitoring', () {      
      final hint = MonitoringMaterializedHint();
      final service = BusinessService();
      
      // Call methods
      hint.invokeMethod(service, 'processOrder', ExecutableArgument.unmodified({}, ['ORD-123', 99.99]));
      
      hint.invokeMethod(service, 'generateReport', ExecutableArgument.unmodified({}, [DateTime.now()]));
      
      // Check logs
      expect(hint.logs.length, 2);
      expect(hint.logs[0], contains('processOrder'));
      expect(hint.logs[1], contains('generateReport'));
    });
  });
}