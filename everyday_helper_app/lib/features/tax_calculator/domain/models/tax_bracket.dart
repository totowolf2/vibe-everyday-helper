import 'package:decimal/decimal.dart';

class TaxBracket {
  static final Decimal _zero = Decimal.fromInt(0);
  static final Decimal _maxValue = Decimal.parse('999999999');

  final Decimal minIncome;
  final Decimal maxIncome;
  final Decimal taxRate;
  final String description;

  TaxBracket({
    Decimal? minIncome,
    Decimal? maxIncome,
    Decimal? taxRate,
    this.description = '',
  }) : minIncome = minIncome ?? _zero,
       maxIncome = maxIncome ?? _maxValue,
       taxRate = taxRate ?? _zero;

  static List<TaxBracket> get thaiTaxBrackets2024 {
    return [
      TaxBracket(
        minIncome: _zero,
        maxIncome: Decimal.fromInt(150000),
        taxRate: _zero,
        description: '0% - No tax on income up to 150,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(150000),
        maxIncome: Decimal.fromInt(300000),
        taxRate: Decimal.fromInt(5),
        description: '5% - Income from 150,001 to 300,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(300000),
        maxIncome: Decimal.fromInt(500000),
        taxRate: Decimal.fromInt(10),
        description: '10% - Income from 300,001 to 500,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(500000),
        maxIncome: Decimal.fromInt(750000),
        taxRate: Decimal.fromInt(15),
        description: '15% - Income from 500,001 to 750,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(750000),
        maxIncome: Decimal.fromInt(1000000),
        taxRate: Decimal.fromInt(20),
        description: '20% - Income from 750,001 to 1,000,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(1000000),
        maxIncome: Decimal.fromInt(2000000),
        taxRate: Decimal.fromInt(25),
        description: '25% - Income from 1,000,001 to 2,000,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(2000000),
        maxIncome: Decimal.fromInt(5000000),
        taxRate: Decimal.fromInt(30),
        description: '30% - Income from 2,000,001 to 5,000,000 THB',
      ),
      TaxBracket(
        minIncome: Decimal.fromInt(5000000),
        maxIncome: _maxValue,
        taxRate: Decimal.fromInt(35),
        description: '35% - Income above 5,000,000 THB',
      ),
    ];
  }

  bool appliesToIncome(Decimal income) {
    return income >= minIncome &&
        (maxIncome == _maxValue || income <= maxIncome);
  }

  Decimal calculateTaxForBracket(Decimal income) {
    if (!appliesToIncome(income)) {
      return _zero;
    }

    final taxableInThisBracket = (maxIncome == _maxValue)
        ? income - minIncome
        : (income < maxIncome ? income : maxIncome) - minIncome;

    if (taxableInThisBracket <= _zero) {
      return _zero;
    }

    final rate = taxRate.toDouble() / 100.0;
    return taxableInThisBracket * Decimal.parse(rate.toString());
  }

  Decimal getTaxableAmountInBracket(Decimal totalIncome) {
    if (totalIncome <= minIncome) {
      return _zero;
    }

    if (maxIncome == _maxValue) {
      return totalIncome - minIncome;
    }

    return (totalIncome < maxIncome ? totalIncome : maxIncome) - minIncome;
  }

  String get formattedMinIncome => _formatCurrency(minIncome);
  String get formattedMaxIncome =>
      maxIncome == _maxValue ? 'and above' : _formatCurrency(maxIncome);
  String get formattedTaxRate => '${taxRate.toStringAsFixed(0)}%';

  String get rangeDescription {
    if (maxIncome == _maxValue) {
      return '$formattedMinIncome THB and above';
    }
    return '$formattedMinIncome - $formattedMaxIncome THB';
  }

  String _formatCurrency(Decimal amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Map<String, dynamic> toMap() {
    return {
      'minIncome': minIncome.toString(),
      'maxIncome': maxIncome.toString(),
      'taxRate': taxRate.toString(),
      'description': description,
    };
  }

  factory TaxBracket.fromMap(Map<String, dynamic> map) {
    return TaxBracket(
      minIncome: Decimal.parse(map['minIncome']?.toString() ?? '0'),
      maxIncome: Decimal.parse(map['maxIncome']?.toString() ?? '999999999'),
      taxRate: Decimal.parse(map['taxRate']?.toString() ?? '0'),
      description: map['description']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'TaxBracket($rangeDescription at $formattedTaxRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxBracket &&
        other.minIncome == minIncome &&
        other.maxIncome == maxIncome &&
        other.taxRate == taxRate;
  }

  @override
  int get hashCode {
    return minIncome.hashCode ^ maxIncome.hashCode ^ taxRate.hashCode;
  }
}
