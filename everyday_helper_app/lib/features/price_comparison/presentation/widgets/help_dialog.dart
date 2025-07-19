import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/help_content.dart';
import '../../../../shared/constants/app_constants.dart';
import '../view_models/price_comparison_view_model.dart';
import '../pages/help_screen.dart';
import 'tutorial_overlay.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.cardBorderRadius),
                  topRight: Radius.circular(AppConstants.cardBorderRadius),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: theme.primaryColor, size: 28),
                  const SizedBox(width: AppConstants.defaultMargin),
                  Expanded(
                    child: Text(
                      'Quick Help',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: theme.primaryColor,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick overview
                    _buildQuickOverview(context),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Quick actions
                    _buildQuickActions(context),
                    const SizedBox(height: AppConstants.defaultPadding),

                    // Example summary
                    _buildExampleSummary(context),
                  ],
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.cardBorderRadius),
                  bottomRight: Radius.circular(AppConstants.cardBorderRadius),
                ),
              ),
              child: _buildFooterButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOverview(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Use',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultMargin),

        ...HelpContent.overview
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(4) // Show only first 4 lines for quick overview
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line.trim(),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultMargin),

        _buildActionTile(
          context,
          Icons.play_arrow,
          'Start Tutorial',
          'Interactive guide with milk example',
          () => _startTutorial(context),
        ),

        _buildActionTile(
          context,
          Icons.add_shopping_cart,
          'Load Example',
          'Add milk comparison example',
          () => _loadExample(context),
        ),

        _buildActionTile(
          context,
          Icons.book,
          'Full Help Guide',
          'Complete instructions and FAQ',
          () => _openFullHelp(context),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 20),
            ),
            const SizedBox(width: AppConstants.defaultMargin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Example: Milk Comparison',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.defaultMargin),
          Text(
            'Compare "6 boxes × 200ml for 57 baht" vs "3 boxes × 300ml for 48 baht"',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
          ),
          const SizedBox(height: AppConstants.defaultMargin),
          Text(
            'Result: First option is better value at 0.048 baht/ml vs 0.053 baht/ml',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ),
        const SizedBox(width: AppConstants.defaultMargin),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _openFullHelp(context),
            child: const Text('Full Guide'),
          ),
        ),
      ],
    );
  }

  void _startTutorial(BuildContext context) {
    Navigator.of(context).pop(); // Close dialog
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TutorialOverlay()));
  }

  void _loadExample(BuildContext context) {
    final products = MilkComparisonExample.getExampleProducts();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Milk Example'),
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
              Navigator.of(context).pop(); // Close confirmation
              Navigator.of(context).pop(); // Close help dialog

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

  void _openFullHelp(BuildContext context) {
    Navigator.of(context).pop(); // Close dialog
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HelpScreen()));
  }

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const HelpDialog());
  }
}
