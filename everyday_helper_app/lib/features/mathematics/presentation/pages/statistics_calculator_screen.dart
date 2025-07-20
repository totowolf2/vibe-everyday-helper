import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_models/statistics_calculator_view_model.dart';
import '../../../../shared/constants/app_constants.dart';

class StatisticsCalculatorScreen extends StatelessWidget {
  const StatisticsCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatisticsCalculatorViewModel(),
      child: const _StatisticsCalculatorView(),
    );
  }
}

class _StatisticsCalculatorView extends StatefulWidget {
  const _StatisticsCalculatorView();

  @override
  State<_StatisticsCalculatorView> createState() =>
      _StatisticsCalculatorViewState();
}

class _StatisticsCalculatorViewState extends State<_StatisticsCalculatorView> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      context.read<StatisticsCalculatorViewModel>().updateInput(_inputController.text);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Calculator'),
        backgroundColor: theme.colorScheme.secondaryContainer,
        actions: [
          Consumer<StatisticsCalculatorViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      viewModel.clear();
                      _inputController.clear();
                      break;
                    case 'sample_data':
                      viewModel.addSampleData();
                      _inputController.text = viewModel.inputText;
                      break;
                    case 'export':
                      _exportResults(context, viewModel);
                      break;
                    case 'clear_history':
                      viewModel.clearHistory();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'sample_data',
                    child: Row(
                      children: [
                        Icon(Icons.data_usage),
                        SizedBox(width: 8),
                        Text('Load Sample Data'),
                      ],
                    ),
                  ),
                  if (viewModel.hasResult)
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Export Results'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text('Clear All'),
                      ],
                    ),
                  ),
                  if (viewModel.calculations.isNotEmpty)
                    const PopupMenuItem(
                      value: 'clear_history',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear History'),
                        ],
                      ),
                    ),
                ],
                icon: const Icon(Icons.more_vert),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Input Section
              _buildInputSection(context),
              const SizedBox(height: AppConstants.defaultPadding),
              // Results Section
              Expanded(
                child: Consumer<StatisticsCalculatorViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.hasError) {
                      return _buildErrorDisplay(context, viewModel.errorMessage!);
                    } else if (viewModel.hasResult) {
                      return _buildResultsDisplay(context, viewModel);
                    } else {
                      return _buildInstructionsDisplay(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Numbers',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                hintText: 'Enter numbers separated by commas (e.g., 1, 2, 3, 4, 5)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                context.read<StatisticsCalculatorViewModel>().calculateStatistics();
              },
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<StatisticsCalculatorViewModel>().calculateStatistics();
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Statistics'),
                  ),
                ),
                const SizedBox(width: AppConstants.defaultMargin),
                Consumer<StatisticsCalculatorViewModel>(
                  builder: (context, viewModel, child) {
                    return IconButton(
                      onPressed: () {
                        viewModel.clear();
                        _inputController.clear();
                      },
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsDisplay(BuildContext context, StatisticsCalculatorViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSummaryCard(context, viewModel),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildDetailedResults(context, viewModel),
          if (viewModel.getOutliers().isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            _buildOutliersCard(context, viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, StatisticsCalculatorViewModel viewModel) {
    final theme = Theme.of(context);
    final results = viewModel.getFormattedResults();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Count', results['Count'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildStatItem('Mean', results['Mean'] ?? 'N/A'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultMargin / 2),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Median', results['Median'] ?? 'N/A'),
                ),
                Expanded(
                  child: _buildStatItem('Std Dev', results['Standard Deviation'] ?? 'N/A'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedResults(BuildContext context, StatisticsCalculatorViewModel viewModel) {
    final theme = Theme.of(context);
    final results = viewModel.getFormattedResults();

    final sections = [
      {
        'title': 'Central Tendency',
        'items': ['Mean', 'Median', 'Mode'],
      },
      {
        'title': 'Variability',
        'items': ['Range', 'Variance', 'Standard Deviation', 'Standard Error', 'Coefficient of Variation'],
      },
      {
        'title': 'Position',
        'items': ['Minimum', 'Q1 (25th percentile)', 'Q3 (75th percentile)', 'Maximum', 'IQR'],
      },
      {
        'title': 'Shape',
        'items': ['Skewness', 'Kurtosis'],
      },
    ];

    return Column(
      children: sections.map((section) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section['title'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultMargin),
                ...((section['items'] as List<String>).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item),
                        Text(
                          results[item] ?? 'N/A',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOutliersCard(BuildContext context, StatisticsCalculatorViewModel viewModel) {
    final theme = Theme.of(context);
    final outliers = viewModel.getOutliers();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outliers',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Text(
              outliers.join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin / 2),
            Text(
              'Values outside 1.5 × IQR from Q1 and Q3',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              Text(
                'Error',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsDisplay(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart,
                color: theme.primaryColor,
                size: 64,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Statistics Calculator',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              const Text(
                'Enter numbers separated by commas to calculate statistical measures including:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              const Text(
                '• Mean, Median, Mode\n'
                '• Standard Deviation & Variance\n'
                '• Quartiles & Outliers\n'
                '• Skewness & Kurtosis',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportResults(BuildContext context, StatisticsCalculatorViewModel viewModel) {
    final results = viewModel.exportResults();
    
    Clipboard.setData(ClipboardData(text: results));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Results copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}