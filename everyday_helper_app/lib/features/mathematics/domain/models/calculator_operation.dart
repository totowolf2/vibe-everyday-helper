enum OperationType {
  // Basic operations
  add,
  subtract,
  multiply,
  divide,
  
  // Scientific operations
  sin,
  cos,
  tan,
  asin,
  acos,
  atan,
  log,
  ln,
  exp,
  power,
  sqrt,
  
  // Special operations
  percentage,
  factorial,
  pi,
  e,
  
  // Control operations
  clear,
  clearEntry,
  backspace,
  equals,
  decimal,
  negate,
  parenthesesOpen,
  parenthesesClose,
}

class CalculatorOperation {
  final OperationType type;
  final String symbol;
  final String displayText;
  final int precedence;
  final bool isUnary;
  final bool isBinary;
  final bool isConstant;
  final bool isControl;

  const CalculatorOperation({
    required this.type,
    required this.symbol,
    required this.displayText,
    this.precedence = 0,
    this.isUnary = false,
    this.isBinary = false,
    this.isConstant = false,
    this.isControl = false,
  });

  bool get isOperator {
    return isBinary || isUnary;
  }

  bool get isNumber {
    return !isOperator && !isConstant && !isControl;
  }

  bool get requiresOperand {
    return isBinary || isUnary;
  }

  static List<CalculatorOperation> get basicOperations {
    return [
      const CalculatorOperation(
        type: OperationType.add,
        symbol: '+',
        displayText: '+',
        precedence: 1,
        isBinary: true,
      ),
      const CalculatorOperation(
        type: OperationType.subtract,
        symbol: '-',
        displayText: '-',
        precedence: 1,
        isBinary: true,
      ),
      const CalculatorOperation(
        type: OperationType.multiply,
        symbol: '*',
        displayText: '×',
        precedence: 2,
        isBinary: true,
      ),
      const CalculatorOperation(
        type: OperationType.divide,
        symbol: '/',
        displayText: '÷',
        precedence: 2,
        isBinary: true,
      ),
      const CalculatorOperation(
        type: OperationType.decimal,
        symbol: '.',
        displayText: '.',
        isControl: true,
      ),
      const CalculatorOperation(
        type: OperationType.equals,
        symbol: '=',
        displayText: '=',
        isControl: true,
      ),
      const CalculatorOperation(
        type: OperationType.clear,
        symbol: 'C',
        displayText: 'C',
        isControl: true,
      ),
      const CalculatorOperation(
        type: OperationType.clearEntry,
        symbol: 'CE',
        displayText: 'CE',
        isControl: true,
      ),
      const CalculatorOperation(
        type: OperationType.backspace,
        symbol: '⌫',
        displayText: '⌫',
        isControl: true,
      ),
      const CalculatorOperation(
        type: OperationType.negate,
        symbol: '±',
        displayText: '±',
        isUnary: true,
      ),
    ];
  }

  static List<CalculatorOperation> get scientificOperations {
    return [
      ...basicOperations,
      const CalculatorOperation(
        type: OperationType.sin,
        symbol: 'sin',
        displayText: 'sin',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.cos,
        symbol: 'cos',
        displayText: 'cos',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.tan,
        symbol: 'tan',
        displayText: 'tan',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.asin,
        symbol: 'asin',
        displayText: 'sin⁻¹',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.acos,
        symbol: 'acos',
        displayText: 'cos⁻¹',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.atan,
        symbol: 'atan',
        displayText: 'tan⁻¹',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.log,
        symbol: 'log',
        displayText: 'log',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.ln,
        symbol: 'ln',
        displayText: 'ln',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.exp,
        symbol: 'exp',
        displayText: 'eˣ',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.power,
        symbol: '^',
        displayText: 'xʸ',
        precedence: 3,
        isBinary: true,
      ),
      const CalculatorOperation(
        type: OperationType.sqrt,
        symbol: 'sqrt',
        displayText: '√',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.factorial,
        symbol: '!',
        displayText: 'x!',
        isUnary: true,
      ),
      const CalculatorOperation(
        type: OperationType.pi,
        symbol: 'π',
        displayText: 'π',
        isConstant: true,
      ),
      const CalculatorOperation(
        type: OperationType.e,
        symbol: 'e',
        displayText: 'e',
        isConstant: true,
      ),
      const CalculatorOperation(
        type: OperationType.parenthesesOpen,
        symbol: '(',
        displayText: '(',
        isControl: true,
      ),
      const CalculatorOperation(
        type: OperationType.parenthesesClose,
        symbol: ')',
        displayText: ')',
        isControl: true,
      ),
    ];
  }

  static CalculatorOperation? getOperationByType(OperationType type) {
    try {
      return scientificOperations.firstWhere((op) => op.type == type);
    } catch (e) {
      return null;
    }
  }

  static CalculatorOperation? getOperationBySymbol(String symbol) {
    try {
      return scientificOperations.firstWhere((op) => op.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  static List<CalculatorOperation> getOperationsByPrecedence(int precedence) {
    return scientificOperations
        .where((op) => op.precedence == precedence)
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'symbol': symbol,
      'displayText': displayText,
      'precedence': precedence,
      'isUnary': isUnary,
      'isBinary': isBinary,
      'isConstant': isConstant,
      'isControl': isControl,
    };
  }

  factory CalculatorOperation.fromMap(Map<String, dynamic> map) {
    return CalculatorOperation(
      type: OperationType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => OperationType.add,
      ),
      symbol: map['symbol'] ?? '',
      displayText: map['displayText'] ?? '',
      precedence: map['precedence'] ?? 0,
      isUnary: map['isUnary'] ?? false,
      isBinary: map['isBinary'] ?? false,
      isConstant: map['isConstant'] ?? false,
      isControl: map['isControl'] ?? false,
    );
  }

  @override
  String toString() {
    return 'CalculatorOperation(type: $type, symbol: $symbol, displayText: $displayText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculatorOperation &&
        other.type == type &&
        other.symbol == symbol;
  }

  @override
  int get hashCode {
    return type.hashCode ^ symbol.hashCode;
  }
}

class OperationValidator {
  static String? validateExpression(String expression) {
    if (expression.isEmpty) {
      return 'Expression cannot be empty';
    }

    // Check for balanced parentheses
    int openParens = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        openParens++;
      } else if (expression[i] == ')') {
        openParens--;
        if (openParens < 0) {
          return 'Unmatched closing parenthesis';
        }
      }
    }
    
    if (openParens > 0) {
      return 'Unmatched opening parenthesis';
    }

    // Check for division by zero patterns
    if (expression.contains('/0') || expression.contains('÷0')) {
      return 'Cannot divide by zero';
    }

    // Check for invalid operator sequences
    final invalidPatterns = [
      RegExp(r'[+\-*/÷]{2,}'), // Multiple consecutive operators
      RegExp(r'^[+*/÷]'), // Starting with operator (except minus)
      RegExp(r'[+\-*/÷]$'), // Ending with operator
    ];

    for (final pattern in invalidPatterns) {
      if (pattern.hasMatch(expression)) {
        return 'Invalid operator sequence';
      }
    }

    return null; // Valid expression
  }

  static bool isDivisionByZero(String expression, double result) {
    return result.isInfinite || result.isNaN;
  }

  static bool isValidNumber(String input) {
    return double.tryParse(input) != null;
  }

  static String sanitizeInput(String input) {
    // Replace display symbols with calculation symbols
    return input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '3.141592653589793')
        .replaceAll('e', '2.718281828459045');
  }
}