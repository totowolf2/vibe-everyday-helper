# PRP: Subnet Calculator (IPv4 Network Calculator)

## Overview

Implementation of a comprehensive subnet calculator feature for the everyday helper app. This feature will provide network administrators and IT professionals with tools to calculate subnet mask information and validate IP addresses within specific subnets. The calculator will support both CIDR notation and traditional subnet mask formats, displaying comprehensive network information including network address, broadcast address, and usable host ranges.

## Context

### Current State
- Flutter app with established clean architecture in `everyday_helper_app/`
- Feature-based structure with domain/presentation separation
- Existing mathematics feature with calculator patterns at `lib/features/mathematics/`
- Provider-based state management already implemented
- Form validation patterns established in price comparison and tax calculator features
- No networking calculation features currently exist

### Requirements
Based on INIT.md specifications:

**Primary Functions:**
1. **Subnet Mask Calculation:**
   - Input: IP Address + Prefix Length (CIDR) OR IP Address + Subnet Mask
   - Output: Network Address, Broadcast Address, First/Last Usable Host, Number of Usable Hosts, Subnet Mask/Prefix Length conversion

2. **IP Address Validation within Subnet:**
   - Input: IP Address to check + Network Address/Subnet Mask of target subnet
   - Output: Clear confirmation whether IP belongs to specified subnet
   - Support for multiple IP validation against single subnet

**UX Requirements:**
- Thai language support for UI elements
- Clear error messaging for invalid inputs
- Easy-to-read, organized results display
- Consistent with existing app UI patterns

### Dependencies
- **Existing:** `provider: ^6.1.1`, `flutter/material`, `dart:io`
- **New:** No additional dependencies required - will implement custom calculation logic
- **Validation:** Use existing form validation patterns from other features

## Research Findings

### Codebase Analysis
**Similar Patterns Found:**
- `lib/features/mathematics/domain/models/calculation.dart` - Calculation history and result models
- `lib/features/mathematics/presentation/view_models/basic_calculator_view_model.dart` - State management patterns
- `lib/features/tax_calculator/presentation/widgets/tax_input_form.dart` - Form input validation patterns
- `lib/features/price_comparison/domain/models/product.dart` - Input validation and error handling

**Files to Reference:**
- Home screen integration: `lib/features/home/models/helper_tool.dart`
- Routing: `lib/routes/app_routes.dart`
- Theme consistency: `lib/shared/theme/app_theme.dart`
- Constants: `lib/shared/constants/app_constants.dart`

**Existing Conventions:**
- Clean architecture: domain/models, domain/use_cases, presentation/pages, presentation/view_models, presentation/widgets
- Provider pattern for state management
- Form validation with error messaging
- History/persistence patterns for calculations
- Material Design UI components

### External Research
**Documentation Links:**
- Flutter Forms: https://docs.flutter.dev/cookbook/forms/validation
- TextFormField: https://api.flutter.dev/flutter/material/TextFormField-class.html
- InternetAddress: https://api.flutter.dev/flutter/dart-io/InternetAddress-class.html

**Implementation Examples:**
- IPv4 Calculator Flutter: https://github.com/HeavyTobi/ipv4-calculator-flutter
- Network Tools Package: https://pub.dev/packages/network_tools
- Dart SDK Network Enhancement Request: https://github.com/dart-lang/sdk/issues/54237

**Best Practices:**
- Use dart:io InternetAddress.tryParse() for IP validation
- Implement bitwise operations for subnet calculations
- Provide IPv4 regex validation as fallback: `r"^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$"`

**Common Pitfalls:**
- CIDR prefix length validation (0-32 range)
- Subnet mask validation (must be valid contiguous mask)
- Integer overflow in IP address calculations
- UI not handling IPv6 addresses (explicitly IPv4 only)

## Implementation Plan

### Pseudocode/Algorithm
```dart
// Subnet Calculation Algorithm
class SubnetCalculator {
  static SubnetInfo calculateSubnet(String ipAddress, dynamic maskOrCidr) {
    // 1. Validate and parse IP address
    InternetAddress ip = InternetAddress.tryParse(ipAddress)
    
    // 2. Convert mask/CIDR to unified format
    int prefixLength = (maskOrCidr is String) 
      ? parseCIDR(maskOrCidr) 
      : subnetMaskToCIDR(maskOrCidr)
    
    // 3. Calculate network mask (bitwise)
    int mask = (0xFFFFFFFF << (32 - prefixLength)) & 0xFFFFFFFF
    
    // 4. Calculate network address
    int networkInt = ipToInt(ip) & mask
    
    // 5. Calculate broadcast address  
    int broadcastInt = networkInt | (0xFFFFFFFF >> prefixLength)
    
    // 6. Calculate usable range
    int firstUsable = networkInt + 1
    int lastUsable = broadcastInt - 1
    int totalHosts = (1 << (32 - prefixLength)) - 2
    
    // 7. Return structured result
    return SubnetInfo(...)
  }
  
  static bool isIpInSubnet(String testIp, String networkIp, dynamic mask) {
    // Similar calculation to check if testIp falls within network range
  }
}
```

### Tasks (in order)
1. **Create Domain Models** (lib/features/subnet_calculator/domain/models/)
   - SubnetInfo model with network details
   - SubnetValidationResult model for IP checking
   - SubnetCalculationHistory for calculation persistence

2. **Create Use Cases** (lib/features/subnet_calculator/domain/use_cases/)
   - CalculateSubnetUseCase for subnet calculations
   - ValidateIpInSubnetUseCase for IP validation
   - IP and CIDR validation utilities

3. **Create View Model** (lib/features/subnet_calculator/presentation/view_models/)
   - SubnetCalculatorViewModel with Provider integration
   - State management for calculation results and history
   - Error handling and validation

4. **Create UI Components** (lib/features/subnet_calculator/presentation/widgets/)
   - SubnetInputForm for IP/CIDR input
   - SubnetResultDisplay for showing calculation results
   - IpValidationForm for IP subnet checking
   - CalculationHistoryList for history display

5. **Create Main Page** (lib/features/subnet_calculator/presentation/pages/)
   - SubnetCalculatorScreen with tabbed interface
   - Integration of input forms and result displays

6. **Update App Integration**
   - Add route to app_routes.dart
   - Add tool to helper_tool.dart
   - Update app constants

7. **Create Tests** (test/features/subnet_calculator/)
   - Unit tests for domain models and use cases
   - Widget tests for UI components
   - Integration tests for full workflow

### File Structure
```
everyday_helper_app/
├── lib/features/subnet_calculator/
│   ├── domain/
│   │   ├── models/
│   │   │   ├── subnet_info.dart
│   │   │   ├── subnet_validation_result.dart
│   │   │   └── subnet_calculation_history.dart
│   │   └── use_cases/
│   │       ├── calculate_subnet_use_case.dart
│   │       ├── validate_ip_in_subnet_use_case.dart
│   │       └── subnet_validation_utils.dart
│   └── presentation/
│       ├── pages/
│       │   └── subnet_calculator_screen.dart
│       ├── view_models/
│       │   └── subnet_calculator_view_model.dart
│       └── widgets/
│           ├── subnet_input_form.dart
│           ├── subnet_result_display.dart
│           ├── ip_validation_form.dart
│           └── calculation_history_list.dart
└── test/features/subnet_calculator/
    ├── domain/
    │   ├── models/
    │   └── use_cases/
    └── presentation/
        ├── view_models/
        └── widgets/
```

## Validation Gates

