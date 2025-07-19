import 'package:flutter/material.dart';

class HelperTool {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String category;
  final bool isAvailable;

  const HelperTool({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.category,
    this.isAvailable = true,
  });

  static List<HelperTool> get availableTools {
    return [
      const HelperTool(
        title: 'Price Comparison',
        description:
            'Compare price per unit for different products to find the best value',
        icon: Icons.compare_arrows,
        route: '/price-comparison',
        category: 'Calculations',
      ),
      // Future tools will be added here
    ];
  }
}
