import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class TaxInputForm extends StatelessWidget {
  final String label;
  final String value;
  final String hintText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? helperText;
  final Widget? suffixIcon;

  const TaxInputForm({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText = '',
    this.errorText,
    this.keyboardType,
    this.helperText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: value == '0' ? '' : value,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: const OutlineInputBorder(),
            errorText: errorText,
            helperText: helperText,
            helperMaxLines: 2,
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboardType ?? TextInputType.number,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class TaxInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final Widget? child;

  const TaxInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            if (child != null) ...[const SizedBox(height: 16), child!],
          ],
        ),
      ),
    );
  }
}

class TaxResultSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const TaxResultSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColor ?? Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Theme.of(context).primaryColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        textColor?.withValues(alpha: 0.7) ?? Colors.grey[600],
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

class TaxBracketProgressIndicator extends StatelessWidget {
  final String bracketRange;
  final String taxRate;
  final String taxableAmount;
  final String taxAmount;
  final double progress;

  const TaxBracketProgressIndicator({
    super.key,
    required this.bracketRange,
    required this.taxRate,
    required this.taxableAmount,
    required this.taxAmount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bracketRange,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'Rate: $taxRate',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxable: $taxableAmount THB',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Tax: $taxAmount THB',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EducationalTooltip extends StatelessWidget {
  final String title;
  final String content;
  final Widget child;

  const EducationalTooltip({
    super.key,
    required this.title,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showInfoDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(width: 4),
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
