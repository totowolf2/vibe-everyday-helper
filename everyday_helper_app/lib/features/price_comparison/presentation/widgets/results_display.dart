import 'package:flutter/material.dart';
import '../../domain/models/comparison_result.dart';
import '../../domain/models/product.dart';
import 'product_card.dart';
import '../../../../shared/constants/app_constants.dart';

class ResultsDisplay extends StatelessWidget {
  final ComparisonResult? comparisonResult;
  final Function(Product)? onEditProduct;
  final Function(Product)? onDeleteProduct;

  const ResultsDisplay({
    super.key,
    this.comparisonResult,
    this.onEditProduct,
    this.onDeleteProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (comparisonResult == null || !comparisonResult!.hasValidProducts) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCard(context),
        const SizedBox(height: AppConstants.defaultPadding),
        _buildProductsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Column(
          children: [
            Icon(
              Icons.compare_arrows,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'No Comparison Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Text(
              'Add at least 2 valid products to see comparison results',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final result = comparisonResult!;

    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green, size: 24),
                const SizedBox(width: AppConstants.defaultMargin),
                Text(
                  'Comparison Results',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),

            Text(
              result.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),

            if (result.bestValueProduct != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildBestValueHighlight(context, result.bestValueProduct!),
            ],

            if (result.validProductCount > 1 && result.totalSavings > 0) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildSavingsInfo(context, result),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBestValueHighlight(BuildContext context, Product bestProduct) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.green, size: 20),
          const SizedBox(width: AppConstants.defaultMargin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Value',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  bestProduct.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${bestProduct.formattedPricePerUnit}/${bestProduct.unit}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsInfo(BuildContext context, ComparisonResult result) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultMargin),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.savings, color: Colors.blue[600], size: 18),
          const SizedBox(width: AppConstants.defaultMargin),
          Expanded(
            child: Text(
              'Potential savings: \$${result.totalSavings.toStringAsFixed(2)} per unit (${result.savingsPercentage.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context) {
    final theme = Theme.of(context);
    final sortedProducts = comparisonResult!.sortedByBestValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products (ranked by value)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedProducts.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppConstants.defaultMargin),
          itemBuilder: (context, index) {
            final product = sortedProducts[index];
            final isBestValue = index == 0 && sortedProducts.length > 1;

            return ProductCard(
              product: product,
              isBestValue: isBestValue,
              onEdit: onEditProduct != null
                  ? () => onEditProduct!(product)
                  : null,
              onDelete: onDeleteProduct != null
                  ? () => onDeleteProduct!(product)
                  : null,
              showActions: onEditProduct != null || onDeleteProduct != null,
            );
          },
        ),
      ],
    );
  }
}
