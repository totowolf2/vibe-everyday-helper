import '../models/subnet_validation_result.dart';
import 'subnet_validation_utils.dart';

class ValidateIpInSubnetUseCase {
  /// Validate if an IP address is within a specific subnet using CIDR
  ///
  /// Example: validateWithCIDR("192.168.1.50", "192.168.1.0", 24)
  /// Returns SubnetValidationResult with validation details
  SubnetValidationResult validateWithCIDR(
    String testIpAddress,
    String networkIpAddress,
    int prefixLength,
  ) {
    final timestamp = DateTime.now();

    // Validate test IP format
    if (!SubnetValidationUtils.isValidIPv4(testIpAddress)) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkIpAddress,
        subnetMask: '',
        prefixLength: prefixLength,
        status: ValidationStatus.invalidFormat,
        message:
            'IP Address ที่ต้องการตรวจสอบไม่ถูกต้อง', // 'Test IP address is invalid' in Thai
        timestamp: timestamp,
      );
    }

    // Validate network IP format
    if (!SubnetValidationUtils.isValidIPv4(networkIpAddress)) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkIpAddress,
        subnetMask: '',
        prefixLength: prefixLength,
        status: ValidationStatus.invalidFormat,
        message:
            'Network IP Address ไม่ถูกต้อง', // 'Network IP address is invalid' in Thai
        timestamp: timestamp,
      );
    }

    // Validate CIDR prefix length
    if (!SubnetValidationUtils.isValidCIDR(prefixLength)) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkIpAddress,
        subnetMask: '',
        prefixLength: prefixLength,
        status: ValidationStatus.invalid,
        message:
            'Prefix length ต้องอยู่ระหว่าง 0-32', // 'Prefix length must be between 0-32' in Thai
        timestamp: timestamp,
      );
    }

    try {
      // Calculate subnet mask for result
      final subnetMask = SubnetValidationUtils.cidrToSubnetMask(prefixLength);

      // Check if IP is in subnet
      final isInSubnet = SubnetValidationUtils.isIPInSubnet(
        testIpAddress,
        networkIpAddress,
        prefixLength,
      );

      if (isInSubnet) {
        return SubnetValidationResult(
          testIpAddress: testIpAddress,
          networkAddress: networkIpAddress,
          subnetMask: subnetMask,
          prefixLength: prefixLength,
          status: ValidationStatus.valid,
          message:
              'IP Address อยู่ในเครือข่าย $networkIpAddress/$prefixLength', // 'IP Address is in network' in Thai
          timestamp: timestamp,
        );
      } else {
        return SubnetValidationResult(
          testIpAddress: testIpAddress,
          networkAddress: networkIpAddress,
          subnetMask: subnetMask,
          prefixLength: prefixLength,
          status: ValidationStatus.outOfRange,
          message:
              'IP Address ไม่ได้อยู่ในเครือข่าย $networkIpAddress/$prefixLength', // 'IP Address is not in network' in Thai
          timestamp: timestamp,
        );
      }
    } catch (e) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkIpAddress,
        subnetMask: '',
        prefixLength: prefixLength,
        status: ValidationStatus.invalid,
        message:
            'เกิดข้อผิดพลาดในการตรวจสอบ: ${e.toString()}', // 'Error occurred during validation' in Thai
        timestamp: timestamp,
      );
    }
  }

  /// Validate if an IP address is within a specific subnet using subnet mask
  ///
  /// Example: validateWithSubnetMask("192.168.1.50", "192.168.1.0", "255.255.255.0")
  /// Returns SubnetValidationResult with validation details
  SubnetValidationResult validateWithSubnetMask(
    String testIpAddress,
    String networkIpAddress,
    String subnetMask,
  ) {
    final timestamp = DateTime.now();

    // Validate subnet mask
    if (!SubnetValidationUtils.isValidSubnetMask(subnetMask)) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkIpAddress,
        subnetMask: subnetMask,
        prefixLength: 0,
        status: ValidationStatus.invalid,
        message: 'Subnet Mask ไม่ถูกต้อง', // 'Subnet mask is invalid' in Thai
        timestamp: timestamp,
      );
    }

    try {
      // Convert subnet mask to CIDR
      final prefixLength = SubnetValidationUtils.subnetMaskToCIDR(subnetMask);

      // Use CIDR validation method
      final result = validateWithCIDR(
        testIpAddress,
        networkIpAddress,
        prefixLength,
      );

      // Return with original subnet mask
      return result.copyWith(subnetMask: subnetMask);
    } catch (e) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkIpAddress,
        subnetMask: subnetMask,
        prefixLength: 0,
        status: ValidationStatus.invalid,
        message:
            'เกิดข้อผิดพลาดในการแปลง Subnet Mask: ${e.toString()}', // 'Error converting subnet mask' in Thai
        timestamp: timestamp,
      );
    }
  }

  /// Validate multiple IP addresses against a single subnet
  ///
  /// Example: validateMultipleIPs(["192.168.1.50", "192.168.1.100"], "192.168.1.0", 24)
  /// Returns List of SubnetValidationResult
  List<SubnetValidationResult> validateMultipleIPs(
    List<String> testIpAddresses,
    String networkIpAddress,
    int prefixLength,
  ) {
    final results = <SubnetValidationResult>[];

    for (final testIp in testIpAddresses) {
      final result = validateWithCIDR(
        testIp.trim(),
        networkIpAddress,
        prefixLength,
      );
      results.add(result);
    }

    return results;
  }

  /// Validate IP addresses from text input (comma or newline separated)
  ///
  /// Example: validateFromTextInput("192.168.1.50, 192.168.1.100\n192.168.1.200", "192.168.1.0", 24)
  /// Returns List of SubnetValidationResult
  List<SubnetValidationResult> validateFromTextInput(
    String textInput,
    String networkIpAddress,
    int prefixLength,
  ) {
    if (textInput.trim().isEmpty) {
      return [];
    }

    // Split by comma and newline, clean up whitespace
    final ipAddresses = textInput
        .split(RegExp(r'[,\n\r]+'))
        .map((ip) => ip.trim())
        .where((ip) => ip.isNotEmpty)
        .toList();

    return validateMultipleIPs(ipAddresses, networkIpAddress, prefixLength);
  }

  /// Parse and validate from mixed input format
  ///
  /// Supports network specification as:
  /// - CIDR notation: "192.168.1.0/24"
  /// - Separate IP and CIDR: parseNetworkInput("192.168.1.0", "24")
  /// - Separate IP and subnet mask: parseNetworkInput("192.168.1.0", "255.255.255.0")
  SubnetValidationResult validateFromMixedInput(
    String testIpAddress,
    String networkInput, [
    String? maskOrCidr,
  ]) {
    final timestamp = DateTime.now();

    try {
      // Parse network specification
      String networkIp;
      int prefixLength;

      if (maskOrCidr == null && networkInput.contains('/')) {
        // CIDR notation
        final parts = networkInput.split('/');
        if (parts.length != 2) {
          return SubnetValidationResult(
            testIpAddress: testIpAddress,
            networkAddress: networkInput,
            subnetMask: '',
            prefixLength: 0,
            status: ValidationStatus.invalid,
            message: 'รูปแบบ CIDR ไม่ถูกต้อง', // 'Invalid CIDR format' in Thai
            timestamp: timestamp,
          );
        }

        networkIp = parts[0].trim();
        final cidrString = parts[1].trim();
        final cidr = SubnetValidationUtils.parseCIDR(cidrString);

        if (cidr == null) {
          return SubnetValidationResult(
            testIpAddress: testIpAddress,
            networkAddress: networkInput,
            subnetMask: '',
            prefixLength: 0,
            status: ValidationStatus.invalid,
            message:
                'Prefix length ไม่ถูกต้อง', // 'Invalid prefix length' in Thai
            timestamp: timestamp,
          );
        }

        prefixLength = cidr;
      } else if (maskOrCidr != null) {
        networkIp = networkInput;

        // Determine if maskOrCidr is CIDR or subnet mask
        if (SubnetValidationUtils.isValidCIDRString(maskOrCidr)) {
          final cidr = SubnetValidationUtils.parseCIDR(maskOrCidr);
          if (cidr == null) {
            return SubnetValidationResult(
              testIpAddress: testIpAddress,
              networkAddress: networkInput,
              subnetMask: '',
              prefixLength: 0,
              status: ValidationStatus.invalid,
              message:
                  'Prefix length ไม่ถูกต้อง', // 'Invalid prefix length' in Thai
              timestamp: timestamp,
            );
          }
          prefixLength = cidr;
        } else {
          // Try as subnet mask
          return validateWithSubnetMask(testIpAddress, networkIp, maskOrCidr);
        }
      } else {
        return SubnetValidationResult(
          testIpAddress: testIpAddress,
          networkAddress: networkInput,
          subnetMask: '',
          prefixLength: 0,
          status: ValidationStatus.invalid,
          message:
              'ขาดข้อมูล Subnet Mask หรือ CIDR', // 'Missing subnet mask or CIDR' in Thai
          timestamp: timestamp,
        );
      }

      return validateWithCIDR(testIpAddress, networkIp, prefixLength);
    } catch (e) {
      return SubnetValidationResult(
        testIpAddress: testIpAddress,
        networkAddress: networkInput,
        subnetMask: '',
        prefixLength: 0,
        status: ValidationStatus.invalid,
        message: 'เกิดข้อผิดพลาด: ${e.toString()}', // 'Error occurred' in Thai
        timestamp: timestamp,
      );
    }
  }

  /// Validate input parameters before validation
  ///
  /// Returns null if valid, error message if invalid
  String? validateInputParameters(
    String testIpAddress,
    String networkInput, [
    String? maskOrCidr,
  ]) {
    // Validate test IP address
    if (testIpAddress.trim().isEmpty) {
      return 'กรุณาใส่ IP Address ที่ต้องการตรวจสอบ'; // 'Please enter IP address to test' in Thai
    }

    if (!SubnetValidationUtils.isValidIPv4(testIpAddress.trim())) {
      return 'IP Address ที่ต้องการตรวจสอบไม่ถูกต้อง'; // 'Test IP address is invalid' in Thai
    }

    // Validate network input
    if (networkInput.trim().isEmpty) {
      return 'กรุณาใส่ Network Address'; // 'Please enter network address' in Thai
    }

    // If CIDR notation in network input
    if (maskOrCidr == null && networkInput.contains('/')) {
      final parts = networkInput.split('/');
      if (parts.length == 2) {
        final networkIp = parts[0].trim();
        final cidrPart = parts[1].trim();

        if (!SubnetValidationUtils.isValidIPv4(networkIp)) {
          return 'Network IP Address ไม่ถูกต้อง'; // 'Network IP address is invalid' in Thai
        }

        if (!SubnetValidationUtils.isValidCIDRString(cidrPart)) {
          return 'Prefix length ต้องอยู่ระหว่าง 0-32'; // 'Prefix length must be between 0-32' in Thai
        }
      } else {
        return 'รูปแบบ CIDR ไม่ถูกต้อง'; // 'Invalid CIDR format' in Thai
      }
    } else {
      // Validate separate network IP
      if (!SubnetValidationUtils.isValidIPv4(networkInput.trim())) {
        return 'Network IP Address ไม่ถูกต้อง'; // 'Network IP address is invalid' in Thai
      }

      // Validate mask or CIDR parameter
      if (maskOrCidr == null || maskOrCidr.trim().isEmpty) {
        return 'กรุณาใส่ Subnet Mask หรือ CIDR'; // 'Please enter subnet mask or CIDR' in Thai
      }

      final trimmedMaskOrCidr = maskOrCidr.trim();
      if (!SubnetValidationUtils.isValidCIDRString(trimmedMaskOrCidr) &&
          !SubnetValidationUtils.isValidSubnetMask(trimmedMaskOrCidr)) {
        return 'Subnet Mask หรือ CIDR ไม่ถูกต้อง'; // 'Subnet mask or CIDR is invalid' in Thai
      }
    }

    return null; // Valid input
  }

  /// Get validation summary for multiple results
  ///
  /// Returns a summary of validation results
  Map<String, dynamic> getValidationSummary(
    List<SubnetValidationResult> results,
  ) {
    if (results.isEmpty) {
      return {
        'total': 0,
        'valid': 0,
        'invalid': 0,
        'outOfRange': 0,
        'invalidFormat': 0,
        'validPercentage': 0.0,
      };
    }

    final validCount = results
        .where((r) => r.status == ValidationStatus.valid)
        .length;
    final invalidCount = results
        .where((r) => r.status == ValidationStatus.invalid)
        .length;
    final outOfRangeCount = results
        .where((r) => r.status == ValidationStatus.outOfRange)
        .length;
    final invalidFormatCount = results
        .where((r) => r.status == ValidationStatus.invalidFormat)
        .length;

    return {
      'total': results.length,
      'valid': validCount,
      'invalid': invalidCount,
      'outOfRange': outOfRangeCount,
      'invalidFormat': invalidFormatCount,
      'validPercentage': (validCount / results.length) * 100,
    };
  }

  /// Get detailed validation information for display
  ///
  /// Returns formatted validation details
  Map<String, dynamic> getValidationDetails(SubnetValidationResult result) {
    return {
      'test': {
        'ipAddress': result.testIpAddress,
        'status': result.status.name,
        'statusDisplay': result.statusDisplay,
        'isValid': result.isValid,
        'resultIcon': result.resultIcon,
      },
      'network': {
        'networkAddress': result.networkAddress,
        'subnetMask': result.subnetMask,
        'prefixLength': result.prefixLength,
        'displayTitle': result.displayTitle,
      },
      'result': {
        'message': result.message,
        'timestamp': result.timestamp,
        'formattedTimestamp': result.formattedTimestamp,
      },
    };
  }
}
