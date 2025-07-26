import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../view_models/subnet_calculator_view_model.dart';
import '../widgets/calculation_history_list.dart';

class CalculationHistoryPage extends StatelessWidget {
  final SubnetCalculatorViewModel viewModel;
  
  const CalculationHistoryPage({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ประวัติการคำนวณ'), // 'Calculation History' in Thai
          centerTitle: true,
        ),
        body: const Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: CalculationHistoryList(),
        ),
        floatingActionButton: Consumer<SubnetCalculatorViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.hasHistory) {
              return FloatingActionButton.extended(
                onPressed: () => _showClearHistoryDialog(context, viewModel),
                icon: const Icon(Icons.delete_sweep),
                label: const Text('ล้างประวัติ'), // 'Clear History' in Thai
                backgroundColor: Colors.red[600],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  void _showClearHistoryDialog(
    BuildContext context,
    SubnetCalculatorViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างประวัติทั้งหมด'), // 'Clear All History' in Thai
        content: const Text(
          'คุณต้องการล้างประวัติการคำนวณทั้งหมดหรือไม่?\n\nการดำเนินการนี้ไม่สามารถยกเลิกได้', // 'Do you want to clear all calculation history? This action cannot be undone' in Thai
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'), // 'Cancel' in Thai
          ),
          TextButton(
            onPressed: () {
              viewModel.clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ล้างประวัติทั้งหมดแล้ว'), // 'All history cleared' in Thai
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ล้างทั้งหมด'), // 'Clear All' in Thai
          ),
        ],
      ),
    );
  }
}