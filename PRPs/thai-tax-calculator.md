# PRP: Thai Tax Calculator Feature

## Overview

Create a comprehensive Thai tax calculator as a new feature in the Everyday Helper App. This feature will help users calculate their personal income tax and understand available deductions according to Thai Revenue Department regulations. The calculator will include educational components to help users understand the tax calculation process.

## Context

### Current State
- Existing Flutter app with clean architecture in `everyday_helper_app/`
- Features structure: `lib/features/{feature_name}/domain/models`, `presentation/pages`, `presentation/view_models`
- Current tools: Price Comparison, Mathematics (calculators, statistics, unit conversion)
- Uses Provider for state management, Material Design with custom theming
- Lazy loading system via FeatureLoader for performance optimization

### Requirements
From INIT.md:
- **Primary Goal**: Tax helper app for tax calculation and deduction optimization
- **Framework**: Flutter development required
- **UX/UI**: Simple, non-complex interface with uniform layout
- **Extensibility**: Easy to improve and further develop
- **Reference**: Thai Revenue Department regulations and existing tax calculators

### Dependencies
```yaml
# Existing dependencies (already in pubspec.yaml)
provider: ^6.1.1                 # State management
cupertino_icons: ^1.0.8          # Icons
decimal: ^3.0.2                  # Precise decimal calculations
math_expressions: ^2.6.0         # Expression parsing

# New dependencies needed
intl: ^0.18.0                    # Date/currency formatting
shared_preferences: ^2.2.0       # Local storage for tax data
```

## Research Findings

### Codebase Analysis
**Existing Patterns to Follow:**
- **Feature Structure**: `lib/features/tax_calculator/domain/models/`, `presentation/pages/`, `presentation/view_models/`
- **Model Pattern**: Follow `lib/features/mathematics/domain/models/calculation.dart` structure
- **Screen Pattern**: Follow `lib/features/mathematics/presentation/pages/mathematics_screen.dart` grid layout
- **Registration**: Add to `lib/features/home/models/helper_tool.dart` in `availableTools` list
- **Routing**: Add routes to `lib/shared/constants/app_constants.dart` and `lib/routes/app_routes.dart`
- **State Management**: Use Provider pattern like `lib/features/mathematics/presentation/view_models/`

### External Research
**Thai Tax System (2023-2024):**
- **Personal Income Tax Brackets**: 0%, 5%, 10%, 20%, 30%, 37%
- **Personal Allowances**: 60,000 THB personal, 60,000 THB spouse, 30,000 THB per child
- **Common Deductions**: Insurance (100,000 THB), retirement fund (500,000 THB), mortgage interest (100,000 THB)
- **Documentation**: https://www.rd.go.th/63765.html, https://www.rd.go.th/59674.html

**Flutter Tax Calculator References:**
- https://github.com/vipulagrahari/taxvisor - Educational tax calculator with Flutter/Firebase
- https://github.com/twmbx/flutter-tax-calc - Country-specific (Zambia) tax calculator structure
- Pattern: Input forms → calculation engine → results display → educational content

## Implementation Plan

### Pseudocode/Algorithm
```dart
// Tax calculation engine
class ThaiTaxCalculator {
  TaxResult calculateTax(TaxInput input) {
    1. Calculate gross annual income
    2. Apply personal allowances and deductions
    3. Calculate taxable income
    4. Apply progressive tax brackets
    5. Calculate final tax amount
    6. Generate breakdown with educational explanations
  }
}

// UI Flow
TaxCalculatorScreen → Input Forms → Calculate → Results Display → Educational Content
```

### Tasks (in order)
1. **Create domain models** for tax calculation (TaxInput, TaxResult, TaxBracket, Deduction)
2. **Implement tax calculation engine** with Thai tax rules and brackets
3. **Create presentation layer** with input forms, results display, and educational components
4. **Add view model** for state management using Provider pattern
5. **Create main tax calculator screen** with tabbed interface (Calculator, History, Help)
6. **Register feature** in app routing and helper tools list
7. **Add validation** for tax calculation inputs and error handling
8. **Create educational components** with tooltips and explanations
9. **Implement calculation history** with local storage
10. **Add tests** for tax calculation logic and UI components

