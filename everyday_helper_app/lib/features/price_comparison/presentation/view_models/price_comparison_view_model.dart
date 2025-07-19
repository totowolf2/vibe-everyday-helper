import 'package:flutter/foundation.dart';
import '../../domain/models/product.dart';
import '../../domain/models/comparison_result.dart';
import '../../../../shared/constants/app_constants.dart';

class PriceComparisonViewModel extends ChangeNotifier {
  final List<Product> _products = [];
  ComparisonResult? _comparisonResult;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  ComparisonResult? get comparisonResult => _comparisonResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => _products.isNotEmpty;
  bool get canCompare => _products.where((p) => p.isValid).length >= 2;
  int get productCount => _products.length;
  int get validProductCount => _products.where((p) => p.isValid).length;

  Product? get bestValueProduct => _comparisonResult?.bestValueProduct;

  // Add product
  void addProduct(Product product) {
    if (_products.length >= AppConstants.maxProductsPerComparison) {
      _setError(
        'Maximum ${AppConstants.maxProductsPerComparison} products allowed',
      );
      return;
    }

    _clearError();
    _products.add(product);
    _updateComparison();
    notifyListeners();
  }

  // Update product
  void updateProduct(int index, Product product) {
    if (index < 0 || index >= _products.length) {
      _setError('Invalid product index');
      return;
    }

    _clearError();
    _products[index] = product;
    _updateComparison();
    notifyListeners();
  }

  // Remove product
  void removeProduct(int index) {
    if (index < 0 || index >= _products.length) {
      _setError('Invalid product index');
      return;
    }

    _clearError();
    _products.removeAt(index);
    _updateComparison();
    notifyListeners();
  }

  // Remove product by ID
  void removeProductById(String id) {
    _clearError();
    _products.removeWhere((product) => product.id == id);
    _updateComparison();
    notifyListeners();
  }

  // Clear all products
  void clearAllProducts() {
    _clearError();
    _products.clear();
    _comparisonResult = null;
    notifyListeners();
  }

