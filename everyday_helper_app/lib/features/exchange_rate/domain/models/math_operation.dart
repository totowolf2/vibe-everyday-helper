enum OperationType { multiply, divide }

class MathOperation {
  final OperationType type;
  final double value;

  const MathOperation({
    required this.type,
    required this.value,
  });

  factory MathOperation.multiply(double value) {
    return MathOperation(type: OperationType.multiply, value: value);
  }

  factory MathOperation.divide(double value) {
    return MathOperation(type: OperationType.divide, value: value);
  }

  bool get isMultiply => type == OperationType.multiply;
  bool get isDivide => type == OperationType.divide;

  String get symbol => isMultiply ? '×' : '÷';
  String get displayName => isMultiply ? 'ตัวคูณ' : 'ตัวหาร';

  double apply(double input) {
    return isMultiply ? input * value : input / value;
  }

  bool get isValid => value > 0;

  MathOperation copyWith({
    OperationType? type,
    double? value,
  }) {
    return MathOperation(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'value': value,
    };
  }

  factory MathOperation.fromMap(Map<String, dynamic> map) {
    return MathOperation(
      type: OperationType.values[map['type'] ?? 0],
      value: (map['value'] ?? 1.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'MathOperation(type: $type, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathOperation &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode {
    return type.hashCode ^ value.hashCode;
  }
}