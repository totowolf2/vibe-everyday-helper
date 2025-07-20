import 'package:flutter/material.dart';
import '../../models/helper_tool.dart';
import '../widgets/menu_item_card.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableTools = HelperTool.availableTools;
    final groupedTools = _groupToolsByCategory(availableTools);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to ${AppConstants.appName}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Text(
              'Choose from the available helper tools below to get started.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding * 2),
            ...groupedTools.entries.map(
              (entry) => _buildCategorySection(context, entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<HelperTool>> _groupToolsByCategory(List<HelperTool> tools) {
    final Map<String, List<HelperTool>> grouped = {};

    for (final tool in tools) {
      if (!grouped.containsKey(tool.category)) {
        grouped[tool.category] = [];
      }
      grouped[tool.category]!.add(tool);
    }

    return grouped;
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<HelperTool> tools,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: AppConstants.defaultMargin,
            mainAxisSpacing: AppConstants.defaultMargin,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return MenuItemCard(
              tool: tool,
              onTap: () => _navigateToTool(context, tool),
            );
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding * 2),
      ],
    );
  }

  void _navigateToTool(BuildContext context, HelperTool tool) {
    switch (tool.route) {
      case AppConstants.priceComparisonRoute:
        AppRoutes.navigateToPriceComparison(context);
        break;
      case AppConstants.mathematicsRoute:
        Navigator.of(context).pushNamed(AppConstants.mathematicsRoute);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tool.title} is not available yet'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }
}
