import 'package:flutter/foundation.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../domain/models/calculation.dart';
import '../../domain/models/calculator_operation.dart';

class BasicCalculatorViewModel extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  String? _errorMessage;
  bool _isLastInputEquals = false;
  final CalculationHistory _history = CalculationHistory();

  // Getters
  String get expression => _expression;
  String get result => _result;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  List<Calculation> get calculations => _history.calculations;
  List<String> get historyStrings => _history.calculations
      .map((calc) => '${calc.expression} = ${calc.result}')
      .toList();

  // Input handling
  void inputNumber(String number) {
    _clearError();

    if (_isLastInputEquals) {
      _expression = '';
      _isLastInputEquals = false;
    }

    if (_expression == '0' && number != '.') {
      _expression = number;
    } else {
      _expression += number;
    }

    _evaluateExpression();
    notifyListeners();
  }

  void inputOperator(String operator) {
    _clearError();

    if (_isLastInputEquals) {
      _expression = _result;
      _isLastInputEquals = false;
    }

    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = '-';
      }
    } else if (_isLastCharOperator()) {
      // Replace the last operator
      _expression = _expression.substring(0, _expression.length - 1) + operator;
    } else {
      _expression += operator;
    }

    notifyListeners();
  }

  void inputDecimal() {
    _clearError();

    if (_isLastInputEquals) {
      _expression = '0.';
      _isLastInputEquals = false;
    } else if (_expression.isEmpty || _isLastCharOperator()) {
      _expression += '0.';
    } else if (!_getCurrentNumber().contains('.')) {
      _expression += '.';
    }

    notifyListeners();
  }

  void inputParenthesis() {
    _clearError();

    if (_isLastInputEquals) {
      _expression = '';
      _isLastInputEquals = false;
    }

    final openCount = _expression.split('(').length - 1;
    final closeCount = _expression.split(')').length - 1;

    if (_expression.isEmpty ||
        _isLastCharOperator() ||
        _expression.endsWith('(')) {
      _expression += '(';
    } else if (openCount > closeCount) {
      _expression += ')';
    } else {
      _expression += '*(';
    }

    _evaluateExpression();
    notifyListeners();
  }

  void calculate() {
    _clearError();

    if (_expression.isEmpty) {
      return;
    }

    try {
      final sanitizedExpression = OperationValidator.sanitizeInput(_expression);
      final validationError = OperationValidator.validateExpression(
        sanitizedExpression,
      );

      if (validationError != null) {
        _setError(validationError);
        notifyListeners();
        return;
      }

      final parser = ShuntingYardParser();
      final exp = parser.parse(sanitizedExpression);
      final contextModel = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, contextModel);

      if (OperationValidator.isDivisionByZero(sanitizedExpression, result)) {
        _setError('Cannot divide by zero');
        notifyListeners();
        return;
      }

      final formattedResult = _formatResult(result);
      _result = formattedResult;

      // Add to history
      final calculation = Calculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: CalculationType.basic,
        expression: _expression,
        result: formattedResult,
        timestamp: DateTime.now(),
      );

      _history.addCalculation(calculation);
      _isLastInputEquals = true;
    } catch (e) {
      _setError('Invalid expression');
    }

    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '0';
    _clearError();
    _isLastInputEquals = false;
    notifyListeners();
  }

  void clearEntry() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      if (_expression.isEmpty) {
        _result = '0';
      } else {
        _evaluateExpression();
      }
    }
    _clearError();
    notifyListeners();
  }

  void negate() {
    _clearError();

    if (_expression.isEmpty || _expression == '0') {
      return;
    }

    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      _expression = '-$_expression';
    }

    _evaluateExpression();
    notifyListeners();
  }

  void clearHistory() {
    _history.clearHistory();
    notifyListeners();
  }

  void useHistoryResult(String historyExpression) {
    final parts = historyExpression.split(' = ');
    if (parts.length == 2) {
      _expression = parts[1];
      _result = parts[1];
      _clearError();
      _isLastInputEquals = false;
      notifyListeners();
    }
  }

  // Helper methods
  void _evaluateExpression() {
    if (_expression.isEmpty || _isLastCharOperator()) {
      _result = '0';
      return;
    }

    try {
      final sanitizedExpression = OperationValidator.sanitizeInput(_expression);
      final parser = ShuntingYardParser();
      final exp = parser.parse(sanitizedExpression);
      final contextModel = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, contextModel);

      if (!result.isFinite) {
        _result = '0';
        return;
      }

      _result = _formatResult(result);
    } catch (e) {
      // Don't show error during typing, just keep previous result
    }
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      final formatted = value.toStringAsFixed(10);
      return formatted.replaceAll(RegExp(r'\.?0+$'), '');
    }
  }

  bool _isLastCharOperator() {
    if (_expression.isEmpty) return false;
    final lastChar = _expression.substring(_expression.length - 1);
    return ['+', '-', '*', '/', '^'].contains(lastChar);
  }

  String _getCurrentNumber() {
    if (_expression.isEmpty) return '';

    final operators = ['+', '-', '*', '/', '(', ')'];
    int lastOperatorIndex = -1;

    for (int i = _expression.length - 1; i >= 0; i--) {
      if (operators.contains(_expression[i])) {
        lastOperatorIndex = i;
        break;
      }
    }

    return _expression.substring(lastOperatorIndex + 1);
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Button press handlers
  void onButtonPressed(CalculatorOperation operation) {
    switch (operation.type) {
      case OperationType.clear:
        clear();
        break;
      case OperationType.clearEntry:
        clearEntry();
        break;
      case OperationType.backspace:
        clearEntry();
        break;
      case OperationType.equals:
        calculate();
        break;
      case OperationType.decimal:
        inputDecimal();
        break;
      case OperationType.negate:
        negate();
        break;
      case OperationType.add:
        inputOperator('+');
        break;
      case OperationType.subtract:
        inputOperator('-');
        break;
      case OperationType.multiply:
        inputOperator('*');
        break;
      case OperationType.divide:
        inputOperator('/');
        break;
      case OperationType.parenthesesOpen:
      case OperationType.parenthesesClose:
        inputParenthesis();
        break;
      default:
        // For numbers and other operations
        break;
    }
  }

  void onNumberPressed(String number) {
    inputNumber(number);
  }
}
