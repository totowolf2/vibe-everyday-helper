import 'package:flutter/foundation.dart';
import '../../domain/models/unit_conversion.dart';
import '../../domain/models/calculation.dart';

class UnitConverterViewModel extends ChangeNotifier {
  UnitCategory _selectedCategory = UnitCategory.length;
  Unit? _fromUnit;
  Unit? _toUnit;
  String _inputValue = '';
  String _outputValue = '';
  String? _errorMessage;
  final List<UnitConversion> _conversions = [];
  final CalculationHistory _history = CalculationHistory();

  // Getters
  UnitCategory get selectedCategory => _selectedCategory;
  Unit? get fromUnit => _fromUnit;
  Unit? get toUnit => _toUnit;
  String get inputValue => _inputValue;
  String get outputValue => _outputValue;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  List<UnitConversion> get conversions => List.unmodifiable(_conversions);
  List<Calculation> get history => _history.calculations;

  List<Unit> get availableUnits =>
      UnitRegistry.getUnitsForCategory(_selectedCategory);
  bool get canConvert =>
      _fromUnit != null && _toUnit != null && _inputValue.isNotEmpty;

  // Category management
  void setCategory(UnitCategory category) {
    _selectedCategory = category;
    _fromUnit = null;
    _toUnit = null;
    _clearInputs();
    notifyListeners();
  }

  String getCategoryDisplayName(UnitCategory category) {
    return UnitRegistry.getCategoryDisplayName(category);
  }

  // Unit selection
  void setFromUnit(Unit unit) {
    _fromUnit = unit;
    _clearError();
    _performConversion();
    notifyListeners();
  }

  void setToUnit(Unit unit) {
    _toUnit = unit;
    _clearError();
    _performConversion();
    notifyListeners();
  }

  void swapUnits() {
    if (_fromUnit != null && _toUnit != null) {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _performConversion();
      notifyListeners();
    }
  }

  // Input handling
  void updateInputValue(String value) {
    _inputValue = value;
    _clearError();
    _performConversion();
    notifyListeners();
  }

