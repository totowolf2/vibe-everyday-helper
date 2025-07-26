enum ValidationStatus { valid, invalid, outOfRange, invalidFormat }

class SubnetValidationResult {
  final String testIpAddress;
  final String networkAddress;
  final String subnetMask;
  final int prefixLength;
  final ValidationStatus status;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const SubnetValidationResult({
    required this.testIpAddress,
    required this.networkAddress,
    required this.subnetMask,
    required this.prefixLength,
    required this.status,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });

  bool get isValid => status == ValidationStatus.valid;

  bool get isInSubnet => status == ValidationStatus.valid;

  String get statusDisplay {
    switch (status) {
      case ValidationStatus.valid:
        return 'ในเครือข่าย'; // 'In Network' in Thai
      case ValidationStatus.invalid:
        return 'ไม่ถูกต้อง'; // 'Invalid' in Thai
      case ValidationStatus.outOfRange:
        return 'นอกเครือข่าย'; // 'Out of Network' in Thai
      case ValidationStatus.invalidFormat:
        return 'รูปแบบไม่ถูกต้อง'; // 'Invalid Format' in Thai
    }
  }

  String get displayTitle {
    return '$testIpAddress → $networkAddress/$prefixLength';
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get resultIcon {
    switch (status) {
      case ValidationStatus.valid:
        return '✓';
      case ValidationStatus.invalid:
      case ValidationStatus.invalidFormat:
        return '✗';
      case ValidationStatus.outOfRange:
        return '⚠';
    }
  }

  SubnetValidationResult copyWith({
    String? testIpAddress,
    String? networkAddress,
    String? subnetMask,
    int? prefixLength,
    ValidationStatus? status,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return SubnetValidationResult(
      testIpAddress: testIpAddress ?? this.testIpAddress,
      networkAddress: networkAddress ?? this.networkAddress,
      subnetMask: subnetMask ?? this.subnetMask,
      prefixLength: prefixLength ?? this.prefixLength,
      status: status ?? this.status,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testIpAddress': testIpAddress,
      'networkAddress': networkAddress,
      'subnetMask': subnetMask,
      'prefixLength': prefixLength,
      'status': status.name,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory SubnetValidationResult.fromMap(Map<String, dynamic> map) {
    return SubnetValidationResult(
      testIpAddress: map['testIpAddress'] ?? '',
      networkAddress: map['networkAddress'] ?? '',
      subnetMask: map['subnetMask'] ?? '',
      prefixLength: map['prefixLength'] ?? 0,
      status: ValidationStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ValidationStatus.invalid,
      ),
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'SubnetValidationResult(testIpAddress: $testIpAddress, networkAddress: $networkAddress, status: $status, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubnetValidationResult &&
        other.testIpAddress == testIpAddress &&
        other.networkAddress == networkAddress &&
        other.prefixLength == prefixLength &&
        other.status == status;
  }

  @override
  int get hashCode {
    return testIpAddress.hashCode ^
        networkAddress.hashCode ^
        prefixLength.hashCode ^
        status.hashCode;
  }
}
