import 'package:decimal/decimal.dart';
import '../models/tax_input.dart';
import '../models/tax_result.dart';
import '../models/tax_bracket.dart';

class ThaiTaxCalculator {
  static final Decimal _zero = Decimal.fromInt(0);
  static final Decimal _maxIncome = Decimal.parse('50000000'); // 50M THB reasonable limit

  /// Calculate Thai personal income tax based on input data
  TaxResult calculateTax(TaxInput input) {
    try {
      // Validation
      final validationError = _validateInput(input);
      if (validationError != null) {
        return TaxResult.error(message: validationError);
      }

      // Get tax brackets
      final brackets = TaxBracket.thaiTaxBrackets2024;
      
      // Calculate tax breakdown by bracket (progressive taxation)
      final bracketCalculations = <TaxBracketCalculation>[];
      Decimal totalTax = _zero;
      Decimal remainingIncome = input.taxableIncome;

      for (final bracket in brackets) {
        if (remainingIncome <= _zero) break;

        // Calculate how much income falls in this bracket
        Decimal incomeInThisBracket = _zero;
        if (remainingIncome > bracket.minIncome) {
          if (bracket.maxIncome == Decimal.parse('999999999')) {
            // Top bracket - all remaining income
            incomeInThisBracket = remainingIncome - bracket.minIncome;
          } else {
            // Regular bracket - income up to bracket max
            final maxIncomeInBracket = bracket.maxIncome - bracket.minIncome;
            final availableIncome = remainingIncome - bracket.minIncome;
            incomeInThisBracket = availableIncome < maxIncomeInBracket 
                ? availableIncome 
                : maxIncomeInBracket;
          }
        }

        if (incomeInThisBracket > _zero) {
          // Calculate tax on only the income in this bracket
          final rate = bracket.taxRate.toDouble() / 100.0;
          final taxForBracket = incomeInThisBracket * Decimal.parse(rate.toString());
          
          bracketCalculations.add(TaxBracketCalculation(
            bracketMin: bracket.minIncome,
            bracketMax: bracket.maxIncome,
            taxRate: bracket.taxRate,
            taxableAmount: incomeInThisBracket,
            taxAmount: taxForBracket,
          ));

          totalTax += taxForBracket;
        }
      }

      // Create result
      return TaxResult(
        grossIncome: input.annualIncome,
        totalAllowances: input.totalAllowances,
        totalDeductions: input.totalDeductions,
        taxableIncome: input.taxableIncome,
        calculatedTax: totalTax,
        bracketBreakdown: bracketCalculations,
        calculationDate: DateTime.now(),
        metadata: {
          'calculatorVersion': '1.0.0',
          'taxYear': '2024',
          'country': 'Thailand',
          'personalAllowance': input.personalAllowance.toString(),
          'childAllowance': input.childAllowance.toString(),
          'spouseAllowance': input.spouseAllowance.toString(),
        },
      );

    } catch (e) {
      return TaxResult.error(
        message: 'Calculation failed: ${e.toString()}',
      );
    }
  }

  /// Validate input data for tax calculation
  String? _validateInput(TaxInput input) {
    if (!input.isValid) {
      return 'Invalid input data provided';
    }

    if (input.annualIncome < _zero) {
      return 'Annual income cannot be negative';
    }

    if (input.annualIncome > _maxIncome) {
      return 'Annual income exceeds maximum allowed (${_formatCurrency(_maxIncome)} THB)';
    }

    if (input.spouseAllowance < _zero) {
      return 'Spouse allowance cannot be negative';
    }

    if (input.spouseAllowance > Decimal.fromInt(60000)) {
      return 'Spouse allowance cannot exceed 60,000 THB';
    }

    if (input.numberOfChildren < 0 || input.numberOfChildren > 20) {
      return 'Number of children must be between 0 and 20';
    }

    // Validate individual deduction limits
    final deductionErrors = _validateDeductions(input);
    if (deductionErrors.isNotEmpty) {
      return deductionErrors.first;
    }

    return null;
  }

  /// Validate individual deduction amounts against Thai tax law limits
  List<String> _validateDeductions(TaxInput input) {
    final errors = <String>[];

    // Insurance premium limit: 100,000 THB
    if (input.insurancePremium > Decimal.fromInt(100000)) {
      errors.add('Insurance premium deduction cannot exceed 100,000 THB');
    }

    // Retirement fund limit: 500,000 THB or 30% of income
    final maxRetirementFund = _calculatePercentageLimit(input.annualIncome, 30, 500000);
    if (input.retirementFund > maxRetirementFund) {
      errors.add('Retirement fund deduction cannot exceed ${_formatCurrency(maxRetirementFund)} THB');
    }

    // Mortgage interest limit: 100,000 THB
    if (input.mortgageInterest > Decimal.fromInt(100000)) {
      errors.add('Mortgage interest deduction cannot exceed 100,000 THB');
    }

    // Donation limits: 10% of net income each
    final netIncome = input.annualIncome - input.totalAllowances;
    final maxDonation = netIncome * Decimal.parse('0.1');
    
    if (input.educationDonation > maxDonation) {
      errors.add('Education donation cannot exceed 10% of net income (${_formatCurrency(maxDonation)} THB)');
    }

    if (input.generalDonation > maxDonation) {
      errors.add('General donation cannot exceed 10% of net income (${_formatCurrency(maxDonation)} THB)');
    }

    // Social security limit: 9,000 THB (750 per month)
    if (input.socialSecurityContribution > Decimal.fromInt(9000)) {
      errors.add('Social security contribution cannot exceed 9,000 THB');
    }

    // Provident fund limit: 500,000 THB or 15% of salary
    final maxProvidentFund = _calculatePercentageLimit(input.annualIncome, 15, 500000);
    if (input.providentFund > maxProvidentFund) {
      errors.add('Provident fund deduction cannot exceed ${_formatCurrency(maxProvidentFund)} THB');
    }

    return errors;
  }

