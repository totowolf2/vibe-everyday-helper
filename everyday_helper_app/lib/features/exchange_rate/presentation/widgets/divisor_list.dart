import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/exchange_rate_view_model.dart';
import 'divisor_input.dart';

class DivisorList extends StatelessWidget {
  const DivisorList({super.key});

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
                      'ตัวหาร',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (viewModel.hasDivisors)
                      TextButton.icon(
                        onPressed: viewModel.clearDivisors,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('ล้างทั้งหมด'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Divisor inputs
                if (viewModel.hasDivisors) ...[
                  ...viewModel.divisors.asMap().entries.map((entry) {
                    final index = entry.key;
                    final divisor = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DivisorInput(
                        initialValue: divisor,
                        index: index,
                        onChanged: (value) {
                          viewModel.updateDivisor(index, value);
                        },
                        onRemove: () {
                          viewModel.removeDivisor(index);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                // Add divisor button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showAddDivisorDialog(context, viewModel),
                    icon: const Icon(Icons.add),
                    label: const Text('เพิ่มตัวหาร'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                if (!viewModel.hasDivisors)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'เพิ่มตัวหารเพื่อคำนวณค่าหาร',
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

  void _showAddDivisorDialog(
    BuildContext context,
    ExchangeRateViewModel viewModel,
  ) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เพิ่มตัวหาร'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'ค่าตัวหาร',
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
                  viewModel.addDivisor(value);
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