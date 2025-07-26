import 'package:flutter/material.dart';
import '../../domain/models/math_category.dart';
import '../../../../shared/constants/app_constants.dart';

class MathCategoryCard extends StatelessWidget {
  final MathematicsCategory category;
  final VoidCallback onTap;

  const MathCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = category.isEnabled;
    final cardColor = category.color ?? theme.primaryColor;

    return Card(
      elevation: isEnabled ? 2 : 1,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            gradient: isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor.withValues(alpha: 0.1),
                      cardColor.withValues(alpha: 0.05),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? cardColor.withValues(alpha: 0.2)
                        : theme.disabledColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    category.icon,
                    size: 32,
                    color: isEnabled ? cardColor : theme.disabledColor,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultMargin),
                Text(
                  category.displayTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEnabled
                        ? theme.colorScheme.onSurface
                        : theme.disabledColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.defaultMargin / 2),
                Text(
                  category.displayDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isEnabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                        : theme.disabledColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isEnabled) ...[
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
      ),
    );
  }
}
