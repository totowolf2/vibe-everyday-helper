import 'subnet_info.dart';
import 'subnet_validation_result.dart';

enum SubnetCalculationType { subnetCalculation, ipValidation }

class SubnetCalculationEntry {
  final String id;
  final SubnetCalculationType type;
  final String title;
  final String summary;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const SubnetCalculationEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.timestamp,
    required this.data,
  });

  String get typeDisplay {
    switch (type) {
      case SubnetCalculationType.subnetCalculation:
        return 'คำนวณ Subnet'; // 'Subnet Calculation' in Thai
      case SubnetCalculationType.ipValidation:
        return 'ตรวจสอบ IP'; // 'IP Validation' in Thai
    }
  }

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get dateDisplay {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'วันนี้'; // 'Today' in Thai
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน'; // 'Yesterday' in Thai
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว'; // 'X days ago' in Thai
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  bool get isValid {
    return title.isNotEmpty && summary.isNotEmpty && data.isNotEmpty;
  }

  SubnetCalculationEntry copyWith({
    String? id,
    SubnetCalculationType? type,
    String? title,
    String? summary,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return SubnetCalculationEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'summary': summary,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'data': data,
    };
  }

  factory SubnetCalculationEntry.fromMap(Map<String, dynamic> map) {
    return SubnetCalculationEntry(
      id: map['id'] ?? '',
      type: SubnetCalculationType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => SubnetCalculationType.subnetCalculation,
      ),
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }

  factory SubnetCalculationEntry.fromSubnetInfo(SubnetInfo subnetInfo) {
    return SubnetCalculationEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SubnetCalculationType.subnetCalculation,
      title: subnetInfo.displayTitle,
      summary:
          '${subnetInfo.usableHosts} โฮสต์ที่ใช้ได้', // 'X usable hosts' in Thai
      timestamp: subnetInfo.timestamp,
      data: subnetInfo.toMap(),
    );
  }

  factory SubnetCalculationEntry.fromValidationResult(
    SubnetValidationResult result,
  ) {
    return SubnetCalculationEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SubnetCalculationType.ipValidation,
      title: result.displayTitle,
      summary: result.statusDisplay,
      timestamp: result.timestamp,
      data: result.toMap(),
    );
  }

  @override
  String toString() {
    return 'SubnetCalculationEntry(id: $id, type: $type, title: $title, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubnetCalculationEntry &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ title.hashCode ^ timestamp.hashCode;
  }
}

class SubnetCalculationHistory {
  final List<SubnetCalculationEntry> _entries = [];
  static const int _maxHistorySize = 100;

  SubnetCalculationHistory();

  List<SubnetCalculationEntry> get entries => List.unmodifiable(_entries);
  int get length => _entries.length;
  bool get isEmpty => _entries.isEmpty;
  bool get isNotEmpty => _entries.isNotEmpty;

  void addEntry(SubnetCalculationEntry entry) {
    _entries.insert(0, entry);

    if (_entries.length > _maxHistorySize) {
      _entries.removeLast();
    }
  }

  void addSubnetCalculation(SubnetInfo subnetInfo) {
    final entry = SubnetCalculationEntry.fromSubnetInfo(subnetInfo);
    addEntry(entry);
  }

  void addValidationResult(SubnetValidationResult result) {
    final entry = SubnetCalculationEntry.fromValidationResult(result);
    addEntry(entry);
  }

  void removeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
  }

  void clearHistory() {
    _entries.clear();
  }

  List<SubnetCalculationEntry> getByType(SubnetCalculationType type) {
    return _entries.where((entry) => entry.type == type).toList();
  }

  List<SubnetCalculationEntry> getRecent({int limit = 10}) {
    return _entries.take(limit).toList();
  }

  List<SubnetCalculationEntry> getToday() {
    final today = DateTime.now();
    return _entries.where((entry) {
      return entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day;
    }).toList();
  }

  SubnetCalculationEntry? getById(String id) {
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {'entries': _entries.map((entry) => entry.toMap()).toList()};
  }

  factory SubnetCalculationHistory.fromMap(Map<String, dynamic> map) {
    final history = SubnetCalculationHistory();
    final entriesList = map['entries'] as List<dynamic>? ?? [];

    for (final entryMap in entriesList) {
      if (entryMap is Map<String, dynamic>) {
        history.addEntry(SubnetCalculationEntry.fromMap(entryMap));
      }
    }

    return history;
  }
}
