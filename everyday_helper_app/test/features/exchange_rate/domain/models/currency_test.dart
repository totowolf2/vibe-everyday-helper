import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_helper_app/features/exchange_rate/domain/models/currency.dart';

void main() {
  group('Currency Model Tests', () {
    test('should create Currency with all required fields', () {
      const currency = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
      );

      expect(currency.code, equals('USD'));
      expect(currency.name, equals('US Dollar'));
      expect(currency.symbol, equals('\$'));
      expect(currency.isValid, isTrue);
    });

    test('should validate Currency correctly', () {
      const validCurrency = Currency(
        code: 'THB',
        name: 'Thai Baht',
        symbol: '฿',
      );

      const invalidCurrency = Currency(
        code: '',
        name: 'Invalid',
        symbol: '\$',
      );

      expect(validCurrency.isValid, isTrue);
      expect(invalidCurrency.isValid, isFalse);
    });

    test('should find currency by code', () {
      final usd = Currency.fromCode('USD');
      final thb = Currency.fromCode('THB');
      final invalid = Currency.fromCode('INVALID');

      expect(usd, equals(Currency.usd));
      expect(thb, equals(Currency.thb));
      expect(invalid, isNull);
    });

    test('should generate display name correctly', () {
      const currency = Currency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
      );

      expect(currency.displayName, equals('Euro (EUR)'));
    });

    test('should serialize to and from map correctly', () {
      const original = Currency(
        code: 'GBP',
        name: 'British Pound',
        symbol: '£',
      );

      final map = original.toMap();
      final recreated = Currency.fromMap(map);

      expect(recreated, equals(original));
      expect(recreated.code, equals(original.code));
      expect(recreated.name, equals(original.name));
      expect(recreated.symbol, equals(original.symbol));
    });

    test('should handle equality correctly', () {
      const currency1 = Currency(
        code: 'JPY',
        name: 'Japanese Yen',
        symbol: '¥',
      );

      const currency2 = Currency(
        code: 'JPY',
        name: 'Japanese Yen',
        symbol: '¥',
      );

      const currency3 = Currency(
        code: 'CNY',
        name: 'Chinese Yuan',
        symbol: '¥',
      );

      expect(currency1, equals(currency2));
      expect(currency1.hashCode, equals(currency2.hashCode));
      expect(currency1, isNot(equals(currency3)));
    });

    test('should have all expected supported currencies', () {
      final supportedCodes = Currency.supportedCurrencies
          .map((currency) => currency.code)
          .toList();

      expect(supportedCodes, contains('USD'));
      expect(supportedCodes, contains('THB'));
      expect(supportedCodes, contains('EUR'));
      expect(supportedCodes, contains('GBP'));
      expect(supportedCodes, contains('JPY'));
      expect(supportedCodes, contains('CNY'));
      expect(supportedCodes, contains('AUD'));
      expect(supportedCodes, contains('CAD'));
      expect(supportedCodes, contains('CHF'));
      expect(supportedCodes, contains('SGD'));
    });
  });
}