import '../models/subnet_info.dart';
import 'subnet_validation_utils.dart';

class CalculateSubnetUseCase {
  /// Calculate subnet information from IP address and CIDR notation
  ///
  /// Example: calculateFromCIDR("192.168.1.100", 24)
  /// Returns SubnetInfo with network details
  SubnetInfo calculateFromCIDR(String ipAddress, int prefixLength) {
    // Validate inputs
    if (!SubnetValidationUtils.isValidIPv4(ipAddress)) {
      throw ArgumentError('Invalid IP address: $ipAddress');
    }

    if (!SubnetValidationUtils.isValidCIDR(prefixLength)) {
      throw ArgumentError('Invalid CIDR prefix length: $prefixLength');
    }

    try {
      // Calculate network information
      final networkAddress = SubnetValidationUtils.calculateNetworkAddress(
        ipAddress,
        prefixLength,
      );

      final broadcastAddress = SubnetValidationUtils.calculateBroadcastAddress(
        ipAddress,
        prefixLength,
      );

      final firstUsableHost = SubnetValidationUtils.calculateFirstUsableHost(
        networkAddress,
      );

      final lastUsableHost = SubnetValidationUtils.calculateLastUsableHost(
        broadcastAddress,
      );

      final totalHosts = SubnetValidationUtils.calculateTotalHosts(
        prefixLength,
      );

      final usableHosts = SubnetValidationUtils.calculateUsableHosts(
        prefixLength,
      );

      final subnetMask = SubnetValidationUtils.cidrToSubnetMask(prefixLength);

      return SubnetInfo(
        networkAddress: networkAddress,
        broadcastAddress: broadcastAddress,
        firstUsableHost: firstUsableHost,
        lastUsableHost: lastUsableHost,
        totalHosts: totalHosts,
        usableHosts: usableHosts,
        subnetMask: subnetMask,
        prefixLength: prefixLength,
        inputIpAddress: ipAddress,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to calculate subnet: ${e.toString()}');
    }
  }

  /// Calculate subnet information from IP address and subnet mask
  ///
  /// Example: calculateFromSubnetMask("192.168.1.100", "255.255.255.0")
  /// Returns SubnetInfo with network details
  SubnetInfo calculateFromSubnetMask(String ipAddress, String subnetMask) {
    // Validate inputs
    if (!SubnetValidationUtils.isValidIPv4(ipAddress)) {
      throw ArgumentError('Invalid IP address: $ipAddress');
    }

    if (!SubnetValidationUtils.isValidSubnetMask(subnetMask)) {
      throw ArgumentError('Invalid subnet mask: $subnetMask');
    }

    try {
      // Convert subnet mask to CIDR
      final prefixLength = SubnetValidationUtils.subnetMaskToCIDR(subnetMask);

      // Use CIDR calculation method
      return calculateFromCIDR(ipAddress, prefixLength);
    } catch (e) {
      throw Exception('Failed to calculate subnet from mask: ${e.toString()}');
    }
  }

  /// Calculate subnet information from CIDR notation string
  ///
  /// Example: calculateFromCIDRString("192.168.1.100/24")
  /// Returns SubnetInfo with network details
  SubnetInfo calculateFromCIDRString(String cidrNotation) {
    if (cidrNotation.isEmpty) {
      throw ArgumentError('CIDR notation cannot be empty');
    }

    // Parse CIDR notation
    final parts = cidrNotation.split('/');
    if (parts.length != 2) {
      throw ArgumentError('Invalid CIDR notation format: $cidrNotation');
    }

    final ipAddress = parts[0].trim();
    final prefixLengthString = parts[1].trim();

    final prefixLength = SubnetValidationUtils.parseCIDR(prefixLengthString);
    if (prefixLength == null) {
      throw ArgumentError('Invalid prefix length: $prefixLengthString');
    }

    return calculateFromCIDR(ipAddress, prefixLength);
  }

  /// Parse and calculate subnet from mixed input format
  ///
  /// Supports:
  /// - "192.168.1.100/24" (CIDR notation)
  /// - IP with separate CIDR: calculateFromMixedInput("192.168.1.100", "24")
  /// - IP with separate subnet mask: calculateFromMixedInput("192.168.1.100", "255.255.255.0")
  SubnetInfo calculateFromMixedInput(String ipInput, [String? maskOrCidr]) {
    // If no second parameter, try to parse as CIDR notation
    if (maskOrCidr == null || maskOrCidr.isEmpty) {
      if (ipInput.contains('/')) {
        return calculateFromCIDRString(ipInput);
      } else {
        throw ArgumentError('Missing subnet mask or CIDR prefix length');
      }
    }

    // Determine if maskOrCidr is a CIDR or subnet mask
    if (SubnetValidationUtils.isValidCIDRString(maskOrCidr)) {
      final prefixLength = SubnetValidationUtils.parseCIDR(maskOrCidr);
      if (prefixLength != null) {
        return calculateFromCIDR(ipInput, prefixLength);
      }
    }

    // Try as subnet mask
    if (SubnetValidationUtils.isValidSubnetMask(maskOrCidr)) {
      return calculateFromSubnetMask(ipInput, maskOrCidr);
    }

    throw ArgumentError('Invalid subnet mask or CIDR: $maskOrCidr');
  }

  /// Validate input before calculation
  ///
  /// Returns null if valid, error message if invalid
  String? validateCalculationInput(String ipInput, [String? maskOrCidr]) {
    try {
      // Validate IP address part
      String ipAddress = ipInput;
      if (maskOrCidr == null && ipInput.contains('/')) {
        ipAddress = ipInput.split('/')[0];
      }

      final ipValidation = SubnetValidationUtils.validateIPCIDRInput(ipAddress);
      if (ipValidation != null) {
        return ipValidation;
      }

      // If CIDR notation in IP input
      if (maskOrCidr == null && ipInput.contains('/')) {
        final parts = ipInput.split('/');
        if (parts.length == 2) {
          final cidrPart = parts[1].trim();
          if (!SubnetValidationUtils.isValidCIDRString(cidrPart)) {
            return 'Prefix length ต้องอยู่ระหว่าง 0-32'; // 'Prefix length must be between 0-32' in Thai
          }
        }
        return null;
      }

      // Validate mask or CIDR parameter
      if (maskOrCidr != null && maskOrCidr.isNotEmpty) {
        if (SubnetValidationUtils.isValidCIDRString(maskOrCidr)) {
          return null; // Valid CIDR
        }

        final maskValidation = SubnetValidationUtils.validateSubnetMaskInput(
          maskOrCidr,
        );
        return maskValidation;
      }

      return 'กรุณาใส่ Subnet Mask หรือ CIDR'; // 'Please enter Subnet Mask or CIDR' in Thai
    } catch (e) {
      return 'ข้อมูลไม่ถูกต้อง: ${e.toString()}'; // 'Invalid data' in Thai
    }
  }

  /// Get subnet calculation summary for history
  ///
  /// Returns a brief summary of the calculation
  String getCalculationSummary(SubnetInfo subnetInfo) {
    if (subnetInfo.usableHosts == 0) {
      return 'ไม่มีโฮสต์ที่ใช้ได้'; // 'No usable hosts' in Thai
    } else if (subnetInfo.usableHosts == 1) {
      return '1 โฮสต์ที่ใช้ได้'; // '1 usable host' in Thai
    } else {
      return '${subnetInfo.usableHosts} โฮสต์ที่ใช้ได้'; // 'X usable hosts' in Thai
    }
  }

  /// Get detailed calculation information for display
  ///
  /// Returns a map with detailed calculation steps and results
  Map<String, dynamic> getCalculationDetails(SubnetInfo subnetInfo) {
    return {
      'input': {
        'ipAddress': subnetInfo.inputIpAddress,
        'prefixLength': subnetInfo.prefixLength,
        'subnetMask': subnetInfo.subnetMask,
        'notation': '${subnetInfo.inputIpAddress}/${subnetInfo.prefixLength}',
      },
      'network': {
        'networkAddress': subnetInfo.networkAddress,
        'broadcastAddress': subnetInfo.broadcastAddress,
        'networkRange': subnetInfo.networkRange,
        'subnetClass': subnetInfo.subnetClass,
      },
      'hosts': {
        'totalHosts': subnetInfo.totalHosts,
        'usableHosts': subnetInfo.usableHosts,
        'firstUsableHost': subnetInfo.firstUsableHost,
        'lastUsableHost': subnetInfo.lastUsableHost,
        'usableRange': subnetInfo.usableRange,
      },
      'metadata': {
        'timestamp': subnetInfo.timestamp,
        'formattedTimestamp': subnetInfo.formattedTimestamp,
        'displayTitle': subnetInfo.displayTitle,
        'isValid': subnetInfo.isValid,
        'hasUsableHosts': subnetInfo.hasUsableHosts,
      },
    };
  }
}
