# PRP: Pack-Based Price Comparison Enhancement

## Overview

Enhance the existing Flutter price comparison tool to support products sold in packs where the user needs to compare price per individual piece/unit. Users should be able to specify pack size, individual item quantities, and pack prices to automatically calculate the most cost-effective option.

## Context

### Current State
- Working Flutter app with price comparison feature at `/everyday_helper_app/`
- Clean architecture with features separated by domain (price_comparison feature exists)
- Current Product model at `lib/features/price_comparison/domain/models/product.dart:1` supports simple price/quantity/unit calculations
- Existing UI at `lib/features/price_comparison/presentation/pages/price_comparison_screen.dart:1` with product input forms
- Tests exist at `test/features/price_comparison/` for current functionality

### Requirements
- **User Story**: Compare products sold in packs where quantity is specified per individual piece
- **Example**: 6 boxes of milk A (200ml each, pack costs ₿57) vs 3 boxes of milk B (300ml each, pack costs ₿48)
- **Goal**: Automatically calculate and display price per piece and price per unit (ml/g/etc.)
- **Input Fields**: Product name, pack size (number of items), individual item quantity, unit, total pack price
- **Output**: Price per piece, price per unit, recommendation for best value

### Dependencies
- Existing Flutter dependencies in `pubspec.yaml:1` (provider, cupertino_icons, introduction_screen, super_tooltip, shared_preferences)
- Flutter SDK ^3.8.1
- Current testing framework (flutter_test, flutter_lints)

## Research Findings

### Codebase Analysis
- **Architecture Pattern**: Clean architecture with features/data/domain/presentation layers
- **State Management**: Provider pattern used in `price_comparison_screen.dart:23`
- **Validation**: Custom validation in `product_input_form.dart:61-125`
- **Testing**: Unit tests for models and view models in `test/features/price_comparison/`
- **Constants**: Centralized in `app_constants.dart:1` with `commonUnits` array, validation limits
- **UI Patterns**: Card-based forms, error handling with banners, Material Design

### External Research
- **Flutter Best Practices 2025**: 
  - Use widget composition and avoid heavy build() methods for dynamic calculations
  - Repository pattern for data management (already implemented)
  - BLoC/Provider for state management (Provider already used)
  - Clean separation of concerns with domain models
  
- **UX Patterns for Pack/Piece Calculations**:
  - 86% of e-commerce sites fail to display price per unit - this is a competitive advantage
  - Mobile users prefer hybrid quantity inputs (buttons + text field)
  - Card-based design works best on mobile (already implemented)
  - Price per unit should be prominently displayed alongside total price
  
- **Flutter Quantity Input Packages**:
  - `input_quantity` package available for enhanced quantity selectors
  - Custom validation and step values for pack sizes
  - Manual input support for large quantities

### Best Practices References
- Flutter Documentation: https://docs.flutter.dev/ui/adaptive-responsive/best-practices
- Flutter App Architecture: https://docs.flutter.dev/app-architecture/guide
- Baymard Institute UX Research: Price per unit display patterns
- DHiWise Flutter Quantity Widget: https://www.dhiwise.com/post/how-to-implement-flutter-quantity-widget

## Implementation Plan

### Pseudocode/Algorithm
```dart
class PackProduct {
  // Enhanced product model
  String id, name, unit;
  int packSize;              // Number of items in pack
  double individualQuantity; // Quantity per individual item
  double packPrice;          // Total price for the pack
  
  // Calculated properties
  double get pricePerPiece => packPrice / packSize;
  double get totalQuantity => packSize * individualQuantity;
  double get pricePerUnit => packPrice / totalQuantity;
}

// Comparison Algorithm
1. For each product, calculate pricePerPiece and pricePerUnit
2. Normalize all units to common base (ml, g, etc.)
3. Rank products by pricePerUnit (lowest = best value)
4. Display comparison with visual indicators
```

### Tasks (in order)
1. **Enhance Product Model** 
   - Add `packSize` and `individualQuantity` fields to Product model
   - Update calculated properties for pack-based pricing
   - Add validation for pack-specific fields
   - Update serialization methods

2. **Update Product Input Form**
   - Add pack size input field with quantity selector widget
   - Add individual quantity field for per-piece measurements
   - Update validation logic for pack scenarios
   - Enhance UX with clear labeling and examples

3. **Enhance Comparison Logic**
   - Update PriceComparisonViewModel to handle pack calculations
   - Add methods for price per piece and normalized unit comparisons
   - Implement ranking algorithm for best value determination

