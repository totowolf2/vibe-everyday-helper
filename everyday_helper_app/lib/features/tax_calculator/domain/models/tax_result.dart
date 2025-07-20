import 'package:decimal/decimal.dart';

class TaxResult {
  static final Decimal _zero = Decimal.fromInt(0);

  final Decimal grossIncome;
  final Decimal totalAllowances;
  final Decimal totalDeductions;
  final Decimal taxableIncome;
  final Decimal calculatedTax;
  final List<TaxBracketCalculation> bracketBreakdown;
  final DateTime calculationDate;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  TaxResult({
    Decimal? grossIncome,
    Decimal? totalAllowances,
    Decimal? totalDeductions,
    Decimal? taxableIncome,
    Decimal? calculatedTax,
    this.bracketBreakdown = const [],
    DateTime? calculationDate,
    this.errorMessage,
    this.metadata = const {},
  })  : grossIncome = grossIncome ?? _zero,
        totalAllowances = totalAllowances ?? _zero,
        totalDeductions = totalDeductions ?? _zero,
        taxableIncome = taxableIncome ?? _zero,
        calculatedTax = calculatedTax ?? _zero,
        calculationDate = calculationDate ?? DateTime.now();

  factory TaxResult.error({required String message}) {
    return TaxResult(
      errorMessage: message,
      calculationDate: DateTime.now(),
    );
  }

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isValid => !hasError && taxableIncome >= _zero;
  
  Decimal get netIncome => grossIncome - calculatedTax;
  Decimal get effectiveTaxRate {
    if (grossIncome > _zero) {
      final rate = calculatedTax.toDouble() / grossIncome.toDouble();
      return Decimal.parse(rate.toString()) * Decimal.fromInt(100);
    }
    return _zero;
  }
  Decimal get marginalTaxRate => bracketBreakdown.isNotEmpty ? bracketBreakdown.last.taxRate : _zero;

  Decimal get totalTaxSavings => totalAllowances + totalDeductions;
  Decimal get taxSavingsAmount {
    final rate = marginalTaxRate.toDouble() / 100.0;
    return totalTaxSavings * Decimal.parse(rate.toString());
  }

  String get summaryText {
    if (hasError) {
      return 'Error: $errorMessage';
    }
    
    return 'Tax owed: ${_formatCurrency(calculatedTax)} THB '
           '(${_formatPercentage(effectiveTaxRate)}% effective rate)';
  }

