import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/percentage_calculator_view_model.dart';
import '../../../../shared/constants/app_constants.dart';

class PercentageCalculatorScreen extends StatelessWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PercentageCalculatorViewModel(),
      child: const _PercentageCalculatorView(),
    );
  }
}

class _PercentageCalculatorView extends StatefulWidget {
  const _PercentageCalculatorView();

  @override
  State<_PercentageCalculatorView> createState() =>
      _PercentageCalculatorViewState();
}

class _PercentageCalculatorViewState extends State<_PercentageCalculatorView> {
  final TextEditingController _value1Controller = TextEditingController();
  final TextEditingController _value2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value1Controller.addListener(() {
      context.read<PercentageCalculatorViewModel>().updateValue1(_value1Controller.text);
    });
    _value2Controller.addListener(() {
      context.read<PercentageCalculatorViewModel>().updateValue2(_value2Controller.text);
    });
  }

  @override
  void dispose() {
    _value1Controller.dispose();
    _value2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Percentage Calculator'),
        backgroundColor: theme.colorScheme.errorContainer,
        actions: [
          Consumer<PercentageCalculatorViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      viewModel.clear();
                      _value1Controller.clear();
                      _value2Controller.clear();
                      break;
                    case 'clear_history':
                      viewModel.clearHistory();
                      break;
                  }
                },
                itemBuilder: (context) => [
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
              // Calculator Type Selector
              _buildTypeSelector(context),
              const SizedBox(height: AppConstants.defaultPadding),
              // Input Section
              _buildInputSection(context),
              const SizedBox(height: AppConstants.defaultPadding),
              // Results Section
              Expanded(
                child: Consumer<PercentageCalculatorViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.hasError) {
                      return _buildErrorDisplay(context, viewModel.errorMessage!);
                    } else if (viewModel.result.isNotEmpty) {
                      return _buildResultsDisplay(context, viewModel);
                    } else {
                      return _buildInstructionsDisplay(context, viewModel);
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

  Widget _buildTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculator Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Consumer<PercentageCalculatorViewModel>(
              builder: (context, viewModel, child) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PercentageCalculatorViewModel.commonTypes.map((type) {
                    final isSelected = viewModel.currentType == type;
                    return FilterChip(
                      label: Text(viewModel.getTypeTitle(type)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          viewModel.setCalculationType(type);
                          _value1Controller.clear();
                          _value2Controller.clear();
                        }
                      },
                      backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
                      selectedColor: theme.colorScheme.primaryContainer,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Consumer<PercentageCalculatorViewModel>(
              builder: (context, viewModel, child) {
                return ExpansionTile(
                  title: const Text('More Options'),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PercentageCalculatorViewModel.allTypes
                          .where((type) => !PercentageCalculatorViewModel.commonTypes.contains(type))
                          .map((type) {
                        final isSelected = viewModel.currentType == type;
                        return FilterChip(
                          label: Text(viewModel.getTypeTitle(type)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              viewModel.setCalculationType(type);
                              _value1Controller.clear();
                              _value2Controller.clear();
                            }
                          },
                          backgroundColor: isSelected ? theme.colorScheme.primaryContainer : null,
                          selectedColor: theme.colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Consumer<PercentageCalculatorViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.getTypeTitle(viewModel.currentType),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultMargin / 2),
                Text(
                  viewModel.getTypeDescription(viewModel.currentType),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _value1Controller,
                        decoration: InputDecoration(
                          labelText: viewModel.getValue1Label(viewModel.currentType),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.input),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: AppConstants.defaultMargin),
                    Expanded(
                      child: TextField(
                        controller: _value2Controller,
                        decoration: InputDecoration(
                          labelText: viewModel.getValue2Label(viewModel.currentType),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.input),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsDisplay(BuildContext context, PercentageCalculatorViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainResultCard(context, viewModel),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildDetailedResults(context, viewModel),
          if (viewModel.calculations.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            _buildHistoryCard(context, viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildMainResultCard(BuildContext context, PercentageCalculatorViewModel viewModel) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Icon(
              Icons.percent,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Text(
              'Result',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin / 2),
            Text(
              viewModel.result,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResults(BuildContext context, PercentageCalculatorViewModel viewModel) {
    final theme = Theme.of(context);
    final details = viewModel.getDetailedResults();

    if (details.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            ...details.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      entry.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PercentageCalculatorViewModel viewModel) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Calculations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: viewModel.clearHistory,
                  icon: const Icon(Icons.clear_all),
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            ...viewModel.calculations.take(5).map((calc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      calc.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'Result: ${calc.formattedResult}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (calc != viewModel.calculations.last)
                      Divider(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        height: 16,
                      ),
                  ],
                ),
              );
            }),
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

  Widget _buildInstructionsDisplay(BuildContext context, PercentageCalculatorViewModel viewModel) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.percent,
                color: theme.primaryColor,
                size: 64,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                viewModel.getTypeTitle(viewModel.currentType),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              Text(
                viewModel.getTypeDescription(viewModel.currentType),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              const Text(
                'Enter values in the fields above to calculate',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}