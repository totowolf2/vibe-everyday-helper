import 'package:flutter/material.dart';

class DivisorInput extends StatefulWidget {
  final double initialValue;
  final int index;
  final Function(double) onChanged;
  final VoidCallback onRemove;

  const DivisorInput({
    super.key,
    required this.initialValue,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<DivisorInput> createState() => _DivisorInputState();
}

class _DivisorInputState extends State<DivisorInput> {
  late TextEditingController _controller;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final value = double.tryParse(text);

    setState(() {
      _isValid = value != null && value > 0;
    });

    if (_isValid && value != null) {
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('divisor_${widget.index}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('ลบตัวหาร'),
                  content: const Text('คุณต้องการลบตัวหารนี้หรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('ยกเลิก'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('ลบ'),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (direction) {
        widget.onRemove();
      },
      child: Row(
        children: [
          const Icon(Icons.horizontal_rule, size: 16),
          const SizedBox(width: 8),
          const Text('ตัวหาร:'),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'กรอกค่าตัวหาร',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                errorText: _isValid ? null : 'ตัวหารต้องมากกว่า 0',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 20,
            color: Theme.of(context).colorScheme.error,
            tooltip: 'ลบตัวหาร',
          ),
        ],
      ),
    );
  }
}