class AppConstants {
  // App Info
  static const String appName = 'Everyday Helper';
  static const String appVersion = '1.0.0';

  // Route Names
  static const String homeRoute = '/';
  static const String priceComparisonRoute = '/price-comparison';
  static const String helpRoute = '/help';

  // Mathematics Routes
  static const String mathematicsRoute = '/mathematics';
  static const String basicCalculatorRoute = '/mathematics/basic-calculator';
  static const String scientificCalculatorRoute =
      '/mathematics/scientific-calculator';
  static const String statisticsCalculatorRoute =
      '/mathematics/statistics-calculator';
  static const String unitConverterRoute = '/mathematics/unit-converter';
  static const String percentageCalculatorRoute =
      '/mathematics/percentage-calculator';

  // Tax Calculator Routes
  static const String taxCalculatorRoute = '/tax-calculator';
  static const String taxInputRoute = '/tax-calculator/input';
  static const String taxResultsRoute = '/tax-calculator/results';
  static const String taxHelpRoute = '/tax-calculator/help';

  // Subnet Calculator Routes
  static const String subnetCalculatorRoute = '/subnet-calculator';

  // Exchange Rate Calculator Routes
  static const String exchangeRateRoute = '/exchange-rate';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Menu Items
  static const List<String> menuCategories = [
    'Calculations',
    'Productivity',
    'Utilities',
  ];

  // Price Comparison Constants
  static const List<String> commonUnits = [
    'g',
    'kg',
    'ml',
    'l',
    'pieces',
    'oz',
    'lb',
    'fl oz',
  ];

  static const String defaultUnit = 'ml';

  // Input Validation
  static const int maxProductNameLength = 50;
  static const double maxPrice = 999999.99;
  static const double maxQuantity = 999999.99;
  static const int maxProductsPerComparison = 10;
}
