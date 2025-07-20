import 'package:flutter/foundation.dart';
import '../../domain/models/calculation.dart';

enum PercentageCalculationType {
  percentageOf,
  percentageIncrease,
  percentageDecrease,
  whatPercent,
  tip,
  discount,
  tax,
  markupMargin,
}

class PercentageCalculation {
  final PercentageCalculationType type;
  final double value1;
  final double value2;
  final double result;
  final String description;
  final DateTime timestamp;

  PercentageCalculation({
    required this.type,
    required this.value1,
    required this.value2,
    required this.result,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedResult {
    return result.toStringAsFixed(2);
  }
}

class PercentageCalculatorViewModel extends ChangeNotifier {
  PercentageCalculationType _currentType = PercentageCalculationType.percentageOf;
  String _value1Text = '';
  String _value2Text = '';
  String _result = '';
  String? _errorMessage;
  final List<PercentageCalculation> _calculations = [];
  final CalculationHistory _history = CalculationHistory();

  // Getters
  PercentageCalculationType get currentType => _currentType;
  String get value1Text => _value1Text;
  String get value2Text => _value2Text;
  String get result => _result;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  List<PercentageCalculation> get calculations => List.unmodifiable(_calculations);
  List<Calculation> get history => _history.calculations;

  // Type management
  void setCalculationType(PercentageCalculationType type) {
    _currentType = type;
    _clearInputs();
    notifyListeners();
  }

  String getTypeTitle(PercentageCalculationType type) {
    switch (type) {
      case PercentageCalculationType.percentageOf:
        return 'Percentage of Value';
      case PercentageCalculationType.percentageIncrease:
        return 'Percentage Increase';
      case PercentageCalculationType.percentageDecrease:
        return 'Percentage Decrease';
      case PercentageCalculationType.whatPercent:
        return 'What Percent';
      case PercentageCalculationType.tip:
        return 'Tip Calculator';
      case PercentageCalculationType.discount:
        return 'Discount Calculator';
      case PercentageCalculationType.tax:
        return 'Tax Calculator';
      case PercentageCalculationType.markupMargin:
        return 'Markup/Margin';
    }
  }

  String getTypeDescription(PercentageCalculationType type) {
    switch (type) {
      case PercentageCalculationType.percentageOf:
        return 'Calculate X% of a value';
      case PercentageCalculationType.percentageIncrease:
        return 'Calculate value after % increase';
      case PercentageCalculationType.percentageDecrease:
        return 'Calculate value after % decrease';
      case PercentageCalculationType.whatPercent:
        return 'Find what % one value is of another';
      case PercentageCalculationType.tip:
        return 'Calculate tip amount and total';
      case PercentageCalculationType.discount:
        return 'Calculate discount amount and final price';
      case PercentageCalculationType.tax:
        return 'Calculate tax amount and total';
      case PercentageCalculationType.markupMargin:
        return 'Calculate markup and profit margin';
    }
  }

  String getValue1Label(PercentageCalculationType type) {
    switch (type) {
      case PercentageCalculationType.percentageOf:
        return 'Percentage (%)';
      case PercentageCalculationType.percentageIncrease:
      case PercentageCalculationType.percentageDecrease:
        return 'Original Value';
      case PercentageCalculationType.whatPercent:
        return 'Value';
      case PercentageCalculationType.tip:
        return 'Bill Amount';
      case PercentageCalculationType.discount:
        return 'Original Price';
      case PercentageCalculationType.tax:
        return 'Price Before Tax';
      case PercentageCalculationType.markupMargin:
        return 'Cost Price';
    }
  }

  String getValue2Label(PercentageCalculationType type) {
    switch (type) {
      case PercentageCalculationType.percentageOf:
        return 'Value';
      case PercentageCalculationType.percentageIncrease:
      case PercentageCalculationType.percentageDecrease:
        return 'Percentage (%)';
      case PercentageCalculationType.whatPercent:
        return 'Total Value';
      case PercentageCalculationType.tip:
        return 'Tip Percentage (%)';
      case PercentageCalculationType.discount:
        return 'Discount Percentage (%)';
      case PercentageCalculationType.tax:
        return 'Tax Rate (%)';
      case PercentageCalculationType.markupMargin:
        return 'Selling Price';
    }
  }

  // Input handling
  void updateValue1(String value) {
    _value1Text = value;
    _clearError();
    _calculateResult();
    notifyListeners();
  }

  void updateValue2(String value) {
    _value2Text = value;
    _clearError();
    _calculateResult();
    notifyListeners();
  }

  void _calculateResult() {
    if (_value1Text.isEmpty || _value2Text.isEmpty) {
      _result = '';
      return;
    }

    final value1 = double.tryParse(_value1Text);
    final value2 = double.tryParse(_value2Text);

    if (value1 == null || value2 == null) {
      _setError('Please enter valid numbers');
      return;
    }

    try {
      final calculation = _performCalculation(_currentType, value1, value2);
      _result = calculation.formattedResult;
      
      // Add to calculations list for display
      _calculations.insert(0, calculation);
      if (_calculations.length > 20) {
        _calculations.removeLast();
      }

      // Add to history
      final historyItem = Calculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CalculationType.percentage,
        expression: calculation.description,
        result: calculation.formattedResult,
        timestamp: DateTime.now(),
        metadata: {
          'calculationType': _currentType.name,
          'value1': value1,
          'value2': value2,
        },
      );
      _history.addCalculation(historyItem);

    } catch (e) {
      _setError(e.toString());
    }
  }

  PercentageCalculation _performCalculation(
    PercentageCalculationType type, 
    double value1, 
    double value2
  ) {
    double result;
    String description;

    switch (type) {
      case PercentageCalculationType.percentageOf:
        result = (value1 / 100) * value2;
        description = '$value1% of $value2 = $result';
        break;

      case PercentageCalculationType.percentageIncrease:
        result = value1 + (value1 * value2 / 100);
        description = '$value1 + $value2% = $result';
        break;

      case PercentageCalculationType.percentageDecrease:
        result = value1 - (value1 * value2 / 100);
        description = '$value1 - $value2% = $result';
        break;

      case PercentageCalculationType.whatPercent:
        if (value2 == 0) throw Exception('Cannot divide by zero');
        result = (value1 / value2) * 100;
        description = '$value1 is ${result.toStringAsFixed(2)}% of $value2';
        break;

      case PercentageCalculationType.tip:
        final tipAmount = value1 * value2 / 100;
        result = value1 + tipAmount;
        description = 'Bill: $value1, Tip ($value2%): ${tipAmount.toStringAsFixed(2)}, Total: $result';
        break;

      case PercentageCalculationType.discount:
        final discountAmount = value1 * value2 / 100;
        result = value1 - discountAmount;
        description = 'Original: $value1, Discount ($value2%): ${discountAmount.toStringAsFixed(2)}, Final: $result';
        break;

      case PercentageCalculationType.tax:
        final taxAmount = value1 * value2 / 100;
        result = value1 + taxAmount;
        description = 'Before tax: $value1, Tax ($value2%): ${taxAmount.toStringAsFixed(2)}, Total: $result';
        break;

      case PercentageCalculationType.markupMargin:
        if (value1 == 0) throw Exception('Cost price cannot be zero');
        final profit = value2 - value1;
        final markupPercent = (profit / value1) * 100;
        final marginPercent = (profit / value2) * 100;
        result = markupPercent;
        description = 'Cost: $value1, Selling: $value2, Markup: ${markupPercent.toStringAsFixed(2)}%, Margin: ${marginPercent.toStringAsFixed(2)}%';
        break;
    }

    return PercentageCalculation(
      type: type,
      value1: value1,
      value2: value2,
      result: result,
      description: description,
      timestamp: DateTime.now(),
    );
  }

  // Quick calculation methods
  Map<String, String> getDetailedResults() {
    if (_value1Text.isEmpty || _value2Text.isEmpty || hasError) {
      return {};
    }

    final value1 = double.tryParse(_value1Text);
    final value2 = double.tryParse(_value2Text);

    if (value1 == null || value2 == null) return {};

    try {
      switch (_currentType) {
        case PercentageCalculationType.tip:
          final tipAmount = value1 * value2 / 100;
          final total = value1 + tipAmount;
          return {
            'Bill Amount': value1.toStringAsFixed(2),
            'Tip Percentage': '$value2%',
            'Tip Amount': tipAmount.toStringAsFixed(2),
            'Total Amount': total.toStringAsFixed(2),
          };

        case PercentageCalculationType.discount:
          final discountAmount = value1 * value2 / 100;
          final finalPrice = value1 - discountAmount;
          final savedAmount = discountAmount;
          return {
            'Original Price': value1.toStringAsFixed(2),
            'Discount': '$value2%',
            'Discount Amount': discountAmount.toStringAsFixed(2),
            'You Save': savedAmount.toStringAsFixed(2),
            'Final Price': finalPrice.toStringAsFixed(2),
          };

        case PercentageCalculationType.tax:
          final taxAmount = value1 * value2 / 100;
          final total = value1 + taxAmount;
          return {
            'Price Before Tax': value1.toStringAsFixed(2),
            'Tax Rate': '$value2%',
            'Tax Amount': taxAmount.toStringAsFixed(2),
            'Total Price': total.toStringAsFixed(2),
          };

        case PercentageCalculationType.markupMargin:
          if (value1 == 0) return {};
          final profit = value2 - value1;
          final markupPercent = (profit / value1) * 100;
          final marginPercent = (profit / value2) * 100;
          return {
            'Cost Price': value1.toStringAsFixed(2),
            'Selling Price': value2.toStringAsFixed(2),
            'Profit': profit.toStringAsFixed(2),
            'Markup': '${markupPercent.toStringAsFixed(2)}%',
            'Margin': '${marginPercent.toStringAsFixed(2)}%',
          };

        default:
          return {
            'Result': _result,
          };
      }
    } catch (e) {
      return {};
    }
  }

  // Utility methods
  void clear() {
    _clearInputs();
    _clearError();
    notifyListeners();
  }

  void clearHistory() {
    _calculations.clear();
    _history.clearHistory();
    notifyListeners();
  }

  void _clearInputs() {
    _value1Text = '';
    _value2Text = '';
    _result = '';
  }

  void _setError(String message) {
    _errorMessage = message;
    _result = '';
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Validation
  String? validateInput(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    if (numValue < 0) {
      return '$fieldName cannot be negative';
    }

    if (_currentType == PercentageCalculationType.markupMargin && 
        fieldName.contains('Cost') && numValue == 0) {
      return 'Cost price cannot be zero';
    }

    return null;
  }

  // Common percentage calculations
  static const List<PercentageCalculationType> commonTypes = [
    PercentageCalculationType.tip,
    PercentageCalculationType.discount,
    PercentageCalculationType.tax,
    PercentageCalculationType.percentageOf,
  ];

  static const List<PercentageCalculationType> allTypes = [
    PercentageCalculationType.percentageOf,
    PercentageCalculationType.percentageIncrease,
    PercentageCalculationType.percentageDecrease,
    PercentageCalculationType.whatPercent,
    PercentageCalculationType.tip,
    PercentageCalculationType.discount,
    PercentageCalculationType.tax,
    PercentageCalculationType.markupMargin,
  ];
}