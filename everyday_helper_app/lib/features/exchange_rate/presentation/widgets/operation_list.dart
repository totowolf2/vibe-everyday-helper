import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_models/exchange_rate_view_model.dart';
import '../../domain/models/math_operation.dart';
import 'operation_input.dart';

class OperationList extends StatelessWidget {
  const OperationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExchangeRateViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate),
                    const SizedBox(width: 8),
                    Text(
                      'การดำเนินการทางคณิตศาสตร์',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (viewModel.hasOperations)
                      TextButton.icon(
                        onPressed: viewModel.clearOperations,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('ล้างทั้งหมด'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Operation inputs
                if (viewModel.hasOperations) ...[
                  ...viewModel.operations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final operation = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: OperationInput(
                        initialOperation: operation,
                        index: index,
                        onChanged: (newOperation) {
                          viewModel.updateOperation(index, newOperation);
                        },
                        onRemove: () {
                          viewModel.removeOperation(index);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // Add operation buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddOperationDialog(context, viewModel),
                        icon: const Icon(Icons.add),
                        label: const Text('เพิ่มการดำเนินการ'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                if (!viewModel.hasOperations)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'เพิ่มการดำเนินการทางคณิตศาสตร์ (คูณ หรือ หาร) เพื่อคำนวณค่าเพิ่มเติม\nการดำเนินการจะเรียงตามลำดับที่เพิ่ม',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddOperationDialog(
    BuildContext context,
    ExchangeRateViewModel viewModel,
  ) {
    final controller = TextEditingController();
    OperationType selectedType = OperationType.multiply;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('เพิ่มการดำเนินการ'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Operation type selector
                  DropdownButtonFormField<OperationType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'ประเภทการดำเนินการ',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: OperationType.multiply,
                        child: Row(
                          children: [
                            Icon(Icons.close, size: 16),
                            const SizedBox(width: 8),
                            const Text('คูณ (×)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: OperationType.divide,
                        child: Row(
                          children: [
                            Icon(Icons.horizontal_rule, size: 16),
                            const SizedBox(width: 8),
                            const Text('หาร (÷)'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (OperationType? newType) {
                      if (newType != null) {
                        setState(() {
                          selectedType = newType;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Value input
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'ค่า',
                      hintText: 'กรอกตัวเลข เช่น 2.5',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ยกเลิก'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text);
                    if (value != null && value > 0) {
                      final operation = MathOperation(
                        type: selectedType,
                        value: value,
                      );
                      viewModel.addOperation(operation);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณากรอกตัวเลขที่มากกว่า 0'),
                        ),
                      );
                    }
                  },
                  child: const Text('เพิ่ม'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}