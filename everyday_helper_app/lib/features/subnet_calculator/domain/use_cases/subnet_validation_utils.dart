import 'dart:io';

class SubnetValidationUtils {
  // IPv4 validation regex as fallback
  static final RegExp _ipv4Regex = RegExp(
    r'^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])$',
  );

  /// Validates IPv4 address format
  static bool isValidIPv4(String ipAddress) {
    if (ipAddress.isEmpty) return false;

    // First try with InternetAddress.tryParse for authoritative validation
    try {
      final address = InternetAddress.tryParse(ipAddress);
      if (address != null && address.type == InternetAddressType.IPv4) {
        return true;
      }
    } catch (e) {
      // Continue to regex fallback
    }

    // Fallback to regex validation
    return _ipv4Regex.hasMatch(ipAddress);
  }

  /// Validates CIDR prefix length (0-32)
  static bool isValidCIDR(int prefixLength) {
    return prefixLength >= 0 && prefixLength <= 32;
  }

  /// Validates CIDR notation string (e.g., "24" or "/24")
  static bool isValidCIDRString(String cidr) {
    if (cidr.isEmpty) return false;

    // Remove leading slash if present
    String cleanCidr = cidr.startsWith('/') ? cidr.substring(1) : cidr;

    final prefixLength = int.tryParse(cleanCidr);
    if (prefixLength == null) return false;

    return isValidCIDR(prefixLength);
  }

  /// Converts CIDR string to integer
  static int? parseCIDR(String cidr) {
    if (!isValidCIDRString(cidr)) return null;

    String cleanCidr = cidr.startsWith('/') ? cidr.substring(1) : cidr;
    return int.tryParse(cleanCidr);
  }

  /// Validates subnet mask format (e.g., 255.255.255.0)
  static bool isValidSubnetMask(String subnetMask) {
    if (!isValidIPv4(subnetMask)) return false;

    // Convert to binary and check if it's a contiguous mask
    try {
      final maskInt = ipToInt(subnetMask);
      return _isContiguousMask(maskInt);
    } catch (e) {
      return false;
    }
  }

  /// Checks if the mask has contiguous bits (valid subnet mask)
  static bool _isContiguousMask(int mask) {
    // A valid subnet mask should have all 1s followed by all 0s
    // Example: 11111111.11111111.11111111.00000000 = 255.255.255.0

    // Find the rightmost 1 bit
    int rightmost1 = mask & -mask;

    // Add rightmost1 to mask, should give us a value where all bits
    // from rightmost1 and to the left are 1, and all others are 0
    int result = mask + rightmost1;

    // Check if result is a power of 2 (only one bit set) or 0
    return (result & (result - 1)) == 0;
  }

  /// Converts subnet mask to CIDR prefix length
  static int subnetMaskToCIDR(String subnetMask) {
    if (!isValidSubnetMask(subnetMask)) {
      throw ArgumentError('Invalid subnet mask: $subnetMask');
    }

    final maskInt = ipToInt(subnetMask);
    int cidr = 0;

    // Count the number of 1 bits
    for (int i = 31; i >= 0; i--) {
      if ((maskInt >> i) & 1 == 1) {
        cidr++;
      } else {
        break;
      }
    }

    return cidr;
  }

  /// Converts CIDR prefix length to subnet mask
  static String cidrToSubnetMask(int prefixLength) {
    if (!isValidCIDR(prefixLength)) {
      throw ArgumentError('Invalid CIDR prefix length: $prefixLength');
    }

    final mask = (0xFFFFFFFF << (32 - prefixLength)) & 0xFFFFFFFF;
    return intToIP(mask);
  }

  /// Converts IP address string to 32-bit integer
  static int ipToInt(String ipAddress) {
    if (!isValidIPv4(ipAddress)) {
      throw ArgumentError('Invalid IP address: $ipAddress');
    }

    final parts = ipAddress.split('.');
    if (parts.length != 4) {
      throw ArgumentError('Invalid IP address format: $ipAddress');
    }

    int result = 0;
    for (int i = 0; i < 4; i++) {
      final octet = int.parse(parts[i]);
      if (octet < 0 || octet > 255) {
        throw ArgumentError('Invalid octet value: $octet');
      }
      result |= (octet << (8 * (3 - i)));
    }

    return result;
  }

  /// Converts 32-bit integer to IP address string
  static String intToIP(int ipInt) {
    if (ipInt < 0 || ipInt > 0xFFFFFFFF) {
      throw ArgumentError('Invalid IP integer: $ipInt');
    }

    final octet1 = (ipInt >> 24) & 0xFF;
    final octet2 = (ipInt >> 16) & 0xFF;
    final octet3 = (ipInt >> 8) & 0xFF;
    final octet4 = ipInt & 0xFF;

    return '$octet1.$octet2.$octet3.$octet4';
  }

  /// Calculates network address from IP and prefix length
  static String calculateNetworkAddress(String ipAddress, int prefixLength) {
    if (!isValidIPv4(ipAddress) || !isValidCIDR(prefixLength)) {
      throw ArgumentError(
        'Invalid IP address or CIDR: $ipAddress/$prefixLength',
      );
    }

    final ipInt = ipToInt(ipAddress);
    final mask = (0xFFFFFFFF << (32 - prefixLength)) & 0xFFFFFFFF;
    final networkInt = ipInt & mask;

    return intToIP(networkInt);
  }

  /// Calculates broadcast address from IP and prefix length
  static String calculateBroadcastAddress(String ipAddress, int prefixLength) {
    if (!isValidIPv4(ipAddress) || !isValidCIDR(prefixLength)) {
      throw ArgumentError(
        'Invalid IP address or CIDR: $ipAddress/$prefixLength',
      );
    }

    final networkAddress = calculateNetworkAddress(ipAddress, prefixLength);
    final networkInt = ipToInt(networkAddress);
    final broadcastInt = networkInt | (0xFFFFFFFF >> prefixLength);

    return intToIP(broadcastInt);
  }

  /// Calculates total number of hosts in subnet
  static int calculateTotalHosts(int prefixLength) {
    if (!isValidCIDR(prefixLength)) {
      throw ArgumentError('Invalid CIDR prefix length: $prefixLength');
    }

    return 1 << (32 - prefixLength);
  }

  /// Calculates number of usable hosts in subnet (total - 2)
  static int calculateUsableHosts(int prefixLength) {
    if (!isValidCIDR(prefixLength)) {
      throw ArgumentError('Invalid CIDR prefix length: $prefixLength');
    }

    final totalHosts = calculateTotalHosts(prefixLength);
    return totalHosts > 2 ? totalHosts - 2 : 0;
  }

  /// Checks if an IP address is within a specific subnet
  static bool isIPInSubnet(String testIP, String networkIP, int prefixLength) {
    if (!isValidIPv4(testIP) ||
        !isValidIPv4(networkIP) ||
        !isValidCIDR(prefixLength)) {
      return false;
    }

    try {
      final testNetworkAddress = calculateNetworkAddress(testIP, prefixLength);
      final targetNetworkAddress = calculateNetworkAddress(
        networkIP,
        prefixLength,
      );

      return testNetworkAddress == targetNetworkAddress;
    } catch (e) {
      return false;
    }
  }

  /// Calculates first usable host address
  static String calculateFirstUsableHost(String networkAddress) {
    if (!isValidIPv4(networkAddress)) {
      throw ArgumentError('Invalid network address: $networkAddress');
    }

    final networkInt = ipToInt(networkAddress);
    return intToIP(networkInt + 1);
  }

  /// Calculates last usable host address
  static String calculateLastUsableHost(String broadcastAddress) {
    if (!isValidIPv4(broadcastAddress)) {
      throw ArgumentError('Invalid broadcast address: $broadcastAddress');
    }

    final broadcastInt = ipToInt(broadcastAddress);
    return intToIP(broadcastInt - 1);
  }

  /// Comprehensive validation of IP/CIDR input
  static String? validateIPCIDRInput(String input) {
    if (input.isEmpty) {
      return 'กรุณาใส่ IP Address'; // 'Please enter IP Address' in Thai
    }

    // Check if input contains CIDR notation
    if (input.contains('/')) {
      final parts = input.split('/');
      if (parts.length != 2) {
        return 'รูปแบบ CIDR ไม่ถูกต้อง'; // 'Invalid CIDR format' in Thai
      }

      final ipPart = parts[0].trim();
      final cidrPart = parts[1].trim();

      if (!isValidIPv4(ipPart)) {
        return 'IP Address ไม่ถูกต้อง'; // 'Invalid IP Address' in Thai
      }

      if (!isValidCIDRString(cidrPart)) {
        return 'Prefix length ต้องอยู่ระหว่าง 0-32'; // 'Prefix length must be between 0-32' in Thai
      }
    } else {
      if (!isValidIPv4(input)) {
        return 'IP Address ไม่ถูกต้อง'; // 'Invalid IP Address' in Thai
      }
    }

    return null; // Valid input
  }

  /// Validate subnet mask input
  static String? validateSubnetMaskInput(String input) {
    if (input.isEmpty) {
      return 'กรุณาใส่ Subnet Mask'; // 'Please enter Subnet Mask' in Thai
    }

    if (!isValidIPv4(input)) {
      return 'Subnet Mask ไม่ถูกต้อง'; // 'Invalid Subnet Mask' in Thai
    }

    if (!isValidSubnetMask(input)) {
      return 'Subnet Mask ต้องเป็น contiguous bits'; // 'Subnet Mask must be contiguous bits' in Thai
    }

    return null; // Valid input
  }
}