4. **Update Results Display**
   - Show pack details (X items × Y unit each = Z total)
   - Display price per piece prominently
   - Highlight best value option with visual indicators
   - Add detailed breakdown view

5. **Update Tests**
   - Add unit tests for enhanced Product model
   - Test pack calculation scenarios
   - Update existing tests for backward compatibility
   - Add widget tests for new UI components

6. **Update Help System**
   - Add examples showing pack vs piece scenarios
   - Update tutorial with pack comparison workflow
   - Add tooltips explaining pack size concepts

### File Structure
```
everyday_helper_app/
├── lib/features/price_comparison/
│   ├── domain/models/
│   │   ├── product.dart (enhanced)
│   │   └── pack_product.dart (new)
│   ├── presentation/
│   │   ├── widgets/
│   │   │   ├── product_input_form.dart (enhanced)
│   │   │   ├── pack_size_selector.dart (new)
│   │   │   └── results_display.dart (enhanced)
│   │   └── view_models/
│   │       └── price_comparison_view_model.dart (enhanced)
│   └── data/ (if needed for unit conversion)
└── test/features/price_comparison/ (updated tests)
```

## Validation Gates

### Syntax/Style Checks
```bash
cd everyday_helper_app
flutter analyze
dart format --set-exit-if-changed .
```

### Testing Commands
```bash
cd everyday_helper_app
flutter test
flutter test test/features/price_comparison/
```

### Manual Validation
- [ ] Can add products with pack sizes (e.g., 6-pack, 12-pack)
- [ ] Individual quantities are properly specified (200ml per piece)
- [ ] Pack price calculation shows correct price per piece
- [ ] Price per unit normalization works across different units
- [ ] Best value recommendation is accurate
- [ ] UI clearly shows pack breakdown (6 × 200ml = 1200ml total)
- [ ] Existing simple products still work without pack fields
- [ ] Form validation prevents invalid pack configurations
- [ ] Help system explains pack vs piece concepts clearly

## Error Handling

### Common Issues
- **Unit Mismatch**: Implement unit conversion system or force same units for comparison
- **Zero Pack Size**: Validate pack size > 0 and individual quantity > 0
- **Large Numbers**: Use appropriate number formatting and validation limits
- **Backward Compatibility**: Ensure existing products without pack data still function

### Troubleshooting
- **Performance Issues**: Use `const` constructors and avoid rebuilds in calculations
- **State Management**: Ensure Provider updates trigger UI refreshes correctly
- **Validation Conflicts**: Clear error states when switching between pack and simple modes
- **Mobile UX**: Test pack size selector usability on different screen sizes

## Quality Checklist

- [ ] All requirements from INIT.md implemented
- [ ] Code follows existing architecture patterns from codebase
- [ ] New features integrate seamlessly with existing price comparison tool
- [ ] Validation passes for both new and existing functionality
- [ ] Mobile-optimized UX for pack size selection
- [ ] Error handling covers edge cases
- [ ] Tests cover new pack calculation scenarios
- [ ] Help documentation updated with examples
- [ ] Performance optimized for real-time calculations
- [ ] Accessibility considerations for form inputs

## Confidence Score

**8/10** - High confidence for one-pass implementation success

**Rationale**: 
- **Strengths**: Excellent existing codebase with clean architecture, comprehensive research completed, clear requirements, solid Flutter foundation
- **Risk Factors**: Complex UI changes require careful testing, unit conversion logic needs robust implementation
- **Mitigation**: Well-defined validation gates, extensive testing plan, existing patterns to follow

The existing codebase provides excellent patterns to follow, the requirements are clear and specific, and the research provides solid UX guidance. The main complexity lies in enhancing the UI while maintaining usability, but the current architecture supports this enhancement well.

## References

- **Flutter Documentation**: https://docs.flutter.dev/ui/widgets (Form widgets and validation)
- **Existing Product Model**: `everyday_helper_app/lib/features/price_comparison/domain/models/product.dart:1`
- **Current Input Form**: `everyday_helper_app/lib/features/price_comparison/presentation/widgets/product_input_form.dart:1`
- **App Constants**: `everyday_helper_app/lib/shared/constants/app_constants.dart:28` (units array)
- **UX Research**: Baymard Institute - "Display Price Per Unit for Multiquantity Items"
- **Flutter Quantity Widget**: https://www.dhiwise.com/post/how-to-implement-flutter-quantity-widget
- **Flutter Best Practices 2025**: https://docs.flutter.dev/app-architecture/guide