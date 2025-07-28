# PRP: Exchange Rate Calculator with Multiplier Chains

## Overview

Implement a Flutter-based exchange rate calculator that allows users to view current exchange rates, convert amounts between currencies, and apply multiple multipliers in a chain for complex calculations. The feature supports automatic rate fetching, currency switching, step-by-step result display, and formula memory.

## Context

### Current State
- Flutter project with feature-based clean architecture
- Existing features: price_comparison, mathematics, tax_calculator, subnet_calculator
- Architecture follows domain/presentation/data layers with ViewModels
- Uses Provider for state management
- Shared utilities for theme, constants, and widgets
- Lazy loading with performance optimization

### Requirements
Based on INIT.md analysis:

**Core Features:**
1. **Exchange Rate Display**: Show current rates (e.g., USD → THB) with refresh capability
2. **Currency Switching**: Allow users to swap source/target currencies
3. **Amount Input**: Input field for amount to convert 
4. **Multiple Multipliers**: Dynamic addition/removal of multiplier fields
5. **Step-by-step Results**: Show calculation results for each step
6. **Auto-calculation**: Calculate results automatically on data changes
7. **Formula Memory**: Remember last used formula/setup
8. **Swipe-to-delete**: Remove multipliers with left swipe gesture

**UI Requirements:**
```
┌─────────────────────────────┐
│ 💱 [USD] → [THB]            ▼  ← selectable
│ Rate: 1 USD = 36.45 THB     ⟳ ← refresh
├─────────────────────────────┤
│ 💰 ใส่จำนวนเงิน: [ 17     ]  ← user input
│ × ตัวคูณ:         [ 8      ]  ← user input
│ × ตัวคูณต่อ:      [ 30     ]  ← user input
│                           ▼ เพิ่มตัวคูณอีก
├─────────────────────────────┤
│ 📊 ผลลัพธ์:                   │
│ 17 USD = 620 THB            │
│ 620 × 8 = 4,960 THB         │
│ 4,960 × 30 = 148,800 THB    │
└─────────────────────────────┘
```

