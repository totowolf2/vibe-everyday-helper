import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/help_content.dart';
import '../../../../shared/constants/app_constants.dart';
import '../view_models/price_comparison_view_model.dart';
import '../widgets/tutorial_overlay.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<HelpSection> _helpSections = HelpContent.getAllSections();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _helpSections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Instructions'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _helpSections.map((section) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIconData(section.icon)),
                  const SizedBox(width: 8),
                  Text(section.title),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _helpSections.map((section) {
          return _buildHelpSection(context, section);
        }).toList(),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildHelpSection(BuildContext context, HelpSection section) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                _getIconData(section.icon),
                size: 32,
                color: theme.primaryColor,
              ),
              const SizedBox(width: AppConstants.defaultMargin),
              Expanded(
                child: Text(
                  section.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          // Section content
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.content,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),

                  // Special actions for specific sections
                  if (section.type == HelpType.examples) ...[
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildExampleActions(context),
                  ] else if (section.type == HelpType.tutorial) ...[
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildTutorialActions(context),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Additional content for examples section
          if (section.type == HelpType.examples) _buildMilkExampleCard(context),
        ],
      ),
    );
  }

  Widget _buildExampleActions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: AppConstants.defaultMargin),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _loadMilkExample(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Load Milk Example'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultMargin),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _navigateToComparison(context),
                icon: const Icon(Icons.calculate),
                label: const Text('Try It Now'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTutorialActions(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: AppConstants.defaultMargin),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startInteractiveTutorial(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Interactive Tutorial'),
          ),
        ),
      ],
    );
  }

  Widget _buildMilkExampleCard(BuildContext context) {
    final theme = Theme.of(context);
    final products = MilkComparisonExample.getExampleProducts();

    return Card(
      color: theme.primaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: theme.primaryColor),
                const SizedBox(width: AppConstants.defaultMargin),
                Text(
                  'Example Products',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            ...products.map<Widget>(
              (product) => Container(
                margin: const EdgeInsets.only(
                  bottom: AppConstants.defaultMargin,
                ),
                padding: const EdgeInsets.all(AppConstants.defaultMargin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.price} baht for ${product.quantity} ${product.unit}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${product.formattedPricePerUnit} baht/${product.unit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToComparison(context),
      icon: const Icon(Icons.calculate),
      label: const Text('Start Comparing'),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'info':
        return Icons.info_outline;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'help':
        return Icons.help_outline;
      default:
        return Icons.help_outline;
    }
  }

  void _loadMilkExample(BuildContext context) {
    final products = MilkComparisonExample.getExampleProducts();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Example'),
        content: const Text(
          'This will add the milk comparison example to your current comparison. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to price comparison

              // Add products to the view model
              final viewModel = Provider.of<PriceComparisonViewModel>(
                context,
                listen: false,
              );
              for (final product in products) {
                viewModel.addProduct(product);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Milk example loaded successfully!'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Load Example'),
          ),
        ],
      ),
    );
  }

  void _startInteractiveTutorial(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TutorialOverlay()));
  }

  void _navigateToComparison(BuildContext context) {
    Navigator.of(context).pop(); // Go back to price comparison screen
  }
}
