import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_helper_app/features/price_comparison/presentation/view_models/price_comparison_view_model.dart';
import 'package:everyday_helper_app/features/price_comparison/domain/models/product.dart';

void main() {
  group('PriceComparisonViewModel Tests', () {
    late PriceComparisonViewModel viewModel;

    setUp(() {
      viewModel = PriceComparisonViewModel();
    });

    test('should start with empty state', () {
      // Assert
      expect(viewModel.products, isEmpty);
      expect(viewModel.hasProducts, isFalse);
      expect(viewModel.canCompare, isFalse);
      expect(viewModel.productCount, equals(0));
      expect(viewModel.validProductCount, equals(0));
      expect(viewModel.comparisonResult, isNull);
      expect(viewModel.bestValueProduct, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('should add product successfully', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test Product',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act
      viewModel.addProduct(product);

      // Assert
      expect(viewModel.products, hasLength(1));
      expect(viewModel.products.first, equals(product));
      expect(viewModel.hasProducts, isTrue);
      expect(viewModel.productCount, equals(1));
      expect(viewModel.validProductCount, equals(1));
      expect(viewModel.comparisonResult, isNotNull);
    });

    test('should update comparison result when adding products', () {
      // Arrange
      const product1 = Product(
        id: '1',
        name: 'Expensive Product',
        price: 20.0,
        quantity: 2.0, // $10 per kg
        unit: 'kg',
      );

      const product2 = Product(
        id: '2',
        name: 'Cheap Product',
        price: 15.0,
        quantity: 5.0, // $3 per kg
        unit: 'kg',
      );

      // Act
      viewModel.addProduct(product1);
      viewModel.addProduct(product2);

      // Assert
      expect(viewModel.canCompare, isTrue);
      expect(viewModel.bestValueProduct, equals(product2));
      expect(viewModel.comparisonResult?.totalSavings, equals(7.0));
    });

    test('should update product successfully', () {
      // Arrange
      const originalProduct = Product(
        id: '1',
        name: 'Original',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const updatedProduct = Product(
        id: '1',
        name: 'Updated',
        price: 15.0,
        quantity: 3.0,
        unit: 'g',
      );

      viewModel.addProduct(originalProduct);

      // Act
      viewModel.updateProduct(0, updatedProduct);

      // Assert
      expect(viewModel.products, hasLength(1));
      expect(viewModel.products.first, equals(updatedProduct));
      expect(viewModel.products.first.name, equals('Updated'));
    });

    test('should handle update product with invalid index', () {
      // Arrange
      const product = Product(
        id: '1',
        name: 'Test',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      // Act
      viewModel.updateProduct(0, product); // Invalid index on empty list

      // Assert
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.products, isEmpty);
    });

    test('should remove product successfully', () {
      // Arrange
      const product1 = Product(
        id: '1',
        name: 'Product 1',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const product2 = Product(
        id: '2',
        name: 'Product 2',
        price: 15.0,
        quantity: 3.0,
        unit: 'kg',
      );

      viewModel.addProduct(product1);
      viewModel.addProduct(product2);

      // Act
      viewModel.removeProduct(0);

      // Assert
      expect(viewModel.products, hasLength(1));
      expect(viewModel.products.first, equals(product2));
    });

    test('should remove product by ID successfully', () {
      // Arrange
      const product1 = Product(
        id: '1',
        name: 'Product 1',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const product2 = Product(
        id: '2',
        name: 'Product 2',
        price: 15.0,
        quantity: 3.0,
        unit: 'kg',
      );

      viewModel.addProduct(product1);
      viewModel.addProduct(product2);

      // Act
      viewModel.removeProductById('1');

      // Assert
      expect(viewModel.products, hasLength(1));
      expect(viewModel.products.first.id, equals('2'));
    });

    test('should clear all products successfully', () {
      // Arrange
      const product1 = Product(
        id: '1',
        name: 'Product 1',
        price: 10.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const product2 = Product(
        id: '2',
        name: 'Product 2',
        price: 15.0,
        quantity: 3.0,
        unit: 'kg',
      );

      viewModel.addProduct(product1);
      viewModel.addProduct(product2);

      // Act
      viewModel.clearAllProducts();

      // Assert
      expect(viewModel.products, isEmpty);
      expect(viewModel.comparisonResult, isNull);
      expect(viewModel.hasProducts, isFalse);
    });

    test('should validate product input correctly - valid input', () {
      // Act
      final errors = viewModel.validateProduct(
        name: 'Test Product',
        priceText: '10.50',
        quantityText: '2.5',
        unit: 'kg',
      );

      // Assert
      expect(errors, isEmpty);
    });

    test('should validate product input correctly - invalid name', () {
      // Act
      final errors = viewModel.validateProduct(
        name: '',
        priceText: '10.50',
        quantityText: '2.5',
        unit: 'kg',
      );

      // Assert
      expect(errors['name'], equals('Product name is required'));
    });

    test('should validate product input correctly - invalid price', () {
      // Act
      final errors = viewModel.validateProduct(
        name: 'Test Product',
        priceText: 'invalid',
        quantityText: '2.5',
        unit: 'kg',
      );

      // Assert
      expect(errors['price'], equals('Invalid price format'));
    });

    test('should validate product input correctly - zero price', () {
      // Act
      final errors = viewModel.validateProduct(
        name: 'Test Product',
        priceText: '0',
        quantityText: '2.5',
        unit: 'kg',
      );

      // Assert
      expect(errors['price'], equals('Price must be greater than 0'));
    });

    test('should validate product input correctly - invalid quantity', () {
      // Act
      final errors = viewModel.validateProduct(
        name: 'Test Product',
        priceText: '10.50',
        quantityText: 'invalid',
        unit: 'kg',
      );

      // Assert
      expect(errors['quantity'], equals('Invalid quantity format'));
    });

    test('should validate product input correctly - empty unit', () {
      // Act
      final errors = viewModel.validateProduct(
        name: 'Test Product',
        priceText: '10.50',
        quantityText: '2.5',
        unit: '',
      );

      // Assert
      expect(errors['unit'], equals('Unit is required'));
    });

    test('should create product from valid form data', () {
      // Act
      final product = viewModel.createProductFromForm(
        name: 'Test Product',
        priceText: '10.50',
        quantityText: '2.5',
        unit: 'kg',
      );

      // Assert
      expect(product, isNotNull);
      expect(product!.name, equals('Test Product'));
      expect(product.price, equals(10.50));
      expect(product.quantity, equals(2.5));
      expect(product.unit, equals('kg'));
    });

    test('should return null for invalid form data', () {
      // Act
      final product = viewModel.createProductFromForm(
        name: '',
        priceText: '10.50',
        quantityText: '2.5',
        unit: 'kg',
      );

      // Assert
      expect(product, isNull);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('should identify best value product correctly', () {
      // Arrange
      const expensive = Product(
        id: '1',
        name: 'Expensive',
        price: 20.0,
        quantity: 2.0,
        unit: 'kg',
      );

      const cheap = Product(
        id: '2',
        name: 'Cheap',
        price: 15.0,
        quantity: 5.0,
        unit: 'kg',
      );

      viewModel.addProduct(expensive);
      viewModel.addProduct(cheap);

      // Act & Assert
      expect(viewModel.isProductBestValue(cheap), isTrue);
      expect(viewModel.isProductBestValue(expensive), isFalse);
    });

    test('should get sorted products by value', () {
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

      viewModel.addProduct(expensive);
      viewModel.addProduct(cheap);

      // Act
      final sortedProducts = viewModel.getProductsSortedByValue();

      // Assert
      expect(sortedProducts.first, equals(cheap));
      expect(sortedProducts.last, equals(expensive));
    });

    test('should clear error message', () {
      // Arrange
      viewModel.updateProduct(
        0,
        const Product(
          id: '1',
          name: 'Test',
          price: 10.0,
          quantity: 2.0,
          unit: 'kg',
        ),
      ); // This will set an error

      expect(viewModel.errorMessage, isNotNull);

      // Act
      viewModel.clearError();

      // Assert
      expect(viewModel.errorMessage, isNull);
    });

    test('should prevent adding more than maximum products', () {
      // Arrange - Add maximum number of products (10)
      for (int i = 0; i < 10; i++) {
        viewModel.addProduct(
          Product(
            id: i.toString(),
            name: 'Product $i',
            price: 10.0,
            quantity: 2.0,
            unit: 'kg',
          ),
        );
      }

      // Act - Try to add one more
      viewModel.addProduct(
        const Product(
          id: '11',
          name: 'Extra Product',
          price: 10.0,
          quantity: 2.0,
          unit: 'kg',
        ),
      );

      // Assert
      expect(viewModel.productCount, equals(10));
      expect(viewModel.errorMessage, contains('Maximum'));
    });
  });
}
