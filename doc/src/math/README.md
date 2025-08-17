# Math Module

## Overview

The Math module provides arbitrary-precision arithmetic classes for working with very large numbers and precise decimal calculations. These classes are essential for applications requiring high precision arithmetic, such as financial calculations, cryptography, and scientific computing.

## Features

- **Arbitrary Precision**: Handle numbers of any size limited only by available memory
- **Decimal Arithmetic**: Precise decimal calculations without floating-point rounding errors
- **Java-like API**: Familiar interface for developers coming from Java
- **Immutable Objects**: Thread-safe by design
- **Comprehensive Operations**: Support for all standard arithmetic and comparison operations

## Core Components

### BigInteger

An immutable arbitrary-precision integer that provides operations for modular arithmetic, GCD calculation, primality testing, and bit manipulation.

### BigDecimal

An immutable, arbitrary-precision signed decimal number that provides operations for arithmetic, scale manipulation, rounding, comparison, and format conversion.

## Usage

### Working with BigInteger

```dart
import 'package:jetleaf_lang/math.dart';

// Create BigIntegers from strings, integers, or BigInts
final a = BigInteger('123456789012345678901234567890');
final b = BigInteger.fromInt(42);
final c = BigInteger.fromBigInt(BigInt.parse('9876543210'));

// Arithmetic operations
final sum = a + b;
final product = a * c;
final quotient = a ~/ b;
final remainder = a % b;

// Comparison
print(a > b);  // true
print(a == BigInteger.one);  // false

// Mathematical operations
final gcd = a.gcd(b);
final modPow = a.modPow(b, c);
final isPrime = a.isProbablePrime(100);  // 100 is certainty parameter
```

### Working with BigDecimal

```dart
import 'package:jetleaf_lang/math.dart';

// Create BigDecimals from strings, integers, or doubles
final price = BigDecimal('1234.5678');
final quantity = BigDecimal.fromInt(5);
final taxRate = BigDecimal('0.0825');  // 8.25%

// Arithmetic operations with precise decimal arithmetic
final subtotal = price * quantity;
final tax = subtotal * taxRate;
final total = subtotal + tax;

// Scale and rounding
final rounded = total.setScale(2, RoundingMode.HALF_UP);
print(rounded);  // e.g., "6695.31"

// Comparison
print(price > BigDecimal.ten);  // true
print(price.signum);  // 1 (positive)
```

## API Reference

### BigInteger

#### Constructors

- `BigInteger(String value, [int radix = 10])`: Creates from a string in the specified radix
- `BigInteger.fromInt(int value)`: Creates from an integer
- `BigInteger.fromBigInt(BigInt value)`: Creates from a Dart BigInt
- `BigInteger.zero`, `BigInteger.one`, `BigInteger.ten`: Common constants

#### Methods

- **Arithmetic**: `+`, `-`, `*`, `~/`, `%`, `-unary`, `abs()`
- **Bit Operations**: `&`, `|`, `^`, `~`, `<<`, `>>`, `bitLength`, `bitCount`
- **Modular Arithmetic**: `modPow(BigInteger exponent, BigInteger m)`, `modInverse(BigInteger m)`
- **Primality**: `isProbablePrime(int certainty)`
- **Comparison**: `compareTo(BigInteger other)`, `==`, `<`, `<=`, `>`, `>=`
- **Conversion**: `toInt()`, `toBigInt()`, `toString([int? radix])`

### BigDecimal

#### Constructors

- `BigDecimal(String value)`: Creates from a string representation
- `BigDecimal.fromInt(int value, [int scale = 0])`: Creates from an integer with optional scale
- `BigDecimal.fromDouble(double value)`: Creates from a double (use with caution)
- `BigDecimal.zero`, `BigDecimal.one`, `BigDecimal.ten`: Common constants

#### Methods

- **Arithmetic**: `+`, `-`, `*`, `/`, `~/`, `%`, `-unary`, `abs()`
- **Scaling**: `setScale(int newScale, [RoundingMode roundingMode = RoundingMode.UNNECESSARY])`
- **Rounding**: `round(MathContext mc)`
- **Comparison**: `compareTo(BigDecimal other)`, `==`, `<`, `<=`, `>`, `>=`
- **Conversion**: `toInt()`, `toDouble()`, `toString()`

