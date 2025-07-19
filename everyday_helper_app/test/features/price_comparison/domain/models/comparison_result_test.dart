import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_helper_app/features/price_comparison/domain/models/product.dart';
import 'package:everyday_helper_app/features/price_comparison/domain/models/comparison_result.dart'
    as comparison;

void main() {
  group('ComparisonResult Model Tests', () {
    test('should handle empty product list', () {
      // Arrange
      final products = <Product>[];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);

      // Assert
      expect(result.products, isEmpty);
      expect(result.bestValueProduct, isNull);
      expect(result.mostExpensiveProduct, isNull);
      expect(result.hasValidProducts, isFalse);
      expect(result.validProductCount, equals(0));
      expect(result.summary, equals('No valid products to compare'));
    });

    test('should handle single valid product', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );
      final products = [product];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);

      // Assert
      expect(result.products, hasLength(1));
      expect(result.bestValueProduct, equals(product));
      expect(result.mostExpensiveProduct, equals(product));
      expect(result.hasValidProducts, isTrue);
      expect(result.validProductCount, equals(1));
      expect(result.summary, equals('1 product analyzed'));
    });

    test('should identify best value product correctly', () {
      // Arrange
      const expensiveProduct = Product(
        id: '1',
        name: 'Expensive Product',
        price: 20.0,
        quantity: 2.0, // $10 per kg
        unit: 'kg',
      );

      const cheapProduct = Product(
        id: '2',
        name: 'Cheap Product',
        price: 15.0,
        quantity: 5.0, // $3 per kg
        unit: 'kg',
      );

      final products = [expensiveProduct, cheapProduct];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);

      // Assert
      expect(result.bestValueProduct, equals(cheapProduct));
      expect(result.mostExpensiveProduct, equals(expensiveProduct));
      expect(result.validProductCount, equals(2));
      expect(result.summary, equals('2 products compared'));
    });

    test('should sort products by best value', () {
      // Arrange
      const mostExpensive = Product(
        id: '1',
        name: 'Most Expensive',
        price: 30.0,
        quantity: 2.0, // $15 per kg
        unit: 'kg',
      );

      const cheapest = Product(
        id: '2',
        name: 'Cheapest',
        price: 10.0,
        quantity: 5.0, // $2 per kg
        unit: 'kg',
      );

      const middle = Product(
        id: '3',
        name: 'Middle',
        price: 20.0,
        quantity: 4.0, // $5 per kg
        unit: 'kg',
      );

      final products = [mostExpensive, middle, cheapest];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);
      final sortedProducts = result.sortedByBestValue;

      // Assert
      expect(sortedProducts[0], equals(cheapest)); // $2 per kg
      expect(sortedProducts[1], equals(middle)); // $5 per kg
      expect(sortedProducts[2], equals(mostExpensive)); // $15 per kg
    });

    test('should calculate total savings correctly', () {
      // Arrange
      const expensive = Product(
        id: '1',
        name: 'Expensive',
        price: 20.0,
        quantity: 2.0, // $10 per kg
        unit: 'kg',
      );

      const cheap = Product(
        id: '2',
        name: 'Cheap',
        price: 15.0,
        quantity: 5.0, // $3 per kg
        unit: 'kg',
      );

      final products = [expensive, cheap];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);

      // Assert
      expect(result.totalSavings, equals(7.0)); // $10 - $3 = $7
    });

    test('should calculate savings percentage correctly', () {
      // Arrange
      const expensive = Product(
        id: '1',
        name: 'Expensive',
        price: 20.0,
        quantity: 2.0, // $10 per kg
        unit: 'kg',
      );

      const cheap = Product(
        id: '2',
        name: 'Cheap',
        price: 15.0,
        quantity: 5.0, // $3 per kg
        unit: 'kg',
      );

      final products = [expensive, cheap];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);

      // Assert
      expect(result.savingsPercentage, equals(70.0)); // (7/10) * 100 = 70%
    });

    test('should handle invalid products in list', () {
      // Arrange
      const validProduct = Product(
        id: '1',
        name: 'Valid Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const invalidProduct = Product(
        id: '2',
        name: '', // Invalid: empty name
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      final products = [validProduct, invalidProduct];

      // Act
      final result = comparison.ComparisonResult.fromProducts(products);

      // Assert
      expect(result.products, hasLength(2)); // Both products in list
      expect(result.validProductCount, equals(1)); // Only one valid
      expect(result.bestValueProduct, equals(validProduct));
      expect(
        result.sortedByBestValue,
        hasLength(1),
      ); // Only valid products sorted
    });

    test(
      'should handle zero savings when products have same price per unit',
      () {
        // Arrange
        const product1 = Product(
          id: '1',
          name: 'Product 1',
          price: 10.0,
          quantity: 2.0, // $5 per kg
          unit: 'kg',
        );

        const product2 = Product(
          id: '2',
          name: 'Product 2',
          price: 15.0,
          quantity: 3.0, // $5 per kg
          unit: 'kg',
        );

        final products = [product1, product2];

        // Act
        final result = comparison.ComparisonResult.fromProducts(products);

        // Assert
        expect(result.totalSavings, equals(0.0));
        expect(result.savingsPercentage, equals(0.0));
      },
    );

    test(
      'should handle edge case with zero price per unit for most expensive',
      () {
        // Arrange
        const validProduct = Product(
          id: '1',
          name: 'Valid Product',
          price: 10.0,
          quantity: 2.0,
          unit: 'kg',
        );

        const zeroQuantityProduct = Product(
          id: '2',
          name: 'Zero Quantity Product',
          price: 10.0,
          quantity: 0.0, // This makes pricePerUnit = 0
          unit: 'kg',
        );

        final products = [validProduct, zeroQuantityProduct];

        // Act
        final result = comparison.ComparisonResult.fromProducts(products);

        // Assert
        expect(result.validProductCount, equals(1));
        expect(result.savingsPercentage, equals(0.0));
      },
    );
  });
}
