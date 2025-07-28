import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/exchange_rate_view_model.dart';
import 'multiplier_input.dart';

class MultiplierList extends StatelessWidget {
  const MultiplierList({super.key});

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
                      'ตัวคูณ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (viewModel.hasMultipliers)
                      TextButton.icon(
                        onPressed: viewModel.clearMultipliers,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('ล้างทั้งหมด'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Multiplier inputs
                if (viewModel.hasMultipliers) ...[
                  ...viewModel.multipliers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final multiplier = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: MultiplierInput(
                        initialValue: multiplier,
                        index: index,
                        onChanged: (value) {
                          viewModel.updateMultiplier(index, value);
                        },
                        onRemove: () {
                          viewModel.removeMultiplier(index);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // Add multiplier button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showAddMultiplierDialog(context, viewModel),
                    icon: const Icon(Icons.add),
                    label: const Text('เพิ่มตัวคูณ'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                if (!viewModel.hasMultipliers)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'เพิ่มตัวคูณเพื่อคำนวณค่าเพิ่มเติม',
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

  void _showAddMultiplierDialog(
    BuildContext context,
    ExchangeRateViewModel viewModel,
  ) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เพิ่มตัวคูณ'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'ค่าตัวคูณ',
              hintText: 'กรอกตัวเลข เช่น 2.5',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
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
                  viewModel.addMultiplier(value);
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
  }
}