  void _performConversion() {
    if (!canConvert) {
      _outputValue = '';
      return;
    }

    final inputNum = double.tryParse(_inputValue);
    if (inputNum == null) {
      _setError('Please enter a valid number');
      return;
    }

    try {
      final result = UnitRegistry.convert(inputNum, _fromUnit!, _toUnit!);
      _outputValue = _formatResult(result);

      // Create conversion record
      final conversion = UnitConversion(
        fromUnit: _fromUnit!,
        toUnit: _toUnit!,
        value: inputNum,
        result: result,
        timestamp: DateTime.now(),
      );

      // Add to conversions list
      _conversions.insert(0, conversion);
      if (_conversions.length > 20) {
        _conversions.removeLast();
      }

      // Add to history
      final historyItem = Calculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CalculationType.unitConversion,
        expression: '$inputNum ${_fromUnit!.symbol} to ${_toUnit!.symbol}',
        result: '${_formatResult(result)} ${_toUnit!.symbol}',
        timestamp: DateTime.now(),
        metadata: {
          'category': _selectedCategory.name,
          'fromUnit': _fromUnit!.id,
          'toUnit': _toUnit!.id,
          'inputValue': inputNum,
          'result': result,
        },
      );
      _history.addCalculation(historyItem);
    } catch (e) {
      _setError(e.toString());
    }
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else if (value >= 1000000000) {
      return value.toStringAsExponential(3);
    } else if (value >= 0.001) {
      return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
    } else {
      return value.toStringAsExponential(3);
    }
  }

  // Quick conversions
  void setQuickConversion(String fromUnitId, String toUnitId, String value) {
    final fromUnit = UnitRegistry.getUnitById(fromUnitId);
    final toUnit = UnitRegistry.getUnitById(toUnitId);

    if (fromUnit != null && toUnit != null) {
      setCategory(fromUnit.category);
      _fromUnit = fromUnit;
      _toUnit = toUnit;
      _inputValue = value;
      _performConversion();
      notifyListeners();
    }
  }

  // Common conversion suggestions
  List<Map<String, String>> getCommonConversions() {
    switch (_selectedCategory) {
      case UnitCategory.length:
        return [
          {'from': 'm', 'to': 'ft', 'label': 'Meters to Feet'},
          {'from': 'km', 'to': 'mi', 'label': 'Kilometers to Miles'},
          {'from': 'cm', 'to': 'in', 'label': 'Centimeters to Inches'},
        ];
      case UnitCategory.weight:
        return [
          {'from': 'kg', 'to': 'lb', 'label': 'Kilograms to Pounds'},
          {'from': 'g', 'to': 'oz', 'label': 'Grams to Ounces'},
        ];
      case UnitCategory.volume:
        return [
          {'from': 'l', 'to': 'gal', 'label': 'Liters to Gallons'},
          {'from': 'ml', 'to': 'fl_oz', 'label': 'Milliliters to Fluid Ounces'},
        ];
      case UnitCategory.temperature:
        return [
          {'from': 'c', 'to': 'f', 'label': 'Celsius to Fahrenheit'},
          {'from': 'f', 'to': 'c', 'label': 'Fahrenheit to Celsius'},
          {'from': 'c', 'to': 'k', 'label': 'Celsius to Kelvin'},
        ];
      case UnitCategory.area:
        return [
          {'from': 'm2', 'to': 'ft2', 'label': 'Square Meters to Square Feet'},
          {'from': 'km2', 'to': 'ac', 'label': 'Square Kilometers to Acres'},
        ];
      case UnitCategory.energy:
        return [
          {'from': 'j', 'to': 'cal', 'label': 'Joules to Calories'},
          {'from': 'kwh', 'to': 'btu', 'label': 'Kilowatt Hours to BTU'},
        ];
      case UnitCategory.power:
        return [
          {'from': 'w', 'to': 'hp', 'label': 'Watts to Horsepower'},
          {'from': 'kw', 'to': 'btu_h', 'label': 'Kilowatts to BTU/Hour'},
        ];
      case UnitCategory.time:
        return [
          {'from': 's', 'to': 'min', 'label': 'Seconds to Minutes'},
          {'from': 'h', 'to': 'd', 'label': 'Hours to Days'},
          {'from': 'ms', 'to': 's', 'label': 'Milliseconds to Seconds'},
        ];
      case UnitCategory.speed:
        return [
          {'from': 'm_s', 'to': 'km_h', 'label': 'Meters/sec to Km/hour'},
          {'from': 'mph', 'to': 'knot', 'label': 'Miles/hour to Knots'},
          {'from': 'km_h', 'to': 'mph', 'label': 'Km/hour to Miles/hour'},
        ];
      case UnitCategory.pressure:
        return [
          {'from': 'pa', 'to': 'bar', 'label': 'Pascals to Bar'},
          {'from': 'psi', 'to': 'atm', 'label': 'PSI to Atmospheres'},
          {'from': 'mmhg', 'to': 'kpa', 'label': 'mmHg to Kilopascals'},
        ];
    }
  }

  // Detailed conversion information
  Map<String, String> getConversionDetails() {
    if (!canConvert || _outputValue.isEmpty) return {};

    final inputNum = double.tryParse(_inputValue);
    if (inputNum == null) return {};

    return {
      'Input': '$inputNum ${_fromUnit!.symbol}',
      'Output': '$_outputValue ${_toUnit!.symbol}',
      'Category': getCategoryDisplayName(_selectedCategory),
      'From Unit': _fromUnit!.displayName,
      'To Unit': _toUnit!.displayName,
      'Conversion': '${_fromUnit!.symbol} → ${_toUnit!.symbol}',
    };
  }

  // Utility methods
  void clear() {
    _clearInputs();
    _clearError();
    notifyListeners();
  }

  void clearHistory() {
    _conversions.clear();
    _history.clearHistory();
    notifyListeners();
  }

  void _clearInputs() {
    _inputValue = '';
    _outputValue = '';
  }

  void _setError(String message) {
    _errorMessage = message;
    _outputValue = '';
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Validation
  String? validateInput(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter a value';
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    if (numValue.isInfinite || numValue.isNaN) {
      return 'Invalid number';
    }

    return null;
  }

  // Preset values for common conversions
  List<String> getPresetValues() {
    return ['1', '10', '100', '1000'];
  }

  // Format methods
  String formatConversionText(UnitConversion conversion) {
    return '${conversion.value} ${conversion.fromUnit.symbol} = ${conversion.formattedResult} ${conversion.toUnit.symbol}';
  }

  String getConversionFormula() {
    if (_fromUnit == null || _toUnit == null) return '';

    if (_fromUnit!.category == UnitCategory.temperature) {
      return 'Special temperature conversion formula';
    } else {
      return 'Value × ${_fromUnit!.conversionFactor} ÷ ${_toUnit!.conversionFactor}';
    }
  }

  // Category shortcuts
  void selectLengthCategory() => setCategory(UnitCategory.length);
  void selectWeightCategory() => setCategory(UnitCategory.weight);
  void selectVolumeCategory() => setCategory(UnitCategory.volume);
  void selectTemperatureCategory() => setCategory(UnitCategory.temperature);
  void selectAreaCategory() => setCategory(UnitCategory.area);
  void selectEnergyCategory() => setCategory(UnitCategory.energy);
  void selectPowerCategory() => setCategory(UnitCategory.power);
  void selectTimeCategory() => setCategory(UnitCategory.time);
  void selectSpeedCategory() => setCategory(UnitCategory.speed);
  void selectPressureCategory() => setCategory(UnitCategory.pressure);
}
