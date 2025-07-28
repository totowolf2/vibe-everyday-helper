import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/multiplier_formula.dart';
import '../../domain/models/calculation_step.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../data/datasources/frankfurter_api_datasource.dart';

class ExchangeRateViewModel extends ChangeNotifier {
  static const String _formulaKey = 'exchange_rate_formula';
  static const String _lastUsedCurrenciesKey = 'exchange_rate_last_currencies';

  final ExchangeRateRepository _repository;
  final SharedPreferences _prefs;

  ExchangeRate? _currentExchangeRate;
  Currency _baseCurrency = Currency.usd;
  Currency _targetCurrency = Currency.thb;
  double _baseAmount = 0.0;
  List<double> _multipliers = [];
  List<CalculationStep> _calculationSteps = [];
  MultiplierFormula? _currentFormula;

  final bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  DateTime? _lastRefresh;

  ExchangeRateViewModel({
    required ExchangeRateRepository repository,
    required SharedPreferences preferences,
  }) : _repository = repository,
       _prefs = preferences {
    _loadPersistedData();
  }

  ExchangeRate? get currentExchangeRate => _currentExchangeRate;
  Currency get baseCurrency => _baseCurrency;
  Currency get targetCurrency => _targetCurrency;
  double get baseAmount => _baseAmount;
  List<double> get multipliers => List.unmodifiable(_multipliers);
  List<CalculationStep> get calculationSteps =>
      List.unmodifiable(_calculationSteps);
  MultiplierFormula? get currentFormula => _currentFormula;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  DateTime? get lastRefresh => _lastRefresh;

  bool get hasValidInput => _baseAmount > 0 && _currentExchangeRate != null;
  bool get hasMultipliers => _multipliers.isNotEmpty;
  bool get canCalculate => hasValidInput;

  double get convertedAmount {
    if (!hasValidInput) return 0.0;
    return _currentExchangeRate!.convertAmount(_baseAmount);
  }

  double get finalAmount {
    if (!hasValidInput) return 0.0;

    double result = convertedAmount;
    for (final multiplier in _multipliers) {
      result *= multiplier;
    }
    return result;
  }

  String get exchangeRateDisplay {
    if (_currentExchangeRate == null) return '';
    return _currentExchangeRate!.displayRate;
  }

