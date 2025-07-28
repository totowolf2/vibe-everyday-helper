import 'currency.dart';
import 'calculation_step.dart';

class MultiplierFormula {
  final String id;
  final Currency baseCurrency;
  final Currency targetCurrency;
  final double baseAmount;
  final List<double> multipliers;
  final DateTime createdAt;
  final DateTime lastUsed;

  const MultiplierFormula({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.baseAmount,
    required this.multipliers,
    required this.createdAt,
    required this.lastUsed,
  });

  factory MultiplierFormula.create({
    required Currency baseCurrency,
    required Currency targetCurrency,
    required double baseAmount,
    required List<double> multipliers,
  }) {
    final now = DateTime.now();
    return MultiplierFormula(
      id: _generateId(),
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      baseAmount: baseAmount,
      multipliers: List.from(multipliers),
      createdAt: now,
      lastUsed: now,
    );
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool get isValid =>
      baseAmount > 0 &&
      multipliers.isNotEmpty &&
      multipliers.every((m) => m > 0) &&
      baseCurrency.isValid &&
      targetCurrency.isValid;

  bool get hasMultipliers => multipliers.isNotEmpty;

  int get multiplierCount => multipliers.length;

  double get totalMultiplier {
    if (multipliers.isEmpty) return 1.0;
    return multipliers.fold(1.0, (product, multiplier) => product * multiplier);
  }

  List<CalculationStep> generateSteps({required double exchangeRate}) {
    final steps = <CalculationStep>[];

    double currentValue = baseAmount;
    final convertedAmount = currentValue * exchangeRate;

    steps.add(
      CalculationStep.exchangeConversion(
        inputValue: currentValue,
        outputValue: convertedAmount,
        fromCurrency: baseCurrency,
        toCurrency: targetCurrency,
        rate: exchangeRate,
      ),
    );

    currentValue = convertedAmount;

    for (int i = 0; i < multipliers.length; i++) {
      final multiplier = multipliers[i];
      steps.add(
        CalculationStep.multiplication(
          inputValue: currentValue,
          multiplier: multiplier,
          currency: targetCurrency,
        ),
      );
      currentValue = currentValue * multiplier;
    }

    return steps;
  }

  double calculateFinalAmount({required double exchangeRate}) {
    final convertedAmount = baseAmount * exchangeRate;
    return convertedAmount * totalMultiplier;
  }

  String get displaySummary {
    final multipliersText = multipliers
        .map((m) => m.toStringAsFixed(2))
        .join(' × ');
    return '${baseAmount.toStringAsFixed(2)} ${baseCurrency.code} → ${targetCurrency.code} × $multipliersText';
  }

  MultiplierFormula copyWith({
    String? id,
    Currency? baseCurrency,
    Currency? targetCurrency,
    double? baseAmount,
    List<double>? multipliers,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return MultiplierFormula(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      baseAmount: baseAmount ?? this.baseAmount,
      multipliers: multipliers ?? List.from(this.multipliers),
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  MultiplierFormula withUpdatedUsage() {
    return copyWith(lastUsed: DateTime.now());
  }

  MultiplierFormula addMultiplier(double multiplier) {
    if (multiplier <= 0) throw ArgumentError('Multiplier must be positive');

    final updatedMultipliers = List<double>.from(multipliers)..add(multiplier);
    return copyWith(multipliers: updatedMultipliers, lastUsed: DateTime.now());
  }

  MultiplierFormula removeMultiplier(int index) {
    if (index < 0 || index >= multipliers.length) {
      throw ArgumentError('Invalid multiplier index');
    }

    final updatedMultipliers = List<double>.from(multipliers)..removeAt(index);
    return copyWith(multipliers: updatedMultipliers, lastUsed: DateTime.now());
  }

  MultiplierFormula updateMultiplier(int index, double newValue) {
    if (index < 0 || index >= multipliers.length) {
      throw ArgumentError('Invalid multiplier index');
    }
    if (newValue <= 0) throw ArgumentError('Multiplier must be positive');

    final updatedMultipliers = List<double>.from(multipliers);
    updatedMultipliers[index] = newValue;

    return copyWith(multipliers: updatedMultipliers, lastUsed: DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baseCurrency': baseCurrency.toMap(),
      'targetCurrency': targetCurrency.toMap(),
      'baseAmount': baseAmount,
      'multipliers': multipliers,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
    };
  }

  factory MultiplierFormula.fromMap(Map<String, dynamic> map) {
    return MultiplierFormula(
      id: map['id'] ?? '',
      baseCurrency: Currency.fromMap(map['baseCurrency'] ?? {}),
      targetCurrency: Currency.fromMap(map['targetCurrency'] ?? {}),
      baseAmount: (map['baseAmount'] ?? 0.0).toDouble(),
      multipliers: List<double>.from(
        (map['multipliers'] ?? []).map((m) => m.toDouble()),
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      lastUsed: DateTime.fromMillisecondsSinceEpoch(
        map['lastUsed'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'MultiplierFormula(id: $id, baseCurrency: $baseCurrency, targetCurrency: $targetCurrency, baseAmount: $baseAmount, multipliers: $multipliers, createdAt: $createdAt, lastUsed: $lastUsed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MultiplierFormula &&
        other.id == id &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency &&
        other.baseAmount == baseAmount &&
        _listEquals(other.multipliers, multipliers) &&
        other.createdAt == createdAt &&
        other.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        baseCurrency.hashCode ^
        targetCurrency.hashCode ^
        baseAmount.hashCode ^
        multipliers.hashCode ^
        createdAt.hashCode ^
        lastUsed.hashCode;
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