#### Rounding Modes

- `UP`: Round away from zero
- `DOWN`: Round towards zero
- `CEILING`: Round towards positive infinity
- `FLOOR`: Round towards negative infinity
- `HALF_UP`: Round towards nearest neighbor, or up if equidistant
- `HALF_DOWN`: Round towards nearest neighbor, or down if equidistant
- `HALF_EVEN`: Round towards nearest neighbor, or towards even neighbor if equidistant
- `UNNECESSARY`: No rounding necessary (throws exception if rounding would be needed)

## Best Practices

### When to Use

1. **Financial Calculations**
   - Currency amounts (avoid floating-point rounding errors)
   - Interest calculations
   - Tax computations

2. **Scientific Computing**
   - High-precision arithmetic
   - Number theory algorithms
   - Cryptographic applications

3. **Large Numbers**
   - Handling numbers larger than 64-bit integers
   - Factorials, permutations, combinations

### Performance Considerations

1. **Memory Usage**
   - BigIntegers and BigDecimals are immutable and create new instances for each operation
   - Avoid creating unnecessary intermediate objects in tight loops

2. **Operation Cost**
   - Multiplication and division are O(n²) in the number of digits
   - Consider performance implications for very large numbers
   - Cache frequently used constants

3. **String Conversion**
   - Parsing from strings is relatively expensive
   - Cache parsed values when possible
   - Be cautious with very large string representations

## Advanced Usage

### Mathematical Constants

```dart
// Calculate factorial
BigInteger factorial(int n) {
  if (n < 0) throw ArgumentError('Factorial of negative number');
  var result = BigInteger.one;
  for (var i = 2; i <= n; i++) {
    result *= BigInteger.fromInt(i);
  }
  return result;
}

// Calculate e to specified precision
BigDecimal calculateE(int precision) {
  final mc = MathContext(precision + 2);
  var e = BigDecimal.one;
  var term = BigDecimal.one;
  
  for (var i = 1; i < 100; i++) {
    term = term / BigDecimal.fromInt(i);
    if (term < BigDecimal.one.scaleByPowerOfTen(-precision)) break;
    e += term;
  }
  
  return e.setScale(precision, RoundingMode.DOWN);
}
```

### Financial Calculations

```dart
class Money {
  static const int DECIMALS = 2;
  static final BigDecimal ONE_HUNDRED = BigDecimal.fromInt(100);
  
  final BigDecimal amount;
  
  Money(String amount) : amount = BigDecimal(amount).setScale(DECIMALS);
  Money.fromCents(BigInteger cents) 
      : amount = BigDecimal.fromBigInt(cents._value, DECIMALS);
  
  Money operator +(Money other) => Money((amount + other.amount).toString());
  Money operator *(BigDecimal factor) => Money((amount * factor).toString());
  
  // Calculate compound interest
  static Money compoundInterest(
    Money principal, 
    BigDecimal rate, 
    int years
  ) {
    final ratePlusOne = BigDecimal.one + (rate / ONE_HUNDRED);
    final multiplier = ratePlusOne.pow(years);
    return principal * multiplier;
  }
  
  @override
  String toString() => amount.toStringAsFixed(DECIMALS);
}
```

## Common Pitfalls

1. **Floating-Point Conversion**
   - Avoid converting between BigDecimal and double when precision is critical
   - Use string constructors instead of double constructors for exact representation

2. **Immutability**
   - Remember that operations return new instances
   - Chain operations to avoid unnecessary intermediate objects

3. **Scale Handling**
   - Be explicit about scale and rounding mode
   - Watch out for non-terminating decimal expansions in division

4. **Performance**
   - Be cautious with very large exponents in modPow
   - Consider algorithmic complexity for large numbers

## See Also

- [Dart BigInt](https://api.dart.dev/stable/dart-core/BigInt-class.html)
- [Java BigDecimal](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/math/BigDecimal.html)
- [Java BigInteger](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/math/BigInteger.html)
