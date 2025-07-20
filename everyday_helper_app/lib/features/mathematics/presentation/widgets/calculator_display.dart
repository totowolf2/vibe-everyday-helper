import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String? errorMessage;
  final bool showHistory;
  final List<String> history;
  final VoidCallback? onClearHistory;

  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.errorMessage,
    this.showHistory = false,
    this.history = const [],
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: hasError
              ? theme.colorScheme.error.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          if (showHistory && history.isNotEmpty) _buildHistorySection(context),
          _buildMainDisplay(context),
          if (hasError) _buildErrorDisplay(context),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.defaultMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (onClearHistory != null)
                  InkWell(
                    onTap: onClearHistory,
                    child: Icon(
                      Icons.clear_all,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final historyItem = history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    historyItem,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.end,
                  ),
                );
              },
            ),
          ),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildMainDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression display
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 40),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultMargin),
          // Result display
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                result.isEmpty ? '0' : result,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.cardBorderRadius),
          bottomRight: Radius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: AppConstants.defaultMargin),
          Expanded(
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompactCalculatorDisplay extends StatelessWidget {
  final String value;
  final String? label;
  final bool isResult;
  final TextAlign textAlign;

  const CompactCalculatorDisplay({
    super.key,
    required this.value,
    this.label,
    this.isResult = false,
    this.textAlign = TextAlign.end,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.end
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: textAlign,
            ),
            const SizedBox(height: 4),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: textAlign == TextAlign.end,
            child: Text(
              value.isEmpty ? '0' : value,
              style: isResult
                  ? theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    )
                  : theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontFamily: 'monospace',
                    ),
              textAlign: textAlign,
            ),
          ),
        ],
      ),
    );
  }
}