### Dependencies
- **HTTP requests**: Use existing http package (should be added to pubspec.yaml)
- **State persistence**: Use existing shared_preferences: ^2.2.0
- **State management**: Existing provider: ^6.1.1
- **Number formatting**: Existing intl: ^0.20.2
- **API**: Frankfurter API (https://api.frankfurter.dev/v1/latest) - Free, no auth required

## Research Findings

### Codebase Analysis

**Architecture Pattern:**
- Feature structure: `lib/features/{feature_name}/{domain,presentation,data}/`
- Domain models: Plain Dart classes with validation and serialization
- Presentation ViewModels: Extend ChangeNotifier with business logic
- Presentation Pages: StatefulWidget with Consumer<ViewModel>
- Presentation Widgets: Reusable UI components

**Reference Files:**
- `lib/features/price_comparison/domain/models/product.dart` - Model structure
- `lib/features/price_comparison/presentation/view_models/price_comparison_view_model.dart` - ViewModel pattern
- `lib/features/price_comparison/presentation/pages/price_comparison_screen.dart` - Screen structure  
- `lib/shared/constants/app_constants.dart` - App constants pattern
- `lib/routes/app_routes.dart` - Routing with lazy loading

**Testing Pattern:**
- Unit tests for ViewModels: `test/features/{feature}/presentation/view_models/`
- Arrange-Act-Assert pattern
- Mock data setup in setUp()
- Comprehensive validation testing

### External Research

**Frankfurter API Documentation (https://frankfurter.dev):**
- Free exchange rate API, no authentication required
- Endpoint: `https://api.frankfurter.dev/v1/latest?base={from}&symbols={to}`
- Updated daily around 16:00 CET from European Central Bank
- Supports major currencies: USD, THB, EUR, GBP, etc.
- Example response:
```json
{
  "amount": 1.0,
  "base": "USD", 
  "date": "2024-01-15",
  "rates": {
    "THB": 36.45
  }
}
```

**Flutter Best Practices:**
- Use proper error handling for network requests
- Implement loading states during API calls
- Cache exchange rates to avoid excessive requests
- Use proper number formatting for currency display
- Implement proper form validation

**Common Pitfalls:**
- Network connectivity issues - implement offline fallback
- Rate limiting - cache results and avoid frequent requests
- Precision issues with floating point - use proper decimal handling
- Currency code validation - ensure supported currencies only

## Implementation Plan

### Pseudocode/Algorithm
```dart
// Exchange Rate Calculator Core Logic
class ExchangeRateCalculator {
  1. Initialize with saved formula from SharedPreferences
  2. Fetch exchange rates from Frankfurter API
  3. On amount or currency change:
     - Convert base amount using current rate
     - Apply multipliers in sequence
     - Display step-by-step results
  4. On multiplier add/remove:
     - Update multiplier list
     - Recalculate all results
     - Save formula to SharedPreferences
  5. On currency switch:
     - Swap base/target currencies
     - Refresh exchange rates
     - Recalculate results
}
```

### Tasks (in order)
1. **Create domain models**: ExchangeRate, Currency, MultiplierFormula, CalculationStep
2. **Implement data layer**: ExchangeRateRepository with Frankfurter API integration  
3. **Create ExchangeRateViewModel**: Core business logic and state management
4. **Build main screen UI**: Currency selector, amount input, multiplier management
5. **Implement multiplier widgets**: Dynamic add/remove with swipe gestures
6. **Create results display**: Step-by-step calculation visualization
7. **Add formula persistence**: SharedPreferences integration for memory
8. **Implement currency switching**: Swap functionality with rate refresh
9. **Add error handling**: Network errors, invalid inputs, API failures
10. **Create comprehensive tests**: Unit tests for models, ViewModels, and widgets
11. **Integrate with app routing**: Add to AppRoutes and home screen
12. **Performance optimization**: Lazy loading and caching

### File Structure
```
lib/features/exchange_rate/
├── domain/
│   ├── models/
│   │   ├── exchange_rate.dart
│   │   ├── currency.dart
│   │   ├── multiplier_formula.dart
│   │   └── calculation_step.dart
│   ├── repositories/
│   │   └── exchange_rate_repository.dart
│   └── use_cases/
│       ├── fetch_exchange_rates_use_case.dart
│       ├── calculate_with_multipliers_use_case.dart
│       └── save_formula_use_case.dart
├── data/
│   ├── repositories/
│   │   └── exchange_rate_repository_impl.dart
│   ├── datasources/
│   │   └── frankfurter_api_datasource.dart
│   └── models/
│       └── exchange_rate_response.dart
└── presentation/
    ├── pages/
    │   └── exchange_rate_screen.dart
    ├── view_models/
    │   └── exchange_rate_view_model.dart
    └── widgets/
        ├── currency_selector.dart
        ├── multiplier_input.dart
        ├── multiplier_list.dart
        ├── calculation_results.dart
        └── exchange_rate_header.dart

test/features/exchange_rate/
├── domain/models/
├── presentation/view_models/
└── data/repositories/
```

## Validation Gates

### Syntax/Style Checks
```bash
# Flutter analyze
flutter analyze

# Dart format check
dart format --set-exit-if-changed .

# Flutter test
flutter test
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific feature tests
flutter test test/features/exchange_rate/

# Run with coverage
flutter test --coverage
```

### Manual Validation
- [ ] Exchange rates load successfully from Frankfurter API
- [ ] Currency switching works correctly 
- [ ] Amount input accepts numeric values with proper validation
- [ ] Multipliers can be added dynamically with + button
- [ ] Multipliers can be removed with swipe gesture
- [ ] Step-by-step calculations display correctly
- [ ] Auto-calculation works on any input change
- [ ] Formula is saved and restored on app restart
- [ ] Error handling works for network failures
- [ ] Number formatting follows currency conventions
- [ ] UI matches the specified design layout
- [ ] App remains responsive during API calls

## Error Handling

### Common Issues
- **Network connectivity**: Implement offline mode with cached rates and user notification
- **API rate limiting**: Cache responses for reasonable duration (1 hour minimum)
- **Invalid currency codes**: Validate against supported currency list
- **Precision errors**: Use intl package for proper currency formatting
- **Empty/invalid inputs**: Comprehensive validation with user-friendly error messages

### Troubleshooting
- **API failures**: Show error banner with retry option
- **Calculation errors**: Reset to last valid state
- **Performance issues**: Implement debouncing for rapid input changes
- **Memory leaks**: Properly dispose ViewModels and streams

## Quality Checklist

- [ ] All requirements from INIT.md implemented
- [ ] Code follows existing codebase patterns (Provider, ChangeNotifier, clean architecture)
- [ ] Comprehensive unit tests for all ViewModels and models
- [ ] Error handling covers network and validation scenarios  
- [ ] UI matches specified design with proper Thai/English labels
- [ ] Performance optimized with proper state management
- [ ] Accessibility considerations implemented
- [ ] Formula persistence works correctly
- [ ] Integration tests for critical user flows
- [ ] Documentation updated in relevant files

## Confidence Score

9/10 - Very high confidence for successful one-pass implementation

**Rationale:**
- **Architecture clarity**: Clear understanding of existing patterns from codebase analysis
- **API simplicity**: Frankfurter API is well-documented and straightforward
- **Similar patterns**: Price comparison feature provides excellent reference implementation
- **Complete requirements**: INIT.md provides detailed specifications with UI mockup
- **Testing foundation**: Existing test patterns are comprehensive and reusable
- **Dependencies available**: All required packages already in project or easily added

**Minor risks:**
- Network handling edge cases might need iteration
- UI fine-tuning for optimal UX might require minor adjustments

## References

### Documentation
- **Flutter Docs**: https://docs.flutter.dev/get-started/fundamentals
- **Frankfurter API**: https://frankfurter.dev
- **Provider Package**: https://pub.dev/packages/provider
- **SharedPreferences**: https://pub.dev/packages/shared_preferences
- **Intl Package**: https://pub.dev/packages/intl

### Code Examples  
- **Reference ViewModel**: `lib/features/price_comparison/presentation/view_models/price_comparison_view_model.dart`
- **Reference Screen**: `lib/features/price_comparison/presentation/pages/price_comparison_screen.dart`
- **Reference Model**: `lib/features/price_comparison/domain/models/product.dart`
- **Reference Tests**: `test/features/price_comparison/presentation/view_models/price_comparison_view_model_test.dart`

### Best Practices Resources
- **Flutter State Management**: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
- **API Integration**: https://docs.flutter.dev/data-and-backend/networking
- **Testing Flutter Apps**: https://docs.flutter.dev/testing
- **Accessibility**: https://docs.flutter.dev/accessibility-and-localization/accessibility