import 'product.dart';

enum ComparisonMode { pricePerUnit, pricePerPiece, automatic }

class ComparisonResult {
  final List<Product> products;
  final Product? bestValueProduct;
  final Product? mostExpensiveProduct;
  final Product? bestValueByPiece;
  final Product? mostExpensiveByPiece;
  final ComparisonMode comparisonMode;
  final DateTime createdAt;

  const ComparisonResult({
    required this.products,
    this.bestValueProduct,
    this.mostExpensiveProduct,
    this.bestValueByPiece,
    this.mostExpensiveByPiece,
    this.comparisonMode = ComparisonMode.automatic,
    required this.createdAt,
  });

  factory ComparisonResult.fromProducts(
    List<Product> products, {
    ComparisonMode mode = ComparisonMode.automatic,
  }) {
    if (products.isEmpty) {
      return ComparisonResult(
        products: products,
        comparisonMode: mode,
        createdAt: DateTime.now(),
      );
    }

    final validProducts = products.where((p) => p.isValid).toList();

    if (validProducts.isEmpty) {
      return ComparisonResult(
        products: products,
        comparisonMode: mode,
        createdAt: DateTime.now(),
      );
    }

    // Determine comparison mode
    final hasPackProducts = validProducts.any((p) => p.isPack);
    final effectiveMode = mode == ComparisonMode.automatic
        ? (hasPackProducts
              ? ComparisonMode.pricePerUnit
              : ComparisonMode.pricePerUnit)
        : mode;

    // Sort by price per unit (ascending - cheapest first)
    final sortedByUnit = List<Product>.from(validProducts)
      ..sort(
        (a, b) => _getEffectivePricePerUnit(
          a,
        ).compareTo(_getEffectivePricePerUnit(b)),
      );

    // Sort by price per piece for pack products
    final sortedByPiece = List<Product>.from(validProducts)
      ..sort((a, b) => a.pricePerPiece.compareTo(b.pricePerPiece));

    return ComparisonResult(
      products: products,
      bestValueProduct: sortedByUnit.first,
      mostExpensiveProduct: sortedByUnit.last,
      bestValueByPiece: hasPackProducts ? sortedByPiece.first : null,
      mostExpensiveByPiece: hasPackProducts ? sortedByPiece.last : null,
      comparisonMode: effectiveMode,
      createdAt: DateTime.now(),
    );
  }

  static double _getEffectivePricePerUnit(Product product) {
    return product.isPack ? product.pricePerUnitFromPack : product.pricePerUnit;
  }

  List<Product> get sortedByBestValue {
    final validProducts = products.where((p) => p.isValid).toList();
    validProducts.sort(
      (a, b) =>
          _getEffectivePricePerUnit(a).compareTo(_getEffectivePricePerUnit(b)),
    );
    return validProducts;
  }

  List<Product> get sortedByBestValuePerPiece {
    final validProducts = products.where((p) => p.isValid).toList();
    validProducts.sort((a, b) => a.pricePerPiece.compareTo(b.pricePerPiece));
    return validProducts;
  }

  bool get hasPackProducts {
    return products.any((p) => p.isPack && p.isValid);
  }

  double get totalSavings {
    if (bestValueProduct == null || mostExpensiveProduct == null) return 0.0;
    final bestPrice = _getEffectivePricePerUnit(bestValueProduct!);
    final worstPrice = _getEffectivePricePerUnit(mostExpensiveProduct!);
    return worstPrice - bestPrice;
  }

  double get savingsPercentage {
    if (bestValueProduct == null || mostExpensiveProduct == null) return 0.0;
    final worstPrice = _getEffectivePricePerUnit(mostExpensiveProduct!);
    if (worstPrice == 0) return 0.0;
    return (totalSavings / worstPrice) * 100;
  }

  double get totalSavingsByPiece {
    if (bestValueByPiece == null || mostExpensiveByPiece == null) return 0.0;
    return mostExpensiveByPiece!.pricePerPiece -
        bestValueByPiece!.pricePerPiece;
  }

  double get savingsPercentageByPiece {
    if (bestValueByPiece == null || mostExpensiveByPiece == null) return 0.0;
    if (mostExpensiveByPiece!.pricePerPiece == 0) return 0.0;
    return (totalSavingsByPiece / mostExpensiveByPiece!.pricePerPiece) * 100;
  }

  bool get hasValidProducts {
    return products.any((p) => p.isValid);
  }

  int get validProductCount {
    return products.where((p) => p.isValid).length;
  }

  String get summary {
    if (!hasValidProducts) return 'No valid products to compare';
    if (validProductCount == 1) return '1 product analyzed';

    final packCount = products.where((p) => p.isPack && p.isValid).length;
    final simpleCount = validProductCount - packCount;

    if (packCount > 0 && simpleCount > 0) {
      return '$validProductCount products compared ($packCount packs, $simpleCount simple)';
    } else if (packCount > 0) {
      return '$validProductCount pack products compared';
    } else {
      return '$validProductCount products compared';
    }
  }

  String getSavingsSummary() {
    if (!hasValidProducts || validProductCount < 2) return '';

    if (hasPackProducts && totalSavingsByPiece > 0) {
      return 'Save \$${totalSavings.toStringAsFixed(2)} per unit or \$${totalSavingsByPiece.toStringAsFixed(2)} per piece';
    } else if (totalSavings > 0) {
      return 'Save \$${totalSavings.toStringAsFixed(2)} per unit (${savingsPercentage.toStringAsFixed(1)}%)';
    }

    return '';
  }

  Product? getBestValueForComparison(ComparisonMode mode) {
    switch (mode) {
      case ComparisonMode.pricePerPiece:
        return bestValueByPiece;
      case ComparisonMode.pricePerUnit:
        return bestValueProduct;
      case ComparisonMode.automatic:
        return hasPackProducts ? bestValueProduct : bestValueProduct;
    }
  }

  List<Product> getSortedProductsForComparison(ComparisonMode mode) {
    switch (mode) {
      case ComparisonMode.pricePerPiece:
        return sortedByBestValuePerPiece;
      case ComparisonMode.pricePerUnit:
      case ComparisonMode.automatic:
        return sortedByBestValue;
    }
  }
}