### File Structure
```
everyday_helper_app/lib/features/tax_calculator/
├── domain/
│   ├── models/
│   │   ├── tax_input.dart
│   │   ├── tax_result.dart
│   │   ├── tax_bracket.dart
│   │   ├── deduction.dart
│   │   └── tax_calculation.dart
│   └── use_cases/
│       └── thai_tax_calculator.dart
├── presentation/
│   ├── pages/
│   │   ├── tax_calculator_screen.dart
│   │   ├── tax_input_screen.dart
│   │   ├── tax_results_screen.dart
│   │   └── tax_help_screen.dart
│   ├── view_models/
│   │   └── tax_calculator_view_model.dart
│   └── widgets/
│       ├── tax_input_form.dart
│       ├── deduction_selector.dart
│       ├── tax_breakdown_card.dart
│       ├── educational_tooltip.dart
│       └── calculation_history_list.dart
└── test/
    ├── domain/
    │   └── thai_tax_calculator_test.dart
    └── presentation/
        └── tax_calculator_view_model_test.dart
```

## Validation Gates

### Syntax/Style Checks
```bash
# Run Flutter analyzer
flutter analyze

# Format code
dart format .

# Check for linting issues
flutter run --analyze
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific tax calculator tests
flutter test test/features/tax_calculator/

# Run integration tests
flutter test integration_test/
```

### Manual Validation
- [ ] Tax calculation matches Thai Revenue Department brackets
- [ ] Personal allowances and deductions calculate correctly
- [ ] Input validation works for all edge cases
- [ ] Educational content displays correctly
- [ ] History saves and loads properly
- [ ] UI follows existing app design patterns
- [ ] Performance is acceptable on low-end devices
- [ ] Accessibility features work properly

## Error Handling

### Common Issues
- **Invalid Income Input**: Validate positive numbers, reasonable ranges (0-50M THB)
- **Missing Deduction Data**: Provide default values, clear error messages
- **Calculation Overflow**: Use Decimal library for precise calculations
- **Storage Errors**: Graceful fallback when SharedPreferences fails
- **Network Issues**: All calculations should work offline

### Troubleshooting
```dart
// Input validation example
if (income < 0 || income > 50000000) {
  throw ValidationException('Income must be between 0 and 50,000,000 THB');
}

// Calculation error handling
try {
  final result = taxCalculator.calculate(input);
  return result;
} on TaxCalculationException catch (e) {
  return TaxResult.error(message: e.message);
}
```

## Quality Checklist

- [ ] All tax brackets and rates match official Thai Revenue Department data
- [ ] Code follows existing Flutter project patterns and architecture
- [ ] All validation gates pass (syntax, tests, manual checks)
- [ ] Feature properly registered in app navigation and home screen
- [ ] Educational content helps users understand tax calculations
- [ ] Error handling covers edge cases and invalid inputs
- [ ] Performance optimized with lazy loading pattern
- [ ] Accessibility features implemented for all interactive elements
- [ ] Local storage works for calculation history
- [ ] UI/UX follows Material Design guidelines and existing app theme

## Confidence Score

**8/10** - High confidence for successful one-pass implementation

**Rationale:**
- **Strong foundation**: Existing codebase has clear patterns and architecture that can be followed
- **Complete research**: Thai tax rules and calculation methods are well-documented
- **Similar features exist**: Mathematics calculators provide excellent reference patterns
- **Clear requirements**: INIT.md provides specific, achievable goals
- **External examples**: Multiple Flutter tax calculator implementations available for reference

**Risk factors (-2 points):**
- Thai tax regulations may have edge cases not covered in research
- Complex deduction interactions might require iterative refinement

## References

### Thai Tax Documentation
- **Tax Calculation Guide**: https://www.rd.go.th/63765.html
- **Tax Deductions**: https://www.rd.go.th/59674.html
- **Revenue Department Main Site**: https://www.rd.go.th/

### Flutter Tax Calculator Examples
- **Educational Tax Calculator**: https://github.com/vipulagrahari/taxvisor
- **Country-specific Implementation**: https://github.com/twmbx/flutter-tax-calc
- **General Tax Calculator**: https://github.com/rayhaanbhikha/tax_calculator

### Codebase References
- **Mathematics Feature**: `everyday_helper_app/lib/features/mathematics/`
- **Price Comparison Feature**: `everyday_helper_app/lib/features/price_comparison/`
- **App Routes**: `everyday_helper_app/lib/routes/app_routes.dart`
- **Helper Tools Model**: `everyday_helper_app/lib/features/home/models/helper_tool.dart`
- **Constants**: `everyday_helper_app/lib/shared/constants/app_constants.dart`

### Technical Documentation
- **Flutter Docs**: https://docs.flutter.dev/get-started/fundamentals
- **Provider State Management**: https://pub.dev/packages/provider
- **Decimal Calculations**: https://pub.dev/packages/decimal
- **Thai Localization**: https://flutter.dev/docs/development/accessibility-and-localization/internationalization