import 'package:flutter/material.dart';

enum MathematicsToolType {
  basicCalculator,
  scientificCalculator,
  statisticsCalculator,
  unitConverter,
  percentageCalculator,
}

class MathematicsCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final MathematicsToolType toolType;
  final String route;
  final Color? color;
  final bool isEnabled;

  const MathematicsCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.toolType,
    required this.route,
    this.color,
    this.isEnabled = true,
  });

  String get displayTitle {
    return title.isEmpty ? 'Unknown Tool' : title;
  }

  String get displayDescription {
    return description.isEmpty ? 'Mathematics calculation tool' : description;
  }

  bool get isAvailable {
    return isEnabled;
  }

  MathematicsCategory copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    MathematicsToolType? toolType,
    String? route,
    Color? color,
    bool? isEnabled,
  }) {
    return MathematicsCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      toolType: toolType ?? this.toolType,
      route: route ?? this.route,
      color: color ?? this.color,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  static List<MathematicsCategory> get allCategories {
    return [
      const MathematicsCategory(
        id: 'basic_calculator',
        title: 'Basic Calculator',
        description:
            'Perform basic arithmetic operations with decimal precision',
        icon: Icons.calculate,
        toolType: MathematicsToolType.basicCalculator,
        route: '/mathematics/basic-calculator',
        color: Colors.blue,
      ),
      const MathematicsCategory(
        id: 'statistics_calculator',
        title: 'Statistics Calculator',
        description:
            'Calculate mean, median, mode, standard deviation, and variance',
        icon: Icons.bar_chart,
        toolType: MathematicsToolType.statisticsCalculator,
        route: '/mathematics/statistics-calculator',
        color: Colors.orange,
      ),
      const MathematicsCategory(
        id: 'percentage_calculator',
        title: 'Percentage Calculator',
        description: 'Calculate tips, discounts, tax, and percentage changes',
        icon: Icons.percent,
        toolType: MathematicsToolType.percentageCalculator,
        route: '/mathematics/percentage-calculator',
        color: Colors.red,
      ),
      const MathematicsCategory(
        id: 'unit_converter',
        title: 'Unit Converter',
        description:
            'Convert between different units of measurement with precision',
        icon: Icons.straighten,
        toolType: MathematicsToolType.unitConverter,
        route: '/mathematics/unit-converter',
        color: Colors.purple,
      ),
    ];
  }

  static List<MathematicsCategory> get enabledCategories {
    return allCategories.where((category) => category.isEnabled).toList();
  }

  static MathematicsCategory? getCategoryByType(MathematicsToolType type) {
    try {
      return allCategories.firstWhere((category) => category.toolType == type);
    } catch (e) {
      return null;
    }
  }

  static MathematicsCategory? getCategoryById(String id) {
    try {
      return allCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static MathematicsCategory? getCategoryByRoute(String route) {
    try {
      return allCategories.firstWhere((category) => category.route == route);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'toolType': toolType.name,
      'route': route,
      'color': color?.toARGB32(),
      'isEnabled': isEnabled,
    };
  }

  factory MathematicsCategory.fromMap(Map<String, dynamic> map) {
    return MathematicsCategory(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: Icons
          .calculate, // Default icon, would need icon mapping for full persistence
      toolType: MathematicsToolType.values.firstWhere(
        (type) => type.name == map['toolType'],
        orElse: () => MathematicsToolType.basicCalculator,
      ),
      route: map['route'] ?? '',
      color: map['color'] != null ? Color(map['color']) : null,
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  @override
  String toString() {
    return 'MathematicsCategory(id: $id, title: $title, toolType: $toolType, route: $route)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathematicsCategory &&
        other.id == id &&
        other.title == title &&
        other.toolType == toolType &&
        other.route == route;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ toolType.hashCode ^ route.hashCode;
  }
}