  /// Calculate percentage-based limit with maximum cap
  Decimal _calculatePercentageLimit(Decimal income, int percentage, int maxAmount) {
    final rate = percentage / 100.0;
    final percentageAmount = income * Decimal.parse(rate.toString());
    final maxDecimal = Decimal.fromInt(maxAmount);
    return percentageAmount < maxDecimal ? percentageAmount : maxDecimal;
  }

  /// Format currency amount for display
  String _formatCurrency(Decimal amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Calculate tax savings from deductions
  TaxSavingsResult calculateTaxSavings(TaxInput originalInput, TaxInput optimizedInput) {
    final originalResult = calculateTax(originalInput);
    final optimizedResult = calculateTax(optimizedInput);

    if (originalResult.hasError || optimizedResult.hasError) {
      return TaxSavingsResult.error('Failed to calculate tax savings');
    }

    final taxSavings = originalResult.calculatedTax - optimizedResult.calculatedTax;
    final deductionIncrease = optimizedInput.totalDeductions - originalInput.totalDeductions;

    return TaxSavingsResult(
      originalTax: originalResult.calculatedTax,
      optimizedTax: optimizedResult.calculatedTax,
      taxSavings: taxSavings,
      deductionIncrease: deductionIncrease,
      effectiveSavingsRate: deductionIncrease > _zero 
          ? Decimal.parse((taxSavings / deductionIncrease).toString()) * Decimal.fromInt(100)
          : _zero,
    );
  }

  /// Get tax optimization suggestions
  List<TaxOptimizationSuggestion> getTaxOptimizationSuggestions(TaxInput input) {
    final suggestions = <TaxOptimizationSuggestion>[];

    // Check if user can increase retirement fund contributions
    final maxRetirementFund = _calculatePercentageLimit(input.annualIncome, 30, 500000);
    if (input.retirementFund < maxRetirementFund) {
      final additionalContribution = maxRetirementFund - input.retirementFund;
      suggestions.add(TaxOptimizationSuggestion(
        title: 'Increase Retirement Fund Contribution',
        description: 'You can contribute an additional ${_formatCurrency(additionalContribution)} THB to retirement funds',
        potentialSavings: _estimateTaxSavings(additionalContribution, input),
        priority: 'High',
        category: 'Retirement',
      ));
    }

    // Check insurance premium optimization
    if (input.insurancePremium < Decimal.fromInt(100000)) {
      final additionalInsurance = Decimal.fromInt(100000) - input.insurancePremium;
      suggestions.add(TaxOptimizationSuggestion(
        title: 'Increase Insurance Premium',
        description: 'Consider increasing insurance coverage to maximize deduction',
        potentialSavings: _estimateTaxSavings(additionalInsurance, input),
        priority: 'Medium',
        category: 'Insurance',
      ));
    }

    // Check mortgage interest if applicable
    if (input.mortgageInterest < Decimal.fromInt(100000) && input.mortgageInterest > _zero) {
      suggestions.add(TaxOptimizationSuggestion(
        title: 'Home Mortgage Optimization',
        description: 'Ensure all mortgage interest payments are properly documented',
        potentialSavings: _zero,
        priority: 'Low',
        category: 'Housing',
      ));
    }

    return suggestions;
  }

  /// Estimate tax savings from additional deduction
  Decimal _estimateTaxSavings(Decimal additionalDeduction, TaxInput input) {
    final marginalTaxRate = _getMarginalTaxRate(input.taxableIncome);
    final rate = marginalTaxRate.toDouble() / 100.0;
    return additionalDeduction * Decimal.parse(rate.toString());
  }

  /// Get marginal tax rate for given income
  Decimal _getMarginalTaxRate(Decimal taxableIncome) {
    final brackets = TaxBracket.thaiTaxBrackets2024;
    
    for (final bracket in brackets.reversed) {
      if (taxableIncome >= bracket.minIncome) {
        return bracket.taxRate;
      }
    }
    
    return _zero;
  }
}

/// Result of tax savings calculation
class TaxSavingsResult {
  final Decimal originalTax;
  final Decimal optimizedTax;
  final Decimal taxSavings;
  final Decimal deductionIncrease;
  final Decimal effectiveSavingsRate;
  final String? errorMessage;

  TaxSavingsResult({
    required this.originalTax,
    required this.optimizedTax,
    required this.taxSavings,
    required this.deductionIncrease,
    required this.effectiveSavingsRate,
    this.errorMessage,
  });

  factory TaxSavingsResult.error(String message) {
    return TaxSavingsResult(
      originalTax: Decimal.fromInt(0),
      optimizedTax: Decimal.fromInt(0),
      taxSavings: Decimal.fromInt(0),
      deductionIncrease: Decimal.fromInt(0),
      effectiveSavingsRate: Decimal.fromInt(0),
      errorMessage: message,
    );
  }

  bool get hasError => errorMessage != null;
  bool get hasSavings => taxSavings > Decimal.fromInt(0);
}

/// Tax optimization suggestion
class TaxOptimizationSuggestion {
  final String title;
  final String description;
  final Decimal potentialSavings;
  final String priority;
  final String category;

  TaxOptimizationSuggestion({
    required this.title,
    required this.description,
    required this.potentialSavings,
    required this.priority,
    required this.category,
  });

  String get formattedSavings {
    return potentialSavings.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}