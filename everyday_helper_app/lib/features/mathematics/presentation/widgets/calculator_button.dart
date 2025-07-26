import 'package:flutter/material.dart';
import '../../domain/models/calculator_operation.dart';
import '../../../../shared/constants/app_constants.dart';

enum CalculatorButtonType { number, operator, function, control, special }

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CalculatorButtonType type;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CalculatorButtonType.number,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  factory CalculatorButton.fromOperation(
    CalculatorOperation operation,
    VoidCallback onPressed, {
    bool isEnabled = true,
  }) {
    CalculatorButtonType buttonType;
    if (operation.isControl) {
      buttonType = CalculatorButtonType.control;
    } else if (operation.isConstant) {
      buttonType = CalculatorButtonType.special;
    } else if (operation.isOperator) {
      buttonType = CalculatorButtonType.operator;
    } else {
      buttonType = CalculatorButtonType.function;
    }

    return CalculatorButton(
      text: operation.displayText,
      onPressed: onPressed,
      type: buttonType,
      isEnabled: isEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColors = _getButtonColors(theme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? buttonColors.backgroundColor,
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
            border: Border.all(color: buttonColors.borderColor, width: 1),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor ?? buttonColors.textColor,
                fontWeight: FontWeight.w600,
                fontSize: fontSize ?? _getFontSize(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _getButtonColors(ThemeData theme) {
    if (!isEnabled) {
      return _ButtonColors(
        backgroundColor: theme.disabledColor.withValues(alpha: 0.1),
        textColor: theme.disabledColor,
        borderColor: theme.disabledColor.withValues(alpha: 0.3),
      );
    }

    switch (type) {
      case CalculatorButtonType.number:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.surface,
          textColor: theme.colorScheme.onSurface,
          borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
        );

      case CalculatorButtonType.operator:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.primaryContainer,
          textColor: theme.colorScheme.onPrimaryContainer,
          borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
        );

      case CalculatorButtonType.function:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.secondaryContainer,
          textColor: theme.colorScheme.onSecondaryContainer,
          borderColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
        );

      case CalculatorButtonType.control:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.errorContainer,
          textColor: theme.colorScheme.onErrorContainer,
          borderColor: theme.colorScheme.error.withValues(alpha: 0.3),
        );

      case CalculatorButtonType.special:
        return _ButtonColors(
          backgroundColor: theme.colorScheme.tertiaryContainer,
          textColor: theme.colorScheme.onTertiaryContainer,
          borderColor: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        );
    }
  }

  double _getFontSize() {
    switch (type) {
      case CalculatorButtonType.number:
      case CalculatorButtonType.operator:
        return 18.0;
      case CalculatorButtonType.function:
      case CalculatorButtonType.special:
        return 14.0;
      case CalculatorButtonType.control:
        return 16.0;
    }
  }
}

class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

class CalculatorButtonGrid extends StatelessWidget {
  final List<List<CalculatorButton>> buttonRows;
  final double spacing;

  const CalculatorButtonGrid({
    super.key,
    required this.buttonRows,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: buttonRows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            children: row.map((button) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: SizedBox(height: 56, child: button),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
