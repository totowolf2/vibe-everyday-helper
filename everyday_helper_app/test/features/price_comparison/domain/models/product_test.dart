import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_helper_app/features/price_comparison/domain/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should calculate price per unit correctly', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act
      final pricePerUnit = product.pricePerUnit;

      // Assert
      expect(pricePerUnit, equals(5.0));
    });

    test('should return 0 for price per unit when quantity is 0', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 0.0,
        unit: 'kg',
      );

      // Act
      final pricePerUnit = product.pricePerUnit;

      // Assert
      expect(pricePerUnit, equals(0.0));
    });

    test('should return 0 for price per unit when quantity is negative', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: -1.0,
        unit: 'kg',
      );

      // Act
      final pricePerUnit = product.pricePerUnit;

      // Assert
      expect(pricePerUnit, equals(0.0));
    });

    test('should format price per unit correctly', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 3.0,
        unit: 'kg',
      );

      // Act
      final formattedPrice = product.formattedPricePerUnit;

      // Assert
      expect(formattedPrice, equals('3.33'));
    });

    test('should validate product correctly - valid product', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product.isValid, isTrue);
    });

    test('should validate product correctly - invalid with empty name', () {
      // Arrange
      const product = Product(
        id: '1',
        name: '',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product.isValid, isFalse);
    });

    test('should validate product correctly - invalid with zero price', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 0.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product.isValid, isFalse);
    });

    test('should validate product correctly - invalid with zero quantity', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 0.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product.isValid, isFalse);
    });

    test('should validate product correctly - invalid with empty unit', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: '',
      );

      // Act & Assert
      expect(product.isValid, isFalse);
    });

    test('should return display name when name is provided', () {
      // Arrange
      const product = Product(
        id: '12345678',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product.displayName, equals('Test Product'));
    });

    test('should return fallback display name when name is empty', () {
      // Arrange
      const product = Product(
        id: '12345678',
        name: '',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product.displayName, equals('Product 12345678'));
    });

    test('should create copy with updated values', () {
      // Arrange
      const original = Product(
        id: '1',
        name: 'Original',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act
      final copy = original.copyWith(name: 'Updated', price: 15.0);

      // Assert
      expect(copy.id, equals('1'));
      expect(copy.name, equals('Updated'));
      expect(copy.price, equals(15.0));
      expect(copy.quantity, equals(2.0));
      expect(copy.unit, equals('kg'));
    });

    test('should convert to map correctly', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act
      final map = product.toMap();

      // Assert
      expect(
        map,
        equals({
          'id': '1',
          'name': 'Test Product',
          'price': 10.0,
          'quantity': 2.0,
          'unit': 'kg',
          'packSize': 1,
          'individualQuantity': 2.0,
        }),
      );
    });

    test('should create from map correctly', () {
      // Arrange
      final map = {
        'id': '1',
        'name': 'Test Product',
        'price': 10.0,
        'quantity': 2.0,
        'unit': 'kg',
        'packSize': 1,
        'individualQuantity': 2.0,
      };

      // Act
      final product = Product.fromMap(map);

      // Assert
      expect(product.id, equals('1'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(10.0));
      expect(product.quantity, equals(2.0));
      expect(product.unit, equals('kg'));
      expect(product.packSize, equals(1));
      expect(product.individualQuantity, equals(2.0));
    });

    test('should handle equality correctly', () {
      // Arrange
      const product1 = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const product2 = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const product3 = Product(
        id: '2',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act & Assert
      expect(product1 == product2, isTrue);
      expect(product1 == product3, isFalse);
      expect(product1.hashCode == product2.hashCode, isTrue);
    });

    // Pack functionality tests
    group('Pack functionality', () {
      test('should identify pack products correctly', () {
        // Arrange
        const packProduct = Product(
          id: '1',
          name: 'Pack Product',
          price: 57.0,
          quantity: 1200.0,
          unit: 'ml',
          packSize: 6,
          individualQuantity: 200.0,
        );

        const simpleProduct = Product(
          id: '2',
          name: 'Simple Product',
          price: 10.0,
          quantity: 2.0,
          unit: 'kg',
        );

        // Act & Assert
        expect(packProduct.isPack, isTrue);
        expect(simpleProduct.isPack, isFalse);
      });

      test('should calculate pack totals correctly', () {
        // Arrange
        const packProduct = Product(
          id: '1',
          name: 'Pack Product',
          price: 57.0,
          quantity: 1200.0,
          unit: 'ml',
          packSize: 6,
          individualQuantity: 200.0,
        );

        // Act & Assert
        expect(packProduct.totalQuantity, equals(1200.0));
        expect(packProduct.pricePerPiece, equals(9.5)); // 57/6
        expect(packProduct.pricePerUnitFromPack, equals(0.0475)); // 57/1200
      });

      test('should validate pack products correctly', () {
        // Arrange
        const validPackProduct = Product(
          id: '1',
          name: 'Valid Pack',
          price: 57.0,
          quantity: 1200.0,
          unit: 'ml',
          packSize: 6,
          individualQuantity: 200.0,
        );

        const invalidPackProduct = Product(
          id: '2',
          name: 'Invalid Pack',
          price: 57.0,
          quantity: 1200.0,
          unit: 'ml',
          packSize: 0,
          individualQuantity: 200.0,
        );

        // Act & Assert
        expect(validPackProduct.isValid, isTrue);
        expect(invalidPackProduct.isValid, isFalse);
      });

      test('should handle pack serialization correctly', () {
        // Arrange
        const packProduct = Product(
          id: '1',
          name: 'Pack Product',
          price: 57.0,
          quantity: 1200.0,
          unit: 'ml',
          packSize: 6,
          individualQuantity: 200.0,
        );

        // Act
        final map = packProduct.toMap();
        final restoredProduct = Product.fromMap(map);

        // Assert
        expect(restoredProduct, equals(packProduct));
        expect(restoredProduct.packSize, equals(6));
        expect(restoredProduct.individualQuantity, equals(200.0));
        expect(restoredProduct.isPack, isTrue);
      });
    });
  });
}
