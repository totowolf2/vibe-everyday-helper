import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../domain/models/tax_result.dart';
import '../../../../shared/constants/app_constants.dart';

class TaxBreakdownCard extends StatelessWidget {
  final TaxResult result;
  final bool showDetailedBreakdown;

  const TaxBreakdownCard({
    super.key,
    required this.result,
    this.showDetailedBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    if (result.hasError) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Calculation Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                result.errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tax Calculation Summary',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryGrid(context),
              ],
            ),
          ),
        ),

        if (showDetailedBreakdown) ...[
          const SizedBox(height: 16),
          // Detailed Breakdown
          _buildDetailedBreakdown(context),
        ],
      ],
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context,
                'Gross Income',
                _formatCurrency(result.grossIncome),
                Icons.attach_money,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryItem(
                context,
                'Tax Owed',
                _formatCurrency(result.calculatedTax),
                Icons.payment,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                context,
                'Effective Rate',
                '${_formatPercentage(result.effectiveTaxRate)}%',
                Icons.percent,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryItem(
                context,
                'Net Income',
                _formatCurrency(result.netIncome),
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Calculation',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Income and Deductions
            _buildCalculationStep('Step 1: Calculate Taxable Income', [
              _buildDetailRow('Gross Annual Income', result.grossIncome),
              _buildDetailRow(
                'Less: Total Allowances',
                result.totalAllowances,
                isNegative: true,
              ),
              _buildDetailRow(
                'Less: Total Deductions',
                result.totalDeductions,
                isNegative: true,
              ),
              const Divider(),
              _buildDetailRow(
                'Taxable Income',
                result.taxableIncome,
                isResult: true,
              ),
            ]),

            const SizedBox(height: 20),

            // Tax Calculation by Bracket
            if (result.bracketBreakdown.isNotEmpty)
              _buildCalculationStep('Step 2: Apply Tax Brackets', [
                ...result.bracketBreakdown
                    .where(
                      (bracket) => bracket.taxableAmount > Decimal.fromInt(0),
                    )
                    .map((bracket) => _buildBracketRow(bracket)),
                const Divider(),
                _buildDetailRow(
                  'Total Tax',
                  result.calculatedTax,
                  isResult: true,
                ),
              ]),

            const SizedBox(height: 20),

            // Final Result
            _buildCalculationStep('Step 3: Final Result', [
              _buildDetailRow('Gross Income', result.grossIncome),
              _buildDetailRow(
                'Less: Tax Owed',
                result.calculatedTax,
                isNegative: true,
              ),
              const Divider(),
              _buildDetailRow('Net Income', result.netIncome, isResult: true),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Effective Tax Rate',
                Decimal.parse(_formatPercentage(result.effectiveTaxRate)),
                suffix: '%',
                isResult: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationStep(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    Decimal amount, {
    String suffix = 'THB',
    bool isNegative = false,
    bool isResult = false,
  }) {
    final color = isResult
        ? Colors.deepPurple
        : isNegative
        ? Colors.red[700]
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isResult ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}${_formatCurrency(amount)} $suffix',
            style: TextStyle(
              fontWeight: isResult ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketRow(TaxBracketCalculation bracket) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              bracket.bracketDescription,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'at ${bracket.taxRateDisplay}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_formatCurrency(bracket.taxAmount)} THB',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
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
}
