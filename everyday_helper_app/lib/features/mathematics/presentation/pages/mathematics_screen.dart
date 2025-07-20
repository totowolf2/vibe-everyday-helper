import 'package:flutter/material.dart';
import '../../domain/models/math_category.dart';
import '../widgets/math_category_card.dart';
import '../../../../shared/constants/app_constants.dart';

class MathematicsScreen extends StatelessWidget {
  const MathematicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableCategories = MathematicsCategory.enabledCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mathematics'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mathematics Tools',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Text(
              'Choose from the available mathematics calculators and tools below.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppConstants.defaultMargin,
                mainAxisSpacing: AppConstants.defaultMargin,
              ),
              itemCount: availableCategories.length,
              itemBuilder: (context, index) {
                final category = availableCategories[index];
                return MathCategoryCard(
                  category: category,
                  onTap: () => _navigateToCalculator(context, category),
                );
              },
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppConstants.defaultMargin),
                Text(
                  'Mathematics Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            const Text(
              '• Precise decimal calculations without floating-point errors\n'
              '• Expression parsing with proper operator precedence\n'
              '• Comprehensive statistical analysis tools\n'
              '• Unit conversion between different measurement systems\n'
              '• Scientific functions with trigonometry and logarithms\n'
              '• Calculation history and result persistence',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCalculator(BuildContext context, MathematicsCategory category) {
    switch (category.toolType) {
      case MathematicsToolType.basicCalculator:
        Navigator.of(context).pushNamed(category.route);
        break;
      case MathematicsToolType.scientificCalculator:
        Navigator.of(context).pushNamed(category.route);
        break;
      case MathematicsToolType.statisticsCalculator:
        Navigator.of(context).pushNamed(category.route);
        break;
      case MathematicsToolType.unitConverter:
        Navigator.of(context).pushNamed(category.route);
        break;
      case MathematicsToolType.percentageCalculator:
        Navigator.of(context).pushNamed(category.route);
        break;
    }
  }

}