  String get lastRefreshDisplay {
    if (_lastRefresh == null) return 'Never updated';
    final now = DateTime.now();
    final difference = now.difference(_lastRefresh!);

    if (difference.inMinutes < 1) {
      return 'Just updated';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours}h ago';
    } else {
      return 'Updated ${difference.inDays}d ago';
    }
  }

  Future<void> initialize() async {
    await refreshExchangeRate();
  }

  Future<void> refreshExchangeRate() async {
    if (_isLoading || _isRefreshing) return;

    _setRefreshing(true);
    _clearError();

    try {
      final rate = await _repository.getExchangeRate(
        baseCurrency: _baseCurrency,
        targetCurrency: _targetCurrency,
      );

      _currentExchangeRate = rate;
      _lastRefresh = DateTime.now();
      _recalculateSteps();
    } on ExchangeRateException catch (e) {
      _setError(e.userFriendlyMessage);
    } catch (e) {
      _setError('Failed to refresh exchange rate. Please try again.');
    } finally {
      _setRefreshing(false);
    }
  }

  Future<void> swapCurrencies() async {
    final temp = _baseCurrency;
    _baseCurrency = _targetCurrency;
    _targetCurrency = temp;

    await _persistCurrencies();
    await refreshExchangeRate();
    notifyListeners();
  }

  Future<void> setBaseCurrency(Currency currency) async {
    if (_baseCurrency == currency) return;

    _baseCurrency = currency;
    await _persistCurrencies();
    await refreshExchangeRate();
  }

  Future<void> setTargetCurrency(Currency currency) async {
    if (_targetCurrency == currency) return;

    _targetCurrency = currency;
    await _persistCurrencies();
    await refreshExchangeRate();
  }

  void setBaseAmount(double amount) {
    if (_baseAmount == amount) return;

    _baseAmount = amount;
    _recalculateSteps();
    _saveCurrentFormula();
    notifyListeners();
  }

  void addMultiplier(double multiplier) {
    if (multiplier <= 0) {
      _setError('Multiplier must be greater than zero');
      return;
    }

    _clearError();
    _multipliers.add(multiplier);
    _recalculateSteps();
    _saveCurrentFormula();
    notifyListeners();
  }

  void updateMultiplier(int index, double newValue) {
    if (index < 0 || index >= _multipliers.length) {
      _setError('Invalid multiplier index');
      return;
    }

    if (newValue <= 0) {
      _setError('Multiplier must be greater than zero');
      return;
    }

    _clearError();
    _multipliers[index] = newValue;
    _recalculateSteps();
    _saveCurrentFormula();
    notifyListeners();
  }

  void removeMultiplier(int index) {
    if (index < 0 || index >= _multipliers.length) {
      _setError('Invalid multiplier index');
      return;
    }

    _clearError();
    _multipliers.removeAt(index);
    _recalculateSteps();
    _saveCurrentFormula();
    notifyListeners();
  }

  void clearMultipliers() {
    _multipliers.clear();
    _recalculateSteps();
    _saveCurrentFormula();
    notifyListeners();
  }

  void loadFormula(MultiplierFormula formula) {
    _baseCurrency = formula.baseCurrency;
    _targetCurrency = formula.targetCurrency;
    _baseAmount = formula.baseAmount;
    _multipliers = List.from(formula.multipliers);
    _currentFormula = formula.withUpdatedUsage();

    refreshExchangeRate();
    _saveCurrentFormula();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _recalculateSteps() {
    _calculationSteps.clear();

    if (!hasValidInput) {
      notifyListeners();
      return;
    }

    final steps = <CalculationStep>[];
    double currentValue = _baseAmount;

    final convertedAmount = _currentExchangeRate!.convertAmount(currentValue);
    steps.add(
      CalculationStep.exchangeConversion(
        inputValue: currentValue,
        outputValue: convertedAmount,
        fromCurrency: _baseCurrency,
        toCurrency: _targetCurrency,
        rate: _currentExchangeRate!.rate,
      ),
    );

    currentValue = convertedAmount;

    for (int i = 0; i < _multipliers.length; i++) {
      final multiplier = _multipliers[i];
      steps.add(
        CalculationStep.multiplication(
          inputValue: currentValue,
          multiplier: multiplier,
          currency: _targetCurrency,
        ),
      );
      currentValue = currentValue * multiplier;
    }

    _calculationSteps = steps;
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> _loadPersistedData() async {
    try {
      await _loadLastUsedCurrencies();
      await _loadSavedFormula();
    } catch (e) {
      // Ignore loading errors, use defaults
    }
  }

  Future<void> _loadLastUsedCurrencies() async {
    final data = _prefs.getString(_lastUsedCurrenciesKey);
    if (data == null) return;

    try {
      final Map<String, dynamic> currencies = json.decode(data);
      final baseCurrency = Currency.fromCode(currencies['base'] ?? '');
      final targetCurrency = Currency.fromCode(currencies['target'] ?? '');

      if (baseCurrency != null) _baseCurrency = baseCurrency;
      if (targetCurrency != null) _targetCurrency = targetCurrency;
    } catch (e) {
      // Ignore parsing errors, use defaults
    }
  }

  Future<void> _loadSavedFormula() async {
    final data = _prefs.getString(_formulaKey);
    if (data == null) return;

    try {
      final Map<String, dynamic> formulaData = json.decode(data);
      final formula = MultiplierFormula.fromMap(formulaData);

      if (formula.isValid) {
        _baseAmount = formula.baseAmount;
        _multipliers = List.from(formula.multipliers);
        _currentFormula = formula;
      }
    } catch (e) {
      // Ignore parsing errors, use defaults
    }
  }

  Future<void> _persistCurrencies() async {
    try {
      final data = json.encode({
        'base': _baseCurrency.code,
        'target': _targetCurrency.code,
      });
      await _prefs.setString(_lastUsedCurrenciesKey, data);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  void _saveCurrentFormula() {
    try {
      final formula = MultiplierFormula.create(
        baseCurrency: _baseCurrency,
        targetCurrency: _targetCurrency,
        baseAmount: _baseAmount,
        multipliers: _multipliers,
      );

      final data = json.encode(formula.toMap());
      _prefs.setString(_formulaKey, data);
      _currentFormula = formula;
    } catch (e) {
      // Ignore persistence errors
    }
  }
}
