import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:everyday_helper_app/features/tax_calculator/domain/models/tax_input.dart';
import 'package:everyday_helper_app/features/tax_calculator/domain/use_cases/thai_tax_calculator.dart';

void main() {
  group('ThaiTaxCalculator Tests', () {
    late ThaiTaxCalculator calculator;

    setUp(() {
      calculator = ThaiTaxCalculator();
    });

    group('Basic Tax Calculation', () {
      test('should calculate zero tax for income below taxable threshold', () {
        // Income: 120,000 THB, Personal allowance: 60,000 THB
        // Taxable income: 60,000 THB (below 150,000 threshold)
        final input = TaxInput(annualIncome: Decimal.fromInt(120000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.taxableIncome, Decimal.fromInt(60000));
        expect(result.calculatedTax, Decimal.fromInt(0));
        expect(result.effectiveTaxRate, Decimal.fromInt(0));
      });

      test('should calculate tax for income in first bracket (5%)', () {
        // Income: 300,000 THB, Personal allowance: 60,000 THB
        // Taxable income: 240,000 THB
        // Tax: (240,000 - 150,000) * 5% = 4,500 THB
        final input = TaxInput(annualIncome: Decimal.fromInt(300000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.taxableIncome, Decimal.fromInt(240000));
        expect(result.calculatedTax, Decimal.fromInt(4500));
        expect(result.bracketBreakdown.length, 2);
      });

      test('should calculate tax for income crossing multiple brackets', () {
        // Income: 600,000 THB, Personal allowance: 60,000 THB
        // Taxable income: 540,000 THB
        // 0-150,000: 0% = 0
        // 150,001-300,000: 5% = 7,500
        // 300,001-500,000: 10% = 20,000
        // 500,001-540,000: 15% = 6,000
        // Total: 33,500 THB
        final input = TaxInput(annualIncome: Decimal.fromInt(600000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.taxableIncome, Decimal.fromInt(540000));
        expect(result.calculatedTax, Decimal.fromInt(33500));
        expect(result.bracketBreakdown.length, 4);
      });
    });

    group('Allowances and Deductions', () {
      test('should apply personal, spouse, and child allowances correctly', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(1000000),
          spouseAllowance: Decimal.fromInt(60000),
          numberOfChildren: 2,
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.totalAllowances, Decimal.fromInt(180000)); // 60k + 60k + 60k
        expect(result.taxableIncome, Decimal.fromInt(820000)); // 1M - 180k
      });

      test('should apply common deductions correctly', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(1000000),
          spouseAllowance: Decimal.fromInt(60000),
          numberOfChildren: 2,
          insurancePremium: Decimal.fromInt(50000),
          retirementFund: Decimal.fromInt(100000),
          mortgageInterest: Decimal.fromInt(50000),
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.totalAllowances, Decimal.fromInt(180000));
        expect(result.totalDeductions, Decimal.fromInt(200000));
        expect(result.taxableIncome, Decimal.fromInt(620000)); // 1M - 180k - 200k
      });

      test('should calculate complex tax scenario with all deductions', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(2000000),
          spouseAllowance: Decimal.fromInt(60000),
          numberOfChildren: 3,
          insurancePremium: Decimal.fromInt(100000),
          retirementFund: Decimal.fromInt(300000),
          mortgageInterest: Decimal.fromInt(100000),
          socialSecurityContribution: Decimal.fromInt(9000),
          providentFund: Decimal.fromInt(200000),
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.totalAllowances, Decimal.fromInt(210000)); // 60k + 60k + 90k
        expect(result.totalDeductions, Decimal.fromInt(709000));
        expect(result.taxableIncome, Decimal.fromInt(1081000));
        expect(result.calculatedTax.toDouble(), greaterThan(0));
        expect(result.effectiveTaxRate.toDouble(), greaterThan(0));
      });
    });

    group('Input Validation', () {
      test('should reject negative income', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(-100000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, true);
        expect(result.errorMessage, contains('Invalid input data provided'));
      });

      test('should reject excessive income', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(100000000)); // 100M THB
        final result = calculator.calculateTax(input);

        expect(result.hasError, true);
        expect(result.errorMessage, contains('maximum'));
      });

      test('should reject excessive spouse allowance', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(500000),
          spouseAllowance: Decimal.fromInt(100000), // Over 60k limit
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, true);
        expect(result.errorMessage, contains('Spouse allowance'));
      });

      test('should reject excessive insurance premium', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(500000),
          insurancePremium: Decimal.fromInt(150000), // Over 100k limit
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, true);
        expect(result.errorMessage, contains('Insurance premium'));
      });

      test('should reject excessive retirement fund contribution', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(500000),
          retirementFund: Decimal.fromInt(600000), // Over limit
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, true);
        expect(result.errorMessage, contains('Retirement fund'));
      });
    });

    group('Tax Brackets Validation', () {
      test('should use correct 2024 Thai tax brackets', () {
        // Test each bracket boundary
        final testCases = [
          {'income': 210000, 'expectedTax': 0}, // 210k - 60k = 150k (0% bracket)
          {'income': 220000, 'expectedTax': 500}, // 220k - 60k = 160k, 10k at 5%
          {'income': 360000, 'expectedTax': 7500}, // 360k - 60k = 300k, 150k at 5%
          {'income': 560000, 'expectedTax': 27500}, // 560k - 60k = 500k
        ];

        for (final testCase in testCases) {
          final input = TaxInput(annualIncome: Decimal.fromInt(testCase['income'] as int));
          final result = calculator.calculateTax(input);

          expect(result.hasError, false);
          expect(result.calculatedTax, Decimal.fromInt(testCase['expectedTax'] as int),
              reason: 'Failed for income ${testCase['income']}');
        }
      });

      test('should handle high income scenarios correctly', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(10000000)); // 10M THB
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.taxableIncome, Decimal.fromInt(9940000)); // 10M - 60k
        expect(result.calculatedTax.toDouble(), greaterThan(1000000)); // Should be substantial
        expect(result.marginalTaxRate, Decimal.fromInt(35)); // Top bracket
      });
    });

    group('Edge Cases', () {
      test('should handle zero income', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(0));
        final result = calculator.calculateTax(input);

        expect(result.hasError, true); // Zero income is invalid for tax calculation
        expect(result.errorMessage, contains('Invalid input data'));
      });

      test('should handle income exactly at bracket boundaries', () {
        // Test income exactly at 150,000 + 60,000 = 210,000 (first bracket boundary)
        final input = TaxInput(annualIncome: Decimal.fromInt(210000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.taxableIncome, Decimal.fromInt(150000));
        expect(result.calculatedTax, Decimal.fromInt(0)); // Exactly at boundary
      });

      test('should handle maximum valid deductions', () {
        final input = TaxInput(
          annualIncome: Decimal.fromInt(3000000),
          spouseAllowance: Decimal.fromInt(60000), // Max
          numberOfChildren: 10, // Large family
          insurancePremium: Decimal.fromInt(100000), // Max
          retirementFund: Decimal.fromInt(500000), // Max or 30% rule
          mortgageInterest: Decimal.fromInt(100000), // Max
          socialSecurityContribution: Decimal.fromInt(9000), // Max
        );
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.totalAllowances, Decimal.fromInt(420000)); // 60k + 60k + 300k
        expect(result.totalDeductions.toDouble(), greaterThan(700000));
      });
    });

    group('Tax Result Properties', () {
      test('should calculate effective tax rate correctly', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(1000000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        
        final expectedEffectiveRate = 
            (result.calculatedTax.toDouble() / result.grossIncome.toDouble()) * 100;
        expect(result.effectiveTaxRate.toDouble(), closeTo(expectedEffectiveRate, 0.01));
      });

      test('should calculate net income correctly', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(500000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.netIncome, result.grossIncome - result.calculatedTax);
      });

      test('should populate bracket breakdown correctly', () {
        final input = TaxInput(annualIncome: Decimal.fromInt(600000));
        final result = calculator.calculateTax(input);

        expect(result.hasError, false);
        expect(result.bracketBreakdown.isNotEmpty, true);
        
        // Sum of bracket taxes should equal total tax
        final bracketTaxSum = result.bracketBreakdown
            .map((b) => b.taxAmount)
            .fold(Decimal.fromInt(0), (a, b) => a + b);
        expect(bracketTaxSum, result.calculatedTax);
      });
    });
  });
}