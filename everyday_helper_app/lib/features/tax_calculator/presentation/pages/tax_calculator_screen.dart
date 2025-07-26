import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';
import '../view_models/tax_calculator_view_model.dart';
import '../../../../shared/constants/app_constants.dart';

class TaxCalculatorScreen extends StatelessWidget {
  const TaxCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaxCalculatorViewModel(),
      child: const _TaxCalculatorView(),
    );
  }
}

class _TaxCalculatorView extends StatelessWidget {
  const _TaxCalculatorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thai Tax Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<TaxCalculatorViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tax calculator...'),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.input), text: 'Input'),
                    Tab(icon: Icon(Icons.analytics), text: 'Results'),
                    Tab(icon: Icon(Icons.help), text: 'Help'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildInputTab(context, viewModel),
                      _buildResultsTab(context, viewModel),
                      _buildHelpTab(context, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputTab(
    BuildContext context,
    TaxCalculatorViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Annual Income',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: viewModel.currentInput.annualIncome
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Annual Income (THB)',
                      hintText: 'Enter your annual income',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateAnnualIncome,
                  ),
                  if (viewModel.formErrors.containsKey('annualIncome'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        viewModel.formErrors['annualIncome']!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allowances',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: viewModel.currentInput.spouseAllowance
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Spouse Allowance (THB)',
                      hintText: 'Enter spouse allowance (max 60,000)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateSpouseAllowance,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Number of Children: '),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: viewModel.currentInput.numberOfChildren,
                        items: List.generate(21, (index) => index)
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            viewModel.updateNumberOfChildren(value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deductions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: viewModel.currentInput.insurancePremium
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Insurance Premium (THB)',
                      hintText: 'Max 100,000 THB',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateInsurancePremium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: viewModel.currentInput.retirementFund
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Retirement Fund (THB)',
                      hintText: 'Max 500,000 THB or 30% of income',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateRetirementFund,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: viewModel.currentInput.mortgageInterest
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Mortgage Interest (THB)',
                      hintText: 'Max 100,000 THB per year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateMortgageInterest,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: viewModel
                        .currentInput
                        .socialSecurityContribution
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Social Security (THB)',
                      hintText: 'Max 9,000 THB per year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateSocialSecurityContribution,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: viewModel.currentInput.providentFund
                        .toString(),
                    decoration: const InputDecoration(
                      labelText: 'Provident Fund (THB)',
                      hintText: 'Max 500,000 THB or 15% of salary',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: viewModel.updateProvidentFund,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.isCalculating
                  ? null
                  : viewModel.calculateTax,
              child: viewModel.isCalculating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Calculate Tax'),
            ),
          ),
          if (viewModel.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text(
                    viewModel.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsTab(
    BuildContext context,
    TaxCalculatorViewModel viewModel,
  ) {
    if (!viewModel.hasResult) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No calculation results yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Go to the Input tab and calculate your tax',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tax Calculation Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow(
                    'Gross Income',
                    viewModel.formatCurrency(
                      viewModel.currentResult!.grossIncome,
                    ),
                  ),
                  _buildResultRow(
                    'Total Allowances',
                    viewModel.formatCurrency(
                      viewModel.currentResult!.totalAllowances,
                    ),
                  ),
                  _buildResultRow(
                    'Total Deductions',
                    viewModel.formatCurrency(
                      viewModel.currentResult!.totalDeductions,
                    ),
                  ),
                  const Divider(),
                  _buildResultRow(
                    'Taxable Income',
                    viewModel.formatCurrency(
                      viewModel.currentResult!.taxableIncome,
                    ),
                  ),
                  _buildResultRow(
                    'Tax Owed',
                    viewModel.formatCurrency(
                      viewModel.currentResult!.calculatedTax,
                    ),
                    isHighlight: true,
                  ),
                  _buildResultRow(
                    'Effective Tax Rate',
                    '${viewModel.formatPercentage(viewModel.currentResult!.effectiveTaxRate)}%',
                  ),
                  _buildResultRow(
                    'Net Income',
                    viewModel.formatCurrency(
                      viewModel.currentResult!.netIncome,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.currentResult!.bracketBreakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tax Breakdown by Bracket',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...viewModel.currentResult!.bracketBreakdown.map((bracket) {
                      if (bracket.taxableAmount > Decimal.fromInt(0)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${bracket.bracketDescription} at ${bracket.taxRateDisplay}',
                                ),
                              ),
                              Text(
                                '${viewModel.formatCurrency(bracket.taxAmount)} THB',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (viewModel.calculationHistory.isNotEmpty)
            Card(
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: viewModel.clearHistory,
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...viewModel.calculationHistory.take(5).map((result) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            'Tax: ${viewModel.formatCurrency(result.calculatedTax)} THB',
                          ),
                          subtitle: Text(
                            'Income: ${viewModel.formatCurrency(result.grossIncome)} THB • '
                            '${result.calculationDate.day}/${result.calculationDate.month}/${result.calculationDate.year}',
                          ),
                          trailing: Text(
                            '${viewModel.formatPercentage(result.effectiveTaxRate)}%',
                          ),
                          onTap: () => viewModel.useHistoryResult(result),
                        ),
                      );
                    }),
                    if (viewModel.calculationHistory.length > 5)
                      Center(
                        child: Text(
                          '${viewModel.calculationHistory.length - 5} more calculations...',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ),
          Text(
            '$value THB',
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTab(BuildContext context, TaxCalculatorViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Thai Tax Calculator',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This calculator helps you compute your personal income tax in Thailand based on the 2024 tax brackets and allowances.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Features:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Progressive tax calculation using official Thai tax brackets',
                  ),
                  Text('• Personal, spouse, and child allowances'),
                  Text(
                    '• Common deductions (insurance, retirement fund, etc.)',
                  ),
                  Text('• Detailed breakdown by tax bracket'),
                  Text('• Calculation history'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2024 Tax Brackets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('0 - 150,000 THB: 0%'),
                  Text('150,001 - 300,000 THB: 5%'),
                  Text('300,001 - 500,000 THB: 10%'),
                  Text('500,001 - 750,000 THB: 15%'),
                  Text('750,001 - 1,000,000 THB: 20%'),
                  Text('1,000,001 - 2,000,000 THB: 25%'),
                  Text('2,000,001 - 5,000,000 THB: 30%'),
                  Text('Over 5,000,000 THB: 35%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standard Allowances',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Personal: 60,000 THB'),
                  Text('Spouse: Up to 60,000 THB'),
                  Text('Child: 30,000 THB per child'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('• This calculator is for estimation purposes only'),
                  Text('• Consult a tax professional for complex situations'),
                  Text('• Tax laws may change - verify current rates'),
                  Text('• Keep all receipts and documentation'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