  // Add empty product template
  void addEmptyProduct({bool isPackMode = false}) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final emptyProduct = Product(
      id: newId,
      name: '',
      price: 0.0,
      quantity: 0.0,
      unit: '',
      packSize: isPackMode ? 1 : 1,
      individualQuantity: isPackMode ? 0.0 : null,
    );
    addProduct(emptyProduct);
  }

  // Get product savings information
  Map<String, dynamic> getProductSavingsInfo(Product product) {
    if (_comparisonResult == null || !hasProducts || validProductCount < 2) {
      return {'savings': 0.0, 'percentage': 0.0, 'isBestValue': false};
    }

    final bestValue = bestValueProduct;
    if (bestValue == null) {
      return {'savings': 0.0, 'percentage': 0.0, 'isBestValue': false};
    }

    final isBestValue = product.id == bestValue.id;
    if (isBestValue) {
      return {'savings': 0.0, 'percentage': 0.0, 'isBestValue': true};
    }

    final productPricePerUnit = product.isPack
        ? product.pricePerUnitFromPack
        : product.pricePerUnit;
    final bestPricePerUnit = bestValue.isPack
        ? bestValue.pricePerUnitFromPack
        : bestValue.pricePerUnit;

    final savings = productPricePerUnit - bestPricePerUnit;
    final percentage = productPricePerUnit > 0
        ? (savings / productPricePerUnit) * 100
        : 0.0;

    return {'savings': savings, 'percentage': percentage, 'isBestValue': false};
  }

  // Get pack-specific calculation details
  Map<String, dynamic> getPackCalculationDetails(Product product) {
    if (!product.isPack) {
      return {
        'isPack': false,
        'pricePerPiece': product.price,
        'pricePerUnit': product.pricePerUnit,
        'totalQuantity': product.quantity,
      };
    }

    return {
      'isPack': true,
      'packSize': product.packSize,
      'individualQuantity': product.individualQuantity,
      'totalQuantity': product.totalQuantity,
      'pricePerPiece': product.pricePerPiece,
      'pricePerUnit': product.pricePerUnitFromPack,
      'packBreakdown':
          '${product.packSize} × ${product.individualQuantity.toStringAsFixed(product.individualQuantity.truncateToDouble() == product.individualQuantity ? 0 : 1)} = ${product.totalQuantity.toStringAsFixed(product.totalQuantity.truncateToDouble() == product.totalQuantity ? 0 : 1)} ${product.unit}',
    };
  }

  // Validate product input
  Map<String, String> validateProduct({
    required String name,
    required String priceText,
    required String quantityText,
    required String unit,
    bool isPackMode = false,
    int packSize = 1,
    String individualQuantityText = '',
  }) {
    final errors = <String, String>{};

    // Name validation
    if (name.trim().isEmpty) {
      errors['name'] = 'Product name is required';
    } else if (name.trim().length > AppConstants.maxProductNameLength) {
      errors['name'] =
          'Product name too long (max ${AppConstants.maxProductNameLength} characters)';
    }

    // Price validation
    final price = double.tryParse(priceText.trim());
    if (priceText.trim().isEmpty) {
      errors['price'] = 'Price is required';
    } else if (price == null) {
      errors['price'] = 'Invalid price format';
    } else if (price <= 0) {
      errors['price'] = 'Price must be greater than 0';
    } else if (price > AppConstants.maxPrice) {
      errors['price'] = 'Price too high (max ${AppConstants.maxPrice})';
    }

    // Quantity validation
    final quantity = double.tryParse(quantityText.trim());
    if (quantityText.trim().isEmpty) {
      errors['quantity'] = 'Quantity is required';
    } else if (quantity == null) {
      errors['quantity'] = 'Invalid quantity format';
    } else if (quantity <= 0) {
      errors['quantity'] = 'Quantity must be greater than 0';
    } else if (quantity > AppConstants.maxQuantity) {
      errors['quantity'] =
          'Quantity too high (max ${AppConstants.maxQuantity})';
    }

    // Unit validation
    if (unit.trim().isEmpty) {
      errors['unit'] = 'Unit is required';
    }

    // Pack-specific validation
    if (isPackMode) {
      if (packSize <= 0) {
        errors['packSize'] = 'Pack size must be greater than 0';
      }

      final individualQuantity = double.tryParse(individualQuantityText.trim());
      if (individualQuantityText.trim().isEmpty) {
        errors['individualQuantity'] = 'Individual quantity is required';
      } else if (individualQuantity == null) {
        errors['individualQuantity'] = 'Invalid individual quantity format';
      } else if (individualQuantity <= 0) {
        errors['individualQuantity'] =
            'Individual quantity must be greater than 0';
      } else if (individualQuantity > AppConstants.maxQuantity) {
        errors['individualQuantity'] =
            'Individual quantity too high (max ${AppConstants.maxQuantity})';
      }
    }

    return errors;
  }

  // Create product from form data
  Product? createProductFromForm({
    required String name,
    required String priceText,
    required String quantityText,
    required String unit,
    String? existingId,
    bool isPackMode = false,
    int packSize = 1,
    String individualQuantityText = '',
  }) {
    final errors = validateProduct(
      name: name,
      priceText: priceText,
      quantityText: quantityText,
      unit: unit,
      isPackMode: isPackMode,
      packSize: packSize,
      individualQuantityText: individualQuantityText,
    );

    if (errors.isNotEmpty) {
      _setError(errors.values.first);
      return null;
    }

    final price = double.parse(priceText.trim());
    final quantity = double.parse(quantityText.trim());
    final id = existingId ?? DateTime.now().millisecondsSinceEpoch.toString();

    return Product(
      id: id,
      name: name.trim(),
      price: price,
      quantity: quantity,
      unit: unit.trim(),
      packSize: isPackMode ? packSize : 1,
      individualQuantity: isPackMode
          ? double.parse(individualQuantityText.trim())
          : null,
    );
  }

  // Update comparison result
  void _updateComparison() {
    if (_products.isEmpty) {
      _comparisonResult = null;
      return;
    }

    _comparisonResult = ComparisonResult.fromProducts(_products);
  }

  // Error handling
  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper methods for UI
  bool isProductBestValue(Product product) {
    return bestValueProduct?.id == product.id;
  }

  bool isProductBestValueByPiece(Product product) {
    return _comparisonResult?.bestValueByPiece?.id == product.id;
  }

  List<Product> getProductsSortedByValue() {
    return _comparisonResult?.sortedByBestValue ?? [];
  }

  List<Product> getProductsSortedByValuePerPiece() {
    return _comparisonResult?.sortedByBestValuePerPiece ?? [];
  }

  String getComparisonSummary() {
    return _comparisonResult?.summary ?? 'No products to compare';
  }

  String getSavingsSummary() {
    return _comparisonResult?.getSavingsSummary() ?? '';
  }

  bool get hasPackProducts {
    return _comparisonResult?.hasPackProducts ?? false;
  }

  double? get totalSavings {
    return _comparisonResult?.totalSavings;
  }

  double? get savingsPercentage {
    return _comparisonResult?.savingsPercentage;
  }

  double? get totalSavingsByPiece {
    return _comparisonResult?.totalSavingsByPiece;
  }

  double? get savingsPercentageByPiece {
    return _comparisonResult?.savingsPercentageByPiece;
  }

  Product? get bestValueByPiece {
    return _comparisonResult?.bestValueByPiece;
  }

  // Bulk operations
  Future<void> addMultipleProducts(List<Product> newProducts) async {
    _setLoading(true);

    try {
      for (final product in newProducts) {
        if (_products.length < AppConstants.maxProductsPerComparison) {
          _products.add(product);
        }
      }
      _updateComparison();
    } catch (e) {
      _setError('Failed to add products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
