import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';

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
        route: AppConstants.priceComparisonRoute,
        category: 'Calculations',
      ),
      const HelperTool(
        title: 'Mathematics',
        description:
            'Access calculators, statistics, unit conversion, and mathematical tools',
        icon: Icons.calculate,
        route: AppConstants.mathematicsRoute,
        category: 'Calculations',
      ),
      const HelperTool(
        title: 'Thai Tax Calculator',
        description:
            'Calculate personal income tax in Thailand with allowances and deductions',
        icon: Icons.account_balance,
        route: AppConstants.taxCalculatorRoute,
        category: 'Calculations',
      ),
      // Future tools will be added here
    ];
  }
}
