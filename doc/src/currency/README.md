# Currency Module

## Overview

The Currency module provides comprehensive support for working with currencies according to ISO 4217 standards. It includes currency codes, symbols, fraction digits, and numeric codes for global currencies, making it ideal for financial applications and internationalization.

## Features

- **ISO 4217 Compliance**: Standard currency codes and numeric codes
- **Locale Support**: Get currency based on locale/country
- **Singleton Pattern**: Efficient memory usage with cached currency instances
- **Comprehensive Data**: Includes symbols, display names, and decimal places
- **Type Safety**: Strongly typed API with compile-time checks

## Core Classes

### Currency

The main class representing a currency with properties:
- `currencyCode`: ISO 4217 code (e.g., "USD", "EUR")
- `symbol`: Currency symbol (e.g., "$", "€")
- `defaultFractionDigits`: Standard decimal places
- `numericCode`: ISO 4217 numeric code
- `displayName`: Localized display name

### CurrencyDatabase

Internal database containing:
- Mappings of country codes to currency codes
- Detailed currency information (symbols, digits, names)
- Support for 160+ global currencies

## Usage

### Basic Usage

```dart
import 'package:jetleaf_lang/currency.dart';

// Get currency by ISO code
final usd = Currency.getInstance('USD');
print('${usd.symbol}100.50'); // $100.50

// Get currency by locale
final locale = Locale('ja', 'JP');
final jpy = Currency.getInstanceFromLocale(locale);
print('${jpy.symbol}1000'); // ¥1000

// List all available currencies
final currencies = Currency.getAllCurrencies();
for (final currency in currencies) {
  print('${currency.currencyCode}: ${currency.displayName}');
}
```

### Formatting Currency Values

```dart
String formatCurrency(num amount, String currencyCode) {
  final currency = Currency.getInstance(currencyCode);
  final formatted = amount.toStringAsFixed(currency.defaultFractionDigits);
  return '${currency.symbol}$formatted';
}

print(formatCurrency(1234.5, 'USD')); // $1,234.50
print(formatCurrency(1234.5, 'JPY')); // ¥1,235 (no decimal places)
```

### Currency Conversion

```dart
class CurrencyConverter {
  final Map<String, double> exchangeRates;
  
  CurrencyConverter(this.exchangeRates);
  
  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    final rate = exchangeRates['${from}_$to'] ?? 
                (1 / (exchangeRates['${to}_$from'] ?? 1));
    return amount * rate;
  }
}

// Example usage
final converter = CurrencyConverter({
  'USD_EUR': 0.85,
  'USD_GBP': 0.72,
});

final amountInUSD = 100.0;
final amountInEUR = converter.convert(amountInUSD, 'USD', 'EUR');
print('$amountInUSD USD = $amountInEUR EUR');
```

## API Reference

### Static Methods

- `getInstance(String currencyCode)`: Gets a Currency instance for the ISO 4217 code
- `getInstanceFromLocale(Locale locale)`: Gets a Currency instance for a locale
- `getAvailableCurrencies()`: Returns a set of all available currency codes
- `getAllCurrencies()`: Returns a list of all available Currency instances

### Instance Properties

- `currencyCode`: The ISO 4217 3-letter code (e.g., "USD")
- `symbol`: The currency symbol (e.g., "$")
- `defaultFractionDigits`: The default number of fraction digits
- `numericCode`: The ISO 4217 numeric code
- `displayName`: The display name of the currency

## Best Practices

### Handling Monetary Values

1. **Use Fixed-Point Arithmetic**
   ```dart
   // Bad: Floating-point arithmetic
   final total = 0.1 + 0.2; // 0.30000000000000004
   
   // Good: Use fixed-point representation
   final totalCents = 10 + 20; // 30 cents
   ```

2. **Store Minor Units**
   ```dart
   // Store amounts in the smallest unit (e.g., cents)
   class Money {
     final int amount; // in cents
     final Currency currency;
     
     Money(this.amount, this.currency);
     
     String format() {
       final major = amount ~/ 100;
       final minor = amount % 100;
       return '${currency.symbol}$major.${minor.toString().padLeft(2, '0')}';
     }
   }
   ```

### Localization

```dart
String formatLocalized(num amount, String currencyCode, Locale locale) {
  final currency = Currency.getInstance(currencyCode);
  final formatter = NumberFormat.currency(
    locale: locale.toString(),
    symbol: currency.symbol,
    decimalDigits: currency.defaultFractionDigits,
  );
  return formatter.format(amount);
}

// Usage
final amount = 1234.5;
print(formatLocalized(amount, 'USD', Locale('en', 'US'))); // $1,234.50
print(formatLocalized(amount, 'EUR', Locale('de', 'DE'))); // 1.234,50 €
```

## Common Patterns

### Currency Input/Output

```dart
class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;
  final int decimalDigits;
  
  CurrencyInputFormatter({required this.decimalDigits, this.maxDigits = 10});
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    
    // Allow only digits and decimal separator
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // Limit total digits
    if (newValue.text.length > maxDigits) {
      return oldValue;
    }
    
    // Limit decimal places
    final parts = newValue.text.split('.');
    if (parts.length > 1 && parts[1].length > decimalDigits) {
      return oldValue;
    }
    
    return newValue;
  }
}
```

### Currency Selection

```dart
class CurrencySelector extends StatelessWidget {
  final String? selectedCurrency;
  final ValueChanged<String?> onChanged;
  
  const CurrencySelector({
    Key? key,
    this.selectedCurrency,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final currencies = Currency.getAllCurrencies();
    
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: InputDecoration(
        labelText: 'Currency',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text('Select a currency')),
        ...currencies.map((currency) => DropdownMenuItem(
          value: currency.currencyCode,
          child: Text('${currency.currencyCode} - ${currency.displayName}'),
        )),
      ],
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a currency' : null,
    );
  }
}
```

## Error Handling

Handle common currency-related errors:

```dry
try {
  final currency = Currency.getInstance('INVALID');
} on UnsupportedOperationException catch (e) {
  print('Error: ${e.message}'); // Unsupported currency code: INVALID
}

try {
  final locale = Locale('XX', 'XX');
  final currency = Currency.getInstanceFromLocale(locale);
} on UnsupportedOperationException catch (e) {
  print('Error: ${e.message}'); // No currency found for locale: xx_XX
}
```

## Performance Considerations

- **Singleton Pattern**: The `Currency` class uses a singleton pattern to cache instances
- **Lazy Loading**: Currency data is loaded only when needed
- **Immutable Objects**: Currency instances are immutable and thread-safe
- **Efficient Lookups**: Uses maps for O(1) lookups by currency code

## Dependencies

- `intl`: For number formatting
- `flutter_localizations`: For locale-aware formatting in Flutter apps

## See Also

- [ISO 4217](https://www.iso.org/iso-4217-currency-codes.html)
- [Unicode CLDR](https://cldr.unicode.org/) for locale data
- [Flutter Internationalization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
