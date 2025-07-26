import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/models/subnet_calculation_history.dart';
import '../view_models/subnet_calculator_view_model.dart';

class CalculationHistoryList extends StatelessWidget {
  const CalculationHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubnetCalculatorViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.hasHistory) {
          return _buildEmptyState(context);
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with summary
                _buildHeader(context, viewModel),
                const SizedBox(height: 16),

                // History list
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.historyEntries.length,
                    itemBuilder: (context, index) {
                      final entry = viewModel.historyEntries[index];
                      return _buildHistoryItem(context, entry, viewModel);
                    },
                  ),
                ),

                // Clear history button
                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showClearHistoryDialog(context, viewModel),
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text(
                      'ล้างประวัติทั้งหมด',
                    ), // 'Clear All History' in Thai
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติการคำนวณ', // 'No calculation history yet' in Thai
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ประวัติการคำนวณ Subnet และการตรวจสอบ IP จะแสดงที่นี่', // 'Subnet calculation and IP validation history will appear here' in Thai
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SubnetCalculatorViewModel viewModel,
  ) {
    final summary = viewModel.getHistorySummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'ประวัติการคำนวณ', // 'Calculation History' in Thai
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '${summary['total']} รายการ', // 'X items' in Thai
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Summary cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'คำนวณ Subnet', // 'Subnet Calculations' in Thai
                summary['calculations'].toString(),
                Icons.calculate,
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'ตรวจสอบ IP', // 'IP Validations' in Thai
                summary['validations'].toString(),
                Icons.verified_user,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSummaryCard(
                'วันนี้', // 'Today' in Thai
                summary['today'].toString(),
                Icons.today,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    SubnetCalculationEntry entry,
    SubnetCalculatorViewModel viewModel,
  ) {
    IconData icon;
    Color color;
    String actionText;

    switch (entry.type) {
      case SubnetCalculationType.subnetCalculation:
        icon = Icons.calculate;
        color = Theme.of(context).primaryColor;
        actionText = 'ใช้ข้อมูลนี้'; // 'Use this data' in Thai
        break;
      case SubnetCalculationType.ipValidation:
        icon = Icons.verified_user;
        color = Colors.green;
        actionText = 'ใช้ข้อมูลนี้'; // 'Use this data' in Thai
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.summary),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  entry.typeDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.dateDisplay} ${entry.formattedTimestamp}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'use':
                if (entry.type == SubnetCalculationType.subnetCalculation) {
                  viewModel.useHistoryCalculation(entry);
                } else {
                  viewModel.useHistoryValidation(entry);
                }
                break;
              case 'delete':
                _showDeleteDialog(context, entry, viewModel);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'use',
              child: Row(
                children: [
                  Icon(Icons.input, size: 18, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(actionText),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  const Text('ลบ'), // 'Delete' in Thai
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          if (entry.type == SubnetCalculationType.subnetCalculation) {
            viewModel.useHistoryCalculation(entry);
          } else {
            viewModel.useHistoryValidation(entry);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    SubnetCalculationEntry entry,
    SubnetCalculatorViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการ'), // 'Delete Item' in Thai
        content: Text(
          'คุณต้องการลบรายการ "${entry.title}" หรือไม่?', // 'Do you want to delete item "X"?' in Thai
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'), // 'Cancel' in Thai
          ),
          TextButton(
            onPressed: () {
              viewModel.removeHistoryEntry(entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ลบรายการแล้ว'), // 'Item deleted' in Thai
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'), // 'Delete' in Thai
          ),
        ],
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
                  content: Text(
                    'ล้างประวัติทั้งหมดแล้ว',
                  ), // 'All history cleared' in Thai
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