### Syntax/Style Checks
```bash
# Navigate to Flutter project directory
cd everyday_helper_app

# Run Flutter analyzer
flutter analyze

# Format code
dart format .
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific subnet calculator tests
flutter test test/features/subnet_calculator/

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Manual Validation
- [ ] Can input IP address and CIDR notation (e.g., 192.168.1.0/24)
- [ ] Can input IP address and subnet mask (e.g., 192.168.1.0 with 255.255.255.0)
- [ ] Displays correct network address, broadcast address, and usable range
- [ ] Can validate single IP against subnet
- [ ] Can validate multiple IPs against subnet
- [ ] Shows clear error messages for invalid inputs
- [ ] Results are displayed in organized, readable format
- [ ] Thai language interface elements work correctly
- [ ] Calculation history persists and displays properly
- [ ] Integration with home screen and navigation works

## Error Handling

### Common Issues
- **Invalid IP Format**: Use InternetAddress.tryParse() validation + regex fallback
- **Invalid CIDR Range**: Validate prefix length is 0-32
- **Invalid Subnet Mask**: Ensure contiguous mask bits
- **Integer Overflow**: Use proper bit masking with 0xFFFFFFFF
- **Empty/Null Inputs**: Provide default values and clear error messages

### Troubleshooting
- **Debug Steps:**
  1. Check IP address parsing with InternetAddress.tryParse()
  2. Verify CIDR to integer conversion
  3. Test bitwise operations with known values
  4. Validate UI state updates with Provider DevTools

- **Fallback Approaches:**
  - If InternetAddress fails, use regex validation
  - Provide example inputs for user guidance
  - Clear forms and reset state on critical errors

## Quality Checklist

- [ ] All requirements from INIT.md implemented
- [ ] Code follows existing clean architecture patterns
- [ ] Uses Provider pattern consistently with other features
- [ ] UI matches existing app theme and design
- [ ] Form validation follows established patterns
- [ ] Error handling implemented comprehensively  
- [ ] Thai language support included
- [ ] Calculation history persists properly
- [ ] All validation gates pass
- [ ] Test coverage includes edge cases
- [ ] Documentation updated (if required)

## Confidence Score

9/10 - High confidence for one-pass implementation success

**Rationale:**
- Clear, well-defined requirements with specific technical details
- Extensive codebase analysis reveals established patterns to follow
- Research identified specific implementation approaches and common pitfalls
- No complex external dependencies required
- Subnet calculation algorithms are well-documented mathematical operations
- Existing form validation and state management patterns provide solid foundation
- Comprehensive validation gates ensure quality assurance

**Risk Mitigation:**
- Bitwise operations are straightforward but will include extensive unit tests
- UI integration follows existing patterns from mathematics feature
- Error handling patterns already established in codebase
- Flutter documentation provides authoritative guidance for form validation

## References

- **Official Documentation:**
  - Flutter Forms Validation: https://docs.flutter.dev/cookbook/forms/validation
  - TextFormField API: https://api.flutter.dev/flutter/material/TextFormField-class.html
  - InternetAddress Class: https://api.flutter.dev/flutter/dart-io/InternetAddress-class.html

- **Implementation Examples:**
  - IPv4 Calculator Flutter Project: https://github.com/HeavyTobi/ipv4-calculator-flutter
  - Network Tools Package: https://pub.dev/packages/network_tools

- **Technical Resources:**
  - Dart SDK Network Feature Request: https://github.com/dart-lang/sdk/issues/54237
  - Flutter Text Field Validation Guide: https://codewithandrea.com/articles/flutter-text-field-form-validation/

- **Subnet Calculation References:**
  - Interactive CIDR Calculator: https://cidr.xyz/
  - IP Subnet Calculator: https://www.calculator.net/ip-subnet-calculator.html

- **Codebase Reference Files:**
  - `everyday_helper_app/lib/features/mathematics/domain/models/calculation.dart`
  - `everyday_helper_app/lib/features/mathematics/presentation/view_models/basic_calculator_view_model.dart`
  - `everyday_helper_app/lib/features/home/models/helper_tool.dart`
  - `everyday_helper_app/lib/routes/app_routes.dart`