  String get detailedBreakdown {
    if (hasError) {
      return 'Calculation failed: $errorMessage';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== Thai Tax Calculation Breakdown ===');
    buffer.writeln('Gross Annual Income: ${_formatCurrency(grossIncome)} THB');
    buffer.writeln('Less: Total Allowances: ${_formatCurrency(totalAllowances)} THB');
    buffer.writeln('Less: Total Deductions: ${_formatCurrency(totalDeductions)} THB');
    buffer.writeln('Taxable Income: ${_formatCurrency(taxableIncome)} THB');
    buffer.writeln('');
    buffer.writeln('=== Tax Calculation by Bracket ===');
    
    for (final bracket in bracketBreakdown) {
      if (bracket.taxableAmount > _zero) {
        buffer.writeln('${_formatCurrency(bracket.taxableAmount)} THB at ${_formatPercentage(bracket.taxRate)}% = ${_formatCurrency(bracket.taxAmount)} THB');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('Total Tax: ${_formatCurrency(calculatedTax)} THB');
    buffer.writeln('Net Income: ${_formatCurrency(netIncome)} THB');
    buffer.writeln('Effective Tax Rate: ${_formatPercentage(effectiveTaxRate)}%');
    buffer.writeln('Marginal Tax Rate: ${_formatPercentage(marginalTaxRate)}%');
    
    return buffer.toString();
  }

  String _formatCurrency(Decimal amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatPercentage(Decimal percentage) {
    return percentage.toStringAsFixed(2);
  }

  TaxResult copyWith({
    Decimal? grossIncome,
    Decimal? totalAllowances,
    Decimal? totalDeductions,
    Decimal? taxableIncome,
    Decimal? calculatedTax,
    List<TaxBracketCalculation>? bracketBreakdown,
    DateTime? calculationDate,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return TaxResult(
      grossIncome: grossIncome ?? this.grossIncome,
      totalAllowances: totalAllowances ?? this.totalAllowances,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      calculatedTax: calculatedTax ?? this.calculatedTax,
      bracketBreakdown: bracketBreakdown ?? this.bracketBreakdown,
      calculationDate: calculationDate ?? this.calculationDate,
      errorMessage: errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grossIncome': grossIncome.toString(),
      'totalAllowances': totalAllowances.toString(),
      'totalDeductions': totalDeductions.toString(),
      'taxableIncome': taxableIncome.toString(),
      'calculatedTax': calculatedTax.toString(),
      'bracketBreakdown': bracketBreakdown.map((b) => b.toMap()).toList(),
      'calculationDate': calculationDate.millisecondsSinceEpoch,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory TaxResult.fromMap(Map<String, dynamic> map) {
    return TaxResult(
      grossIncome: Decimal.parse(map['grossIncome']?.toString() ?? '0'),
      totalAllowances: Decimal.parse(map['totalAllowances']?.toString() ?? '0'),
      totalDeductions: Decimal.parse(map['totalDeductions']?.toString() ?? '0'),
      taxableIncome: Decimal.parse(map['taxableIncome']?.toString() ?? '0'),
      calculatedTax: Decimal.parse(map['calculatedTax']?.toString() ?? '0'),
      bracketBreakdown: (map['bracketBreakdown'] as List<dynamic>?)
          ?.map((b) => TaxBracketCalculation.fromMap(b as Map<String, dynamic>))
          .toList() ?? [],
      calculationDate: DateTime.fromMillisecondsSinceEpoch(
        map['calculationDate'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      errorMessage: map['errorMessage'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'TaxResult(taxableIncome: $taxableIncome, calculatedTax: $calculatedTax, effectiveRate: $effectiveTaxRate%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxResult &&
        other.grossIncome == grossIncome &&
        other.taxableIncome == taxableIncome &&
        other.calculatedTax == calculatedTax;
  }

  @override
  int get hashCode {
    return grossIncome.hashCode ^
        taxableIncome.hashCode ^
        calculatedTax.hashCode;
  }
}

class TaxBracketCalculation {
  static final Decimal _zero = Decimal.fromInt(0);

  final Decimal bracketMin;
  final Decimal bracketMax;
  final Decimal taxRate;
  final Decimal taxableAmount;
  final Decimal taxAmount;

  TaxBracketCalculation({
    Decimal? bracketMin,
    Decimal? bracketMax,
    Decimal? taxRate,
    Decimal? taxableAmount,
    Decimal? taxAmount,
  })  : bracketMin = bracketMin ?? _zero,
        bracketMax = bracketMax ?? _zero,
        taxRate = taxRate ?? _zero,
        taxableAmount = taxableAmount ?? _zero,
        taxAmount = taxAmount ?? _zero;

  String get bracketDescription {
    if (bracketMax == _zero || bracketMax == Decimal.parse('999999999')) {
      return '${_formatCurrency(bracketMin)} THB and above';
    }
    return '${_formatCurrency(bracketMin)} - ${_formatCurrency(bracketMax)} THB';
  }

  String get taxRateDisplay => '${taxRate.toStringAsFixed(0)}%';

  String _formatCurrency(Decimal amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bracketMin': bracketMin.toString(),
      'bracketMax': bracketMax.toString(),
      'taxRate': taxRate.toString(),
      'taxableAmount': taxableAmount.toString(),
      'taxAmount': taxAmount.toString(),
    };
  }

  factory TaxBracketCalculation.fromMap(Map<String, dynamic> map) {
    return TaxBracketCalculation(
      bracketMin: Decimal.parse(map['bracketMin']?.toString() ?? '0'),
      bracketMax: Decimal.parse(map['bracketMax']?.toString() ?? '0'),
      taxRate: Decimal.parse(map['taxRate']?.toString() ?? '0'),
      taxableAmount: Decimal.parse(map['taxableAmount']?.toString() ?? '0'),
      taxAmount: Decimal.parse(map['taxAmount']?.toString() ?? '0'),
    );
  }

  @override
  String toString() {
    return 'TaxBracketCalculation($bracketDescription at $taxRateDisplay: ${_formatCurrency(taxAmount)} THB)';
  }
}