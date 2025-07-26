class SubnetInfo {
  final String networkAddress;
  final String broadcastAddress;
  final String firstUsableHost;
  final String lastUsableHost;
  final int totalHosts;
  final int usableHosts;
  final String subnetMask;
  final int prefixLength;
  final String inputIpAddress;
  final DateTime timestamp;

  const SubnetInfo({
    required this.networkAddress,
    required this.broadcastAddress,
    required this.firstUsableHost,
    required this.lastUsableHost,
    required this.totalHosts,
    required this.usableHosts,
    required this.subnetMask,
    required this.prefixLength,
    required this.inputIpAddress,
    required this.timestamp,
  });

  String get displayTitle {
    return '$inputIpAddress/$prefixLength';
  }

  String get networkRange {
    return '$networkAddress - $broadcastAddress';
  }

  String get usableRange {
    return '$firstUsableHost - $lastUsableHost';
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  bool get isValid {
    return networkAddress.isNotEmpty &&
        broadcastAddress.isNotEmpty &&
        firstUsableHost.isNotEmpty &&
        lastUsableHost.isNotEmpty &&
        inputIpAddress.isNotEmpty &&
        prefixLength >= 0 &&
        prefixLength <= 32 &&
        totalHosts > 0;
  }

  bool get hasUsableHosts {
    return usableHosts > 0;
  }

  String get subnetClass {
    final firstOctet = int.tryParse(networkAddress.split('.').first) ?? 0;
    if (firstOctet >= 1 && firstOctet <= 126) {
      return 'Class A';
    } else if (firstOctet >= 128 && firstOctet <= 191) {
      return 'Class B';
    } else if (firstOctet >= 192 && firstOctet <= 223) {
      return 'Class C';
    } else if (firstOctet >= 224 && firstOctet <= 239) {
      return 'Class D (Multicast)';
    } else if (firstOctet >= 240 && firstOctet <= 255) {
      return 'Class E (Reserved)';
    }
    return 'Unknown';
  }

  SubnetInfo copyWith({
    String? networkAddress,
    String? broadcastAddress,
    String? firstUsableHost,
    String? lastUsableHost,
    int? totalHosts,
    int? usableHosts,
    String? subnetMask,
    int? prefixLength,
    String? inputIpAddress,
    DateTime? timestamp,
  }) {
    return SubnetInfo(
      networkAddress: networkAddress ?? this.networkAddress,
      broadcastAddress: broadcastAddress ?? this.broadcastAddress,
      firstUsableHost: firstUsableHost ?? this.firstUsableHost,
      lastUsableHost: lastUsableHost ?? this.lastUsableHost,
      totalHosts: totalHosts ?? this.totalHosts,
      usableHosts: usableHosts ?? this.usableHosts,
      subnetMask: subnetMask ?? this.subnetMask,
      prefixLength: prefixLength ?? this.prefixLength,
      inputIpAddress: inputIpAddress ?? this.inputIpAddress,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'networkAddress': networkAddress,
      'broadcastAddress': broadcastAddress,
      'firstUsableHost': firstUsableHost,
      'lastUsableHost': lastUsableHost,
      'totalHosts': totalHosts,
      'usableHosts': usableHosts,
      'subnetMask': subnetMask,
      'prefixLength': prefixLength,
      'inputIpAddress': inputIpAddress,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SubnetInfo.fromMap(Map<String, dynamic> map) {
    return SubnetInfo(
      networkAddress: map['networkAddress'] ?? '',
      broadcastAddress: map['broadcastAddress'] ?? '',
      firstUsableHost: map['firstUsableHost'] ?? '',
      lastUsableHost: map['lastUsableHost'] ?? '',
      totalHosts: map['totalHosts'] ?? 0,
      usableHosts: map['usableHosts'] ?? 0,
      subnetMask: map['subnetMask'] ?? '',
      prefixLength: map['prefixLength'] ?? 0,
      inputIpAddress: map['inputIpAddress'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'SubnetInfo(networkAddress: $networkAddress, broadcastAddress: $broadcastAddress, prefixLength: $prefixLength, usableHosts: $usableHosts)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubnetInfo &&
        other.networkAddress == networkAddress &&
        other.broadcastAddress == broadcastAddress &&
        other.prefixLength == prefixLength &&
        other.inputIpAddress == inputIpAddress;
  }

  @override
  int get hashCode {
    return networkAddress.hashCode ^
        broadcastAddress.hashCode ^
        prefixLength.hashCode ^
        inputIpAddress.hashCode;
  }
}
