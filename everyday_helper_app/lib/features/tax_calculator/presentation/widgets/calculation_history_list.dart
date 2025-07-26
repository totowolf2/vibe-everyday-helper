import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../domain/models/tax_result.dart';
import '../../../../shared/constants/app_constants.dart';

class CalculationHistoryList extends StatelessWidget {
  final List<TaxResult> history;
  final Function(TaxResult) onResultSelected;
  final VoidCallback? onClearHistory;
  final int maxDisplay;

  const CalculationHistoryList({
    super.key,
    required this.history,
    required this.onResultSelected,
    this.onClearHistory,
    this.maxDisplay = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No calculation history yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Your tax calculations will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Calculation History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (onClearHistory != null)
                  TextButton(
                    onPressed: onClearHistory,
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...history.take(maxDisplay).map((result) {
              return HistoryItem(
                result: result,
                onTap: () => onResultSelected(result),
              );
            }),
            if (history.length > maxDisplay)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${history.length - maxDisplay} more calculations...',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  final TaxResult result;
  final VoidCallback onTap;

  const HistoryItem({super.key, required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax: ${_formatCurrency(result.calculatedTax)} THB',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_formatPercentage(result.effectiveTaxRate)}%',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Income: ${_formatCurrency(result.grossIncome)} THB',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    _formatDate(result.calculationDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              if (result.totalDeductions > Decimal.fromInt(0)) ...[
                const SizedBox(height: 4),
                Text(
                  'Deductions: ${_formatCurrency(result.totalDeductions)} THB',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(Decimal amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatPercentage(Decimal percentage) {
    return percentage.toStringAsFixed(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class HistoryDetailDialog extends StatelessWidget {
  final TaxResult result;

  const HistoryDetailDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tax Calculation Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(
              'Calculation Date',
              _formatDate(result.calculationDate),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Gross Income',
              '${_formatCurrency(result.grossIncome)} THB',
            ),
            _buildDetailRow(
              'Total Allowances',
              '${_formatCurrency(result.totalAllowances)} THB',
            ),
            _buildDetailRow(
              'Total Deductions',
              '${_formatCurrency(result.totalDeductions)} THB',
            ),
            const Divider(),
            _buildDetailRow(
              'Taxable Income',
              '${_formatCurrency(result.taxableIncome)} THB',
              isHighlight: true,
            ),
            _buildDetailRow(
              'Tax Owed',
              '${_formatCurrency(result.calculatedTax)} THB',
              isHighlight: true,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Effective Tax Rate',
              '${_formatPercentage(result.effectiveTaxRate)}%',
            ),
            _buildDetailRow(
              'Net Income',
              '${_formatCurrency(result.netIncome)} THB',
            ),
            if (result.bracketBreakdown.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tax Breakdown by Bracket:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.bracketBreakdown.map((bracket) {
                if (bracket.taxableAmount > Decimal.fromInt(0)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${bracket.bracketDescription}: ${_formatCurrency(bracket.taxAmount)} THB',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(Decimal amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatPercentage(Decimal percentage) {
    return percentage.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
