import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:everyday_helper_app/features/tax_calculator/presentation/view_models/tax_calculator_view_model.dart';

void main() {
  group('TaxCalculatorViewModel Tests', () {
    late TaxCalculatorViewModel viewModel;

    setUp(() {
      viewModel = TaxCalculatorViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initial State', () {
      test('should start with default values', () {
        expect(viewModel.currentInput.annualIncome, Decimal.fromInt(0));
        expect(viewModel.currentInput.spouseAllowance, Decimal.fromInt(0));
        expect(viewModel.currentInput.numberOfChildren, 0);
        expect(viewModel.currentResult, null);
        expect(viewModel.hasError, false);
        expect(viewModel.isCalculating, false);
        expect(viewModel.isDirty, false);
      });

      test('should have empty calculation history initially', () {
        expect(viewModel.calculationHistory, isEmpty);
      });

      test('should have available deductions loaded', () {
        expect(viewModel.availableDeductions, isNotEmpty);
      });
    });

    group('Input Updates', () {
      test('should update annual income correctly', () {
        viewModel.updateAnnualIncome('500000');

        expect(viewModel.currentInput.annualIncome, Decimal.fromInt(500000));
        expect(viewModel.isDirty, true);
        expect(viewModel.formErrors.containsKey('annualIncome'), false);
      });

      test('should handle invalid annual income input', () {
        viewModel.updateAnnualIncome('invalid');

        expect(viewModel.formErrors.containsKey('annualIncome'), true);
        expect(viewModel.formErrors['annualIncome'], contains('Invalid'));
      });

      test('should update spouse allowance correctly', () {
        viewModel.updateSpouseAllowance('60000');

        expect(viewModel.currentInput.spouseAllowance, Decimal.fromInt(60000));
        expect(viewModel.isDirty, true);
      });

      test('should update number of children correctly', () {
        viewModel.updateNumberOfChildren(3);

        expect(viewModel.currentInput.numberOfChildren, 3);
        expect(viewModel.isDirty, true);
      });

      test('should update insurance premium correctly', () {
        viewModel.updateInsurancePremium('50000');

        expect(viewModel.currentInput.insurancePremium, Decimal.fromInt(50000));
        expect(viewModel.isDirty, true);
      });

      test('should update retirement fund correctly', () {
        viewModel.updateRetirementFund('100000');

        expect(viewModel.currentInput.retirementFund, Decimal.fromInt(100000));
        expect(viewModel.isDirty, true);
      });

      test('should clear field errors when input becomes valid', () {
        // Set invalid input first
        viewModel.updateAnnualIncome('invalid');
        expect(viewModel.formErrors.containsKey('annualIncome'), true);

        // Fix the input
        viewModel.updateAnnualIncome('500000');
        expect(viewModel.formErrors.containsKey('annualIncome'), false);
      });
    });

    group('Tax Calculation', () {
      test('should calculate tax successfully with valid input', () async {
        viewModel.updateAnnualIncome('500000');

        await viewModel.calculateTax();

        expect(viewModel.hasResult, true);
        expect(viewModel.hasError, false);
        expect(viewModel.currentResult?.hasError, false);
        expect(
          viewModel.isDirty,
          false,
        ); // Should be false after successful calculation
      });

      test('should handle calculation with deductions', () async {
        viewModel.updateAnnualIncome('1000000');
        viewModel.updateSpouseAllowance('60000');
        viewModel.updateNumberOfChildren(2);
        viewModel.updateInsurancePremium('50000');
        viewModel.updateRetirementFund('100000');

        await viewModel.calculateTax();

        expect(viewModel.hasResult, true);
        expect(
          viewModel.currentResult?.totalAllowances,
          Decimal.fromInt(180000),
        ); // 60k + 60k + 60k
        expect(
          viewModel.currentResult?.totalDeductions,
          Decimal.fromInt(150000),
        ); // 50k + 100k
      });

      test('should add calculation to history', () async {
        expect(viewModel.calculationHistory, isEmpty);

        viewModel.updateAnnualIncome('500000');
        await viewModel.calculateTax();

        expect(viewModel.calculationHistory, isNotEmpty);
        expect(viewModel.calculationHistory.length, 1);
      });

      test('should fail validation with empty income', () async {
        await viewModel.calculateTax();

        expect(viewModel.hasResult, false);
        expect(viewModel.formErrors.containsKey('annualIncome'), true);
      });

      test('should fail validation with excessive income', () async {
        viewModel.updateAnnualIncome('100000000'); // 100M THB
        await viewModel.calculateTax();

        expect(viewModel.formErrors.containsKey('annualIncome'), true);
      });

      test('should fail validation with excessive spouse allowance', () async {
        viewModel.updateAnnualIncome('500000');
        viewModel.updateSpouseAllowance('100000'); // Over limit
        await viewModel.calculateTax();

        expect(viewModel.formErrors.containsKey('spouseAllowance'), true);
      });

      test('should prevent concurrent calculations', () async {
        viewModel.updateAnnualIncome('500000');

        // Start first calculation
        final future1 = viewModel.calculateTax();

        // Try to start second calculation immediately
        final future2 = viewModel.calculateTax();

        await Future.wait([future1, future2]);

        // Should still have valid result
        expect(viewModel.hasResult, true);
      });
    });

    group('Form State Management', () {
      test('should reset form correctly', () {
        viewModel.updateAnnualIncome('500000');
        viewModel.updateSpouseAllowance('60000');
        viewModel.updateNumberOfChildren(2);

        viewModel.resetForm();

        expect(viewModel.currentInput.annualIncome, Decimal.fromInt(0));
        expect(viewModel.currentInput.spouseAllowance, Decimal.fromInt(0));
        expect(viewModel.currentInput.numberOfChildren, 0);
        expect(viewModel.currentResult, null);
        expect(viewModel.isDirty, false);
        expect(viewModel.formErrors, isEmpty);
      });

      test('should track dirty state correctly', () {
        expect(viewModel.isDirty, false);

        viewModel.updateAnnualIncome('500000');
        expect(viewModel.isDirty, true);

        viewModel.resetForm();
        expect(viewModel.isDirty, false);
      });

      test('should manage error state correctly', () {
        expect(viewModel.hasError, false);

        viewModel.updateAnnualIncome('invalid');
        expect(viewModel.formErrors.isNotEmpty, true);

        viewModel.updateAnnualIncome('500000');
        expect(viewModel.formErrors.containsKey('annualIncome'), false);
      });
    });

    group('History Management', () {
      test('should clear history correctly', () async {
        // Add some calculations to history
        viewModel.updateAnnualIncome('500000');
        await viewModel.calculateTax();

        viewModel.updateAnnualIncome('600000');
        await viewModel.calculateTax();

        expect(viewModel.calculationHistory.length, 2);

        viewModel.clearHistory();
        expect(viewModel.calculationHistory, isEmpty);
      });

      test('should limit history size', () async {
        // Add many calculations
        for (int i = 1; i <= 60; i++) {
          viewModel.updateAnnualIncome('${500000 + i * 1000}');
          await viewModel.calculateTax();
        }

        // Should be limited to 50 (as per implementation)
        expect(viewModel.calculationHistory.length, lessThanOrEqualTo(50));
      });

      test('should use history result correctly', () async {
        viewModel.updateAnnualIncome('500000');
        viewModel.updateSpouseAllowance('60000');
        await viewModel.calculateTax();

        final historyResult = viewModel.calculationHistory.first;

        // Reset form
        viewModel.resetForm();
        expect(viewModel.currentInput.annualIncome, Decimal.fromInt(0));

        // Use history result
        viewModel.useHistoryResult(historyResult);
        expect(viewModel.currentInput.annualIncome, historyResult.grossIncome);
      });
    });

    group('Utility Methods', () {
      test('should format currency correctly', () {
        final formatted = viewModel.formatCurrency(Decimal.fromInt(1234567));
        expect(formatted, '1,234,567.00');
      });

      test('should format percentage correctly', () {
        final formatted = viewModel.formatPercentage(Decimal.parse('12.345'));
        expect(formatted, '12.35');
      });

      test('should calculate estimated tax correctly', () {
        viewModel.updateAnnualIncome('500000');
        expect(
          viewModel.estimatedTax,
          Decimal.fromInt(0),
        ); // No calculation yet

        viewModel.updateInputAndCalculate();
        expect(viewModel.estimatedTax.toDouble(), greaterThanOrEqualTo(0));
      });
    });

    group('Tab Management', () {
      test('should change tabs correctly', () {
        expect(viewModel.currentTabIndex, 0);

        viewModel.setCurrentTab(1);
        expect(viewModel.currentTabIndex, 1);

        viewModel.setCurrentTab(2);
        expect(viewModel.currentTabIndex, 2);
      });

      test('should not change tab if same index', () {
        viewModel.setCurrentTab(0);
        expect(viewModel.currentTabIndex, 0);

        // Should not trigger notification for same index
        viewModel.setCurrentTab(0);
        expect(viewModel.currentTabIndex, 0);
      });
    });

    group('Auto-calculation', () {
      test('should auto-calculate for valid input', () {
        viewModel.updateAnnualIncome('500000');
        viewModel.updateInputAndCalculate();

        // Should have a result from auto-calculation
        expect(viewModel.currentResult, isNotNull);
        expect(viewModel.currentResult?.hasError, false);
      });

      test('should not auto-calculate for invalid input', () {
        viewModel.updateInputAndCalculate(); // No income set

        // Should not have auto-calculated
        expect(viewModel.currentResult, null);
      });
    });
  });
}
