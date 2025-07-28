import 'currency.dart';

enum CalculationStepType { exchangeConversion, multiplication, division }

class CalculationStep {
  final CalculationStepType type;
  final double inputValue;
  final double outputValue;
  final double? multiplier;
  final double? divisor;
  final Currency? fromCurrency;
  final Currency? toCurrency;
  final String description;

  const CalculationStep({
    required this.type,
    required this.inputValue,
    required this.outputValue,
    this.multiplier,
    this.divisor,
    this.fromCurrency,
    this.toCurrency,
    required this.description,
  });

  factory CalculationStep.exchangeConversion({
    required double inputValue,
    required double outputValue,
    required Currency fromCurrency,
    required Currency toCurrency,
    required double rate,
  }) {
    return CalculationStep(
      type: CalculationStepType.exchangeConversion,
      inputValue: inputValue,
      outputValue: outputValue,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      description:
          '${inputValue.toStringAsFixed(2)} ${fromCurrency.code} = ${outputValue.toStringAsFixed(2)} ${toCurrency.code}',
    );
  }

  factory CalculationStep.multiplication({
    required double inputValue,
    required double multiplier,
    required Currency currency,
  }) {
    final outputValue = inputValue * multiplier;
    return CalculationStep(
      type: CalculationStepType.multiplication,
      inputValue: inputValue,
      outputValue: outputValue,
      multiplier: multiplier,
      description:
          '${inputValue.toStringAsFixed(2)} × ${multiplier.toStringAsFixed(2)} = ${outputValue.toStringAsFixed(2)} ${currency.code}',
    );
  }

  factory CalculationStep.division({
    required double inputValue,
    required double divisor,
    required Currency currency,
  }) {
    final outputValue = inputValue / divisor;
    return CalculationStep(
      type: CalculationStepType.division,
      inputValue: inputValue,
      outputValue: outputValue,
      divisor: divisor,
      description:
          '${inputValue.toStringAsFixed(2)} ÷ ${divisor.toStringAsFixed(2)} = ${outputValue.toStringAsFixed(2)} ${currency.code}',
    );
  }

  bool get isValid => inputValue >= 0 && outputValue >= 0;

  String get formattedInputValue => inputValue.toStringAsFixed(2);

  String get formattedOutputValue => outputValue.toStringAsFixed(2);

  String get formattedMultiplier => multiplier?.toStringAsFixed(2) ?? '';

  String get formattedDivisor => divisor?.toStringAsFixed(2) ?? '';

  CalculationStep copyWith({
    CalculationStepType? type,
    double? inputValue,
    double? outputValue,
    double? multiplier,
    double? divisor,
    Currency? fromCurrency,
    Currency? toCurrency,
    String? description,
  }) {
    return CalculationStep(
      type: type ?? this.type,
      inputValue: inputValue ?? this.inputValue,
      outputValue: outputValue ?? this.outputValue,
      multiplier: multiplier ?? this.multiplier,
      divisor: divisor ?? this.divisor,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'inputValue': inputValue,
      'outputValue': outputValue,
      'multiplier': multiplier,
      'divisor': divisor,
      'fromCurrency': fromCurrency?.toMap(),
      'toCurrency': toCurrency?.toMap(),
      'description': description,
    };
  }

  factory CalculationStep.fromMap(Map<String, dynamic> map) {
    return CalculationStep(
      type: CalculationStepType.values[map['type'] ?? 0],
      inputValue: (map['inputValue'] ?? 0.0).toDouble(),
      outputValue: (map['outputValue'] ?? 0.0).toDouble(),
      multiplier: map['multiplier']?.toDouble(),
      divisor: map['divisor']?.toDouble(),
      fromCurrency: map['fromCurrency'] != null
          ? Currency.fromMap(map['fromCurrency'])
          : null,
      toCurrency: map['toCurrency'] != null
          ? Currency.fromMap(map['toCurrency'])
          : null,
      description: map['description'] ?? '',
    );
  }

  @override
  String toString() {
    return 'CalculationStep(type: $type, inputValue: $inputValue, outputValue: $outputValue, multiplier: $multiplier, divisor: $divisor, fromCurrency: $fromCurrency, toCurrency: $toCurrency, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculationStep &&
        other.type == type &&
        other.inputValue == inputValue &&
        other.outputValue == outputValue &&
        other.multiplier == multiplier &&
        other.divisor == divisor &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency &&
        other.description == description;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        inputValue.hashCode ^
        outputValue.hashCode ^
        multiplier.hashCode ^
        divisor.hashCode ^
        fromCurrency.hashCode ^
        toCurrency.hashCode ^
        description.hashCode;
  }
}
