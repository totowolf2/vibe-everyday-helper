import 'package:flutter/material.dart';
import '../../domain/models/product.dart';
import '../../../../shared/constants/app_constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isBestValue;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProductCard({
    super.key,
    required this.product,
    this.isBestValue = false,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = product.isValid;

    return Card(
      elevation: isBestValue ? 8 : 4,
      color: isBestValue ? theme.primaryColor.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isValid ? null : theme.disabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isBestValue) ...[
                  const SizedBox(width: AppConstants.defaultMargin),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Best Value',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isValid) ...[
                  const SizedBox(width: AppConstants.defaultMargin),
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                ],
              ],
            ),
            const SizedBox(height: AppConstants.defaultMargin),

            // Product details
            if (isValid) ...[
              _buildDetailRow(
                context,
                Icons.attach_money,
                'Price',
                '\$${product.price.toStringAsFixed(2)}',
              ),
              const SizedBox(height: AppConstants.defaultMargin / 2),
              _buildDetailRow(
                context,
                Icons.scale,
                'Quantity',
                '${product.quantity} ${product.unit}',
              ),
              const SizedBox(height: AppConstants.defaultMargin),

              // Pack-specific details
              if (product.isPack) ...[
                _buildDetailRow(
                  context,
                  Icons.inventory,
                  'Pack size',
                  '${product.packSize} pieces',
                ),
                const SizedBox(height: AppConstants.defaultMargin / 2),
                _buildDetailRow(
                  context,
                  Icons.straighten,
                  'Per piece',
                  '${product.individualQuantity} ${product.unit}',
                ),
                const SizedBox(height: AppConstants.defaultMargin / 2),
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultMargin),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: AppConstants.defaultMargin),
                      Expanded(
                        child: Text(
                          'Pack total: ${product.packSize} × ${product.individualQuantity.toStringAsFixed(product.individualQuantity.truncateToDouble() == product.individualQuantity ? 0 : 1)} = ${product.totalQuantity.toStringAsFixed(product.totalQuantity.truncateToDouble() == product.totalQuantity ? 0 : 1)} ${product.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.defaultMargin),

                // Price per piece
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultMargin),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calculate,
                        color: theme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: AppConstants.defaultMargin),
                      Text(
                        'Price per piece:',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        '\$${product.pricePerPiece.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.defaultMargin),
              ],

              // Price per unit (highlighted)
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultMargin),
                decoration: BoxDecoration(
                  color: isBestValue
                      ? Colors.green.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                  border: Border.all(
                    color: isBestValue
                        ? Colors.green
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: isBestValue ? Colors.green : theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.defaultMargin),
                    Text(
                      'Price per ${product.unit}:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      '\$${(product.isPack ? product.pricePerUnitFromPack : product.pricePerUnit).toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isBestValue ? Colors.green : theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Invalid product message
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultMargin),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: AppConstants.defaultMargin),
                    Expanded(
                      child: Text(
                        'Please complete all fields to calculate price per unit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            if (showActions) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultMargin),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: AppConstants.defaultMargin),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
