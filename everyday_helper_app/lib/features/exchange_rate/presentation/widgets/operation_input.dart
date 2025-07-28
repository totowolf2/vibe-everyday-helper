import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/math_operation.dart';

class OperationInput extends StatefulWidget {
  final MathOperation initialOperation;
  final int index;
  final Function(MathOperation) onChanged;
  final VoidCallback onRemove;

  const OperationInput({
    super.key,
    required this.initialOperation,
    required this.index,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<OperationInput> createState() => _OperationInputState();
}

class _OperationInputState extends State<OperationInput> {
  late TextEditingController _controller;
  late OperationType _selectedType;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialOperation.value.toString(),
    );
    _selectedType = widget.initialOperation.type;
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
      final operation = MathOperation(type: _selectedType, value: value);
      widget.onChanged(operation);
    }
  }

  void _onTypeChanged(OperationType? type) {
    if (type != null) {
      setState(() {
        _selectedType = type;
      });

      final value = double.tryParse(_controller.text);
      if (value != null && value > 0) {
        final operation = MathOperation(type: type, value: value);
        widget.onChanged(operation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('operation_${widget.index}'),
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
                  title: const Text('ลบการดำเนินการ'),
                  content: const Text('คุณต้องการลบการดำเนินการนี้หรือไม่?'),
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Operation type selector
              Container(
                height: 40, // Set fixed height to match TextField
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<OperationType>(
                  value: _selectedType,
                  onChanged: _onTypeChanged,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: OperationType.multiply,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 16),
                            const SizedBox(width: 4),
                            const Text('คูณ'),
                          ],
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: OperationType.divide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.horizontal_rule, size: 16),
                            const SizedBox(width: 4),
                            const Text('หาร'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Value input
              Expanded(
                child: SizedBox(
                  height: 40, // Set fixed height to match dropdown
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'กรอกค่า',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      errorText: _isValid ? null : 'ค่าต้องมากกว่า 0',
                      isDense: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Remove button
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 20,
                color: Theme.of(context).colorScheme.error,
                tooltip: 'ลบการดำเนินการ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
