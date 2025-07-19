import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PackSizeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final String? errorText;

  const PackSizeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many items in the pack?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Decrease button
            IconButton(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: Icon(
                Icons.remove_circle_outline,
                color: value > 1 ? theme.primaryColor : theme.disabledColor,
              ),
            ),

            // Current value display and text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: errorText != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  key: ValueKey(value),
                  initialValue: value.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) {
                    final newValue = int.tryParse(text);
                    if (newValue != null && newValue > 0 && newValue <= 99) {
                      onChanged(newValue);
                    }
                  },
                ),
              ),
            ),

            // Increase button
            IconButton(
              onPressed: value < 99 ? () => onChanged(value + 1) : null,
              icon: Icon(
                Icons.add_circle_outline,
                color: value < 99 ? theme.primaryColor : theme.disabledColor,
              ),
            ),
          ],
        ),

        // Quick select buttons
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1, 2, 3, 4, 6, 8, 12, 24].map((size) {
            return ActionChip(
              label: Text('$size'),
              onPressed: value != size ? () => onChanged(size) : null,
              backgroundColor: value == size
                  ? theme.primaryColor.withValues(alpha: 0.2)
                  : null,
              side: value == size
                  ? BorderSide(color: theme.primaryColor)
                  : null,
            );
          }).toList(),
        ),

        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
