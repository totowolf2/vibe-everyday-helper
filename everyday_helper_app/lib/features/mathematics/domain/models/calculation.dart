
enum CalculationType {
  basic,
  scientific,
  statistics,
  unitConversion,
  percentage,
}

class Calculation {
  final String id;
  final CalculationType type;
  final String expression;
  final String result;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const Calculation({
    required this.id,
    required this.type,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.metadata = const {},
  });

  String get displayExpression {
    return expression.isEmpty ? 'Unknown' : expression;
  }

  String get displayResult {
    return result.isEmpty ? '0' : result;
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get typeDisplay {
    switch (type) {
      case CalculationType.basic:
        return 'Basic';
      case CalculationType.scientific:
        return 'Scientific';
      case CalculationType.statistics:
        return 'Statistics';
      case CalculationType.unitConversion:
        return 'Unit Conversion';
      case CalculationType.percentage:
        return 'Percentage';
    }
  }

  bool get isValid {
    return expression.isNotEmpty && result.isNotEmpty;
  }

  Calculation copyWith({
    String? id,
    CalculationType? type,
    String? expression,
    String? result,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Calculation(
      id: id ?? this.id,
      type: type ?? this.type,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'expression': expression,
      'result': result,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'] ?? '',
      type: CalculationType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => CalculationType.basic,
      ),
      expression: map['expression'] ?? '',
      result: map['result'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'Calculation(id: $id, type: $type, expression: $expression, result: $result, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Calculation &&
        other.id == id &&
        other.type == type &&
        other.expression == expression &&
        other.result == result &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        expression.hashCode ^
        result.hashCode ^
        timestamp.hashCode;
  }
}

class CalculationHistory {
  final List<Calculation> _calculations = [];
  static const int _maxHistorySize = 100;

  CalculationHistory();

  List<Calculation> get calculations => List.unmodifiable(_calculations);
  int get length => _calculations.length;
  bool get isEmpty => _calculations.isEmpty;
  bool get isNotEmpty => _calculations.isNotEmpty;

  void addCalculation(Calculation calculation) {
    _calculations.insert(0, calculation);
    
    if (_calculations.length > _maxHistorySize) {
      _calculations.removeLast();
    }
  }

  void removeCalculation(String id) {
    _calculations.removeWhere((calc) => calc.id == id);
  }

  void clearHistory() {
    _calculations.clear();
  }

  List<Calculation> getByType(CalculationType type) {
    return _calculations.where((calc) => calc.type == type).toList();
  }

  List<Calculation> getRecent({int limit = 10}) {
    return _calculations.take(limit).toList();
  }

  Calculation? getById(String id) {
    try {
      return _calculations.firstWhere((calc) => calc.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'calculations': _calculations.map((calc) => calc.toMap()).toList(),
    };
  }

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    final history = CalculationHistory();
    final calcsList = map['calculations'] as List<dynamic>? ?? [];
    
    for (final calcMap in calcsList) {
      if (calcMap is Map<String, dynamic>) {
        history.addCalculation(Calculation.fromMap(calcMap));
      }
    }
    
    return history;
  }
}