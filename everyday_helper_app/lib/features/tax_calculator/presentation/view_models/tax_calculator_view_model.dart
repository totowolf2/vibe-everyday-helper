import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../domain/models/tax_input.dart';
import '../../domain/models/tax_result.dart';
import '../../domain/models/deduction.dart';
import '../../domain/use_cases/thai_tax_calculator.dart';

class TaxCalculatorViewModel extends ChangeNotifier {
  static final Decimal _zero = Decimal.fromInt(0);

  final ThaiTaxCalculator _taxCalculator = ThaiTaxCalculator();

  // Current input state
  TaxInput _currentInput = TaxInput();
  TaxResult? _currentResult;
  List<TaxResult> _calculationHistory = [];
  List<Deduction> _availableDeductions = [];
  String? _errorMessage;
  bool _isCalculating = false;
  bool _isLoading = false;

  // Tab state
  int _currentTabIndex = 0;

  // Form state
  final Map<String, String> _formErrors = {};
  bool _isDirty = false;

  // Getters
  TaxInput get currentInput => _currentInput;
  TaxResult? get currentResult => _currentResult;
  List<TaxResult> get calculationHistory =>
      List.unmodifiable(_calculationHistory);
  List<Deduction> get availableDeductions =>
      List.unmodifiable(_availableDeductions);
  String? get errorMessage => _errorMessage;
  bool get isCalculating => _isCalculating;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  bool get hasResult => _currentResult != null && !_currentResult!.hasError;
  bool get isDirty => _isDirty;
  int get currentTabIndex => _currentTabIndex;
  Map<String, String> get formErrors => Map.unmodifiable(_formErrors);

  // Calculated properties
  Decimal get estimatedTax => _currentResult?.calculatedTax ?? _zero;
  Decimal get effectiveTaxRate => _currentResult?.effectiveTaxRate ?? _zero;
  Decimal get marginalTaxRate => _currentResult?.marginalTaxRate ?? _zero;
  String get taxSummary =>
      _currentResult?.summaryText ?? 'No calculation performed';

  TaxCalculatorViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      _availableDeductions = Deduction.standardThaiDeductions;
      await _loadCalculationHistory();
      await _loadLastInput();
    } catch (e) {
      _setError('Failed to initialize tax calculator: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Tab navigation
  void setCurrentTab(int index) {
    if (index != _currentTabIndex) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  // Input management
  void updateAnnualIncome(String value) {
    try {
      final income = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(annualIncome: income));
      _clearFieldError('annualIncome');
    } catch (e) {
      _setFieldError('annualIncome', 'Invalid income amount');
    }
  }

  void updateSpouseAllowance(String value) {
    try {
      final allowance = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(spouseAllowance: allowance));
      _clearFieldError('spouseAllowance');
    } catch (e) {
      _setFieldError('spouseAllowance', 'Invalid allowance amount');
    }
  }

  void updateNumberOfChildren(int children) {
    _updateInput(_currentInput.copyWith(numberOfChildren: children));
    _clearFieldError('numberOfChildren');
  }

  void updateInsurancePremium(String value) {
    try {
      final premium = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(insurancePremium: premium));
      _clearFieldError('insurancePremium');
    } catch (e) {
      _setFieldError('insurancePremium', 'Invalid premium amount');
    }
  }

  void updateRetirementFund(String value) {
    try {
      final fund = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(retirementFund: fund));
      _clearFieldError('retirementFund');
    } catch (e) {
      _setFieldError('retirementFund', 'Invalid fund amount');
    }
  }

  void updateMortgageInterest(String value) {
    try {
      final interest = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(mortgageInterest: interest));
      _clearFieldError('mortgageInterest');
    } catch (e) {
      _setFieldError('mortgageInterest', 'Invalid interest amount');
    }
  }

  void updateEducationDonation(String value) {
    try {
      final donation = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(educationDonation: donation));
      _clearFieldError('educationDonation');
    } catch (e) {
      _setFieldError('educationDonation', 'Invalid donation amount');
    }
  }

  void updateGeneralDonation(String value) {
    try {
      final donation = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(generalDonation: donation));
      _clearFieldError('generalDonation');
    } catch (e) {
      _setFieldError('generalDonation', 'Invalid donation amount');
    }
  }

  void updateSocialSecurityContribution(String value) {
    try {
      final contribution = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(
        _currentInput.copyWith(socialSecurityContribution: contribution),
      );
      _clearFieldError('socialSecurityContribution');
    } catch (e) {
      _setFieldError(
        'socialSecurityContribution',
        'Invalid contribution amount',
      );
    }
  }

  void updateProvidentFund(String value) {
    try {
      final fund = value.isEmpty ? _zero : Decimal.parse(value);
      _updateInput(_currentInput.copyWith(providentFund: fund));
      _clearFieldError('providentFund');
    } catch (e) {
      _setFieldError('providentFund', 'Invalid fund amount');
    }
  }

  void _updateInput(TaxInput newInput) {
    _currentInput = newInput;
    _isDirty = true;
    _clearError();
    notifyListeners();
  }

  // Calculation
  Future<void> calculateTax() async {
    if (_isCalculating) return;

    _setCalculating(true);
    _clearError();
    _formErrors.clear();

    try {
      // Validate input
      if (!_validateInput()) {
        return;
      }

      // Perform calculation
      final result = _taxCalculator.calculateTax(_currentInput);

      if (result.hasError) {
        _setError(result.errorMessage!);
      } else {
        _currentResult = result;
        _addToHistory(result);
        await _saveLastInput();
        await _saveCalculationHistory();
        _isDirty = false;
      }
    } catch (e) {
      _setError('Calculation failed: ${e.toString()}');
    } finally {
      _setCalculating(false);
    }
  }

  bool _validateInput() {
    bool isValid = true;

    if (_currentInput.annualIncome <= _zero) {
      _setFieldError('annualIncome', 'Annual income is required');
      isValid = false;
    }

    if (_currentInput.annualIncome > Decimal.parse('50000000')) {
      _setFieldError('annualIncome', 'Income exceeds maximum allowed');
      isValid = false;
    }

    if (_currentInput.spouseAllowance < _zero) {
      _setFieldError('spouseAllowance', 'Spouse allowance cannot be negative');
      isValid = false;
    }

    if (_currentInput.spouseAllowance > Decimal.fromInt(60000)) {
      _setFieldError(
        'spouseAllowance',
        'Spouse allowance cannot exceed 60,000 THB',
      );
      isValid = false;
    }

    if (_currentInput.numberOfChildren < 0 ||
        _currentInput.numberOfChildren > 20) {
      _setFieldError(
        'numberOfChildren',
        'Number of children must be between 0 and 20',
      );
      isValid = false;
    }

    return isValid;
  }

  // Reset and clear
  void resetForm() {
    _currentInput = TaxInput();
    _currentResult = null;
    _formErrors.clear();
    _isDirty = false;
    _clearError();
    notifyListeners();
  }

  void clearHistory() {
    _calculationHistory.clear();
    _saveCalculationHistory();
    notifyListeners();
  }

  // History management
  void _addToHistory(TaxResult result) {
    _calculationHistory.insert(0, result);

    // Keep only last 50 calculations
    if (_calculationHistory.length > 50) {
      _calculationHistory = _calculationHistory.take(50).toList();
    }
  }

  void useHistoryResult(TaxResult result) {
    if (result.hasError) return;

    _currentInput = TaxInput(
      annualIncome: result.grossIncome,
      spouseAllowance:
          result.totalAllowances -
          Decimal.fromInt(60000) -
          (Decimal.fromInt(30000) *
              Decimal.fromInt(_currentInput.numberOfChildren)),
      // Note: We can't perfectly reconstruct all individual deductions from the result
      // This is a limitation of the history feature
    );

    _currentResult = result;
    _isDirty = true;
    _clearError();
    notifyListeners();
  }

  // Error handling
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setFieldError(String field, String message) {
    _formErrors[field] = message;
    notifyListeners();
  }

  void _clearFieldError(String field) {
    _formErrors.remove(field);
    notifyListeners();
  }

  // Loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setCalculating(bool calculating) {
    _isCalculating = calculating;
    notifyListeners();
  }

  // Persistence
  Future<void> _saveLastInput() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'tax_calculator_last_input',
        jsonEncode(_currentInput.toMap()),
      );
    } catch (e) {
      debugPrint('Failed to save last input: $e');
    }
  }

  Future<void> _loadLastInput() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inputJson = prefs.getString('tax_calculator_last_input');

      if (inputJson != null) {
        final inputMap = jsonDecode(inputJson) as Map<String, dynamic>;
        _currentInput = TaxInput.fromMap(inputMap);
      }
    } catch (e) {
      debugPrint('Failed to load last input: $e');
    }
  }

  Future<void> _saveCalculationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _calculationHistory
          .map((result) => result.toMap())
          .toList();
      await prefs.setString('tax_calculator_history', jsonEncode(historyJson));
    } catch (e) {
      debugPrint('Failed to save calculation history: $e');
    }
  }

  Future<void> _loadCalculationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('tax_calculator_history');

      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List<dynamic>;
        _calculationHistory = historyList
            .map((item) => TaxResult.fromMap(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load calculation history: $e');
    }
  }

  // Utility methods
  String formatCurrency(Decimal amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String formatPercentage(Decimal percentage) {
    return percentage.toStringAsFixed(2);
  }

  // Auto-calculate for live preview
  void updateInputAndCalculate() {
    if (_currentInput.isValid && _currentInput.annualIncome > _zero) {
      // Perform a quick calculation for preview (without saving)
      final result = _taxCalculator.calculateTax(_currentInput);
      if (!result.hasError) {
        _currentResult = result;
        notifyListeners();
      }
    }
  }
}
