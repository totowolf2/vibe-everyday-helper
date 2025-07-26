import 'package:flutter/foundation.dart';
import '../../domain/models/statistical_data_set.dart';
import '../../domain/models/calculation.dart';

class StatisticsCalculatorViewModel extends ChangeNotifier {
  String _inputText = '';
  StatisticalDataSet? _dataSet;
  StatisticalResult? _result;
  String? _errorMessage;
  final CalculationHistory _history = CalculationHistory();

  // Getters
  String get inputText => _inputText;
  StatisticalDataSet? get dataSet => _dataSet;
  StatisticalResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  bool get hasData => _dataSet != null && _dataSet!.isNotEmpty;
  bool get hasResult => _result != null;
  List<Calculation> get calculations => _history.calculations;

  // Input handling
  void updateInput(String input) {
    _inputText = input;
    _clearError();
    notifyListeners();
  }

  void calculateStatistics() {
    _clearError();

    if (_inputText.trim().isEmpty) {
      _setError('Please enter numbers separated by commas');
      notifyListeners();
      return;
    }

    try {
      _dataSet = StatisticalDataSet.fromString(_inputText);

      if (_dataSet!.isEmpty) {
        _setError(
          'No valid numbers found. Please enter numbers separated by commas.',
        );
        notifyListeners();
        return;
      }

      if (_dataSet!.count < 1) {
        _setError('At least one number is required for statistical analysis.');
        notifyListeners();
        return;
      }

      _result = StatisticalResult.fromDataSet(_dataSet!);

      // Add to history
      final calculation = Calculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CalculationType.statistics,
        expression: 'Statistics for: $_inputText',
        result:
            'Count: ${_dataSet!.count}, Mean: ${_dataSet!.mean.toStringAsFixed(2)}',
        timestamp: DateTime.now(),
        metadata: {
          'count': _dataSet!.count,
          'mean': _dataSet!.mean,
          'median': _dataSet!.median,
          'standardDeviation': _dataSet!.standardDeviation,
        },
      );

      _history.addCalculation(calculation);
    } catch (e) {
      _setError('Error calculating statistics: ${e.toString()}');
    }

    notifyListeners();
  }

  void clear() {
    _inputText = '';
    _dataSet = null;
    _result = null;
    _clearError();
    notifyListeners();
  }

  void clearHistory() {
    _history.clearHistory();
    notifyListeners();
  }

  void addSampleData() {
    _inputText = '12, 15, 18, 20, 22, 25, 28, 30, 32, 35';
    _clearError();
    notifyListeners();
  }

  // Validation
  String? validateInput(String input) {
    if (input.trim().isEmpty) {
      return 'Please enter at least one number';
    }

    final testDataSet = StatisticalDataSet.fromString(input);
    if (testDataSet.isEmpty) {
      return 'No valid numbers found. Use format: 1, 2, 3, 4, 5';
    }

    if (testDataSet.count > 10000) {
      return 'Too many numbers. Maximum 10,000 values allowed.';
    }

    return null;
  }

  // Formatting helpers
  String formatValue(double value, {int decimals = 2}) {
    if (value.isNaN || value.isInfinite) {
      return 'N/A';
    }
    return value.toStringAsFixed(decimals);
  }

  String formatList(List<double> values, {int decimals = 2}) {
    if (values.isEmpty) {
      return 'N/A';
    }
    return values.map((v) => formatValue(v, decimals: decimals)).join(', ');
  }

  Map<String, String> getFormattedResults() {
    if (_result == null || _dataSet == null) {
      return {};
    }

    return {
      'Count': _dataSet!.count.toString(),
      'Sum': formatValue(_dataSet!.sum),
      'Mean': formatValue(_dataSet!.mean),
      'Median': formatValue(_dataSet!.median),
      'Mode': formatList(_dataSet!.mode),
      'Range': formatValue(_dataSet!.range),
      'Minimum': formatValue(_dataSet!.minimum),
      'Maximum': formatValue(_dataSet!.maximum),
      'Variance': formatValue(_dataSet!.variance),
      'Standard Deviation': formatValue(_dataSet!.standardDeviation),
      'Standard Error': formatValue(_dataSet!.standardError),
      'Q1 (25th percentile)': formatValue(_dataSet!.q1),
      'Q3 (75th percentile)': formatValue(_dataSet!.q3),
      'IQR': formatValue(_dataSet!.iqr),
      'Skewness': formatValue(_dataSet!.skewness, decimals: 4),
      'Kurtosis': formatValue(_dataSet!.kurtosis, decimals: 4),
      'Coefficient of Variation':
          '${formatValue(_dataSet!.coefficientOfVariation)}%',
    };
  }

  List<String> getOutliers() {
    if (_dataSet == null) return [];
    return _dataSet!.outliers.map((v) => formatValue(v)).toList();
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

  // Export functionality
  String exportResults() {
    if (_result == null || _dataSet == null) {
      return 'No data to export';
    }

    final buffer = StringBuffer();
    buffer.writeln('Statistical Analysis Results');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('');
    buffer.writeln('Input Data: $_inputText');
    buffer.writeln('');
    buffer.writeln('Results:');

    final results = getFormattedResults();
    results.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    final outliers = getOutliers();
    if (outliers.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Outliers: ${outliers.join(', ')}');
    }

    return buffer.toString();
  }
}
