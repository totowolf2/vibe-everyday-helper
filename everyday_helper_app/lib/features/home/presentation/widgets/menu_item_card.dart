import 'package:flutter/material.dart';
import '../../models/helper_tool.dart';
import '../../../../shared/constants/app_constants.dart';

class MenuItemCard extends StatelessWidget {
  final HelperTool tool;
  final VoidCallback onTap;

  const MenuItemCard({super.key, required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: tool.isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tool.icon,
                size: 48,
                color: tool.isAvailable
                    ? theme.primaryColor
                    : theme.disabledColor,
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              Text(
                tool.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tool.isAvailable
                      ? theme.colorScheme.onSurface
                      : theme.disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultMargin / 2),
              Text(
                tool.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tool.isAvailable
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      : theme.disabledColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (!tool.isAvailable) ...[
                const SizedBox(height: AppConstants.defaultMargin / 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.disabledColor),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
