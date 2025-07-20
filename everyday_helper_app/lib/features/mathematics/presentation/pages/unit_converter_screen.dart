import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/unit_converter_view_model.dart';
import '../../domain/models/unit_conversion.dart';
import '../../../../shared/constants/app_constants.dart';
import 'package:flutter/services.dart';

class UnitConverterScreen extends StatelessWidget {
  const UnitConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnitConverterViewModel(),
      child: const _UnitConverterView(),
    );
  }
}

class _UnitConverterView extends StatefulWidget {
  const _UnitConverterView();

  @override
  State<_UnitConverterView> createState() => _UnitConverterViewState();
}

class _UnitConverterViewState extends State<_UnitConverterView> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      context.read<UnitConverterViewModel>().updateInputValue(
        _inputController.text,
      );
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
        title: const Text('Unit Converter'),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        actions: [
          Consumer<UnitConverterViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      viewModel.clear();
                      _inputController.clear();
                      break;
                    case 'clear_history':
                      viewModel.clearHistory();
                      break;
                    case 'swap_units':
                      viewModel.swapUnits();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (viewModel.fromUnit != null && viewModel.toUnit != null)
                    const PopupMenuItem(
                      value: 'swap_units',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz),
                          SizedBox(width: 8),
                          Text('Swap Units'),
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
                  if (viewModel.conversions.isNotEmpty)
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
        child: Column(
          children: [
            // Fixed top section with category and input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultMargin, vertical: 4),
              child: Column(
                children: [
                  // Category Selector
                  _buildCategorySelector(context),
                  const SizedBox(height: 6),
                  // Unit Selection and Input
                  _buildConversionSection(context),
                ],
              ),
            ),
            // Flexible results section
            Expanded(
              child: Consumer<UnitConverterViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultMargin),
                      child: _buildErrorDisplay(
                        context,
                        viewModel.errorMessage!,
                      ),
                    );
                  } else if (viewModel.outputValue.isNotEmpty) {
                    return _buildResultsDisplay(context, viewModel);
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultMargin),
                      child: _buildInstructionsDisplay(context, viewModel),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Category',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Consumer<UnitConverterViewModel>(
              builder: (context, viewModel, child) {
                return Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: UnitCategory.values.map((category) {
                    final isSelected = viewModel.selectedCategory == category;
                    return FilterChip(
                      label: Text(
                        viewModel.getCategoryDisplayName(category),
                        style: const TextStyle(fontSize: 10),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          viewModel.setCategory(category);
                          _inputController.clear();
                        }
                      },
                      backgroundColor: isSelected
                          ? theme.colorScheme.tertiaryContainer
                          : null,
                      selectedColor: theme.colorScheme.tertiaryContainer,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionSection(BuildContext context) {
    return Consumer<UnitConverterViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Convert ${viewModel.getCategoryDisplayName(viewModel.selectedCategory)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultMargin),
                // Input section
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _inputController,
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,}$'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: _buildUnitDropdown(
                        context,
                        'From',
                        viewModel.fromUnit,
                        viewModel.availableUnits,
                        (unit) => viewModel.setFromUnit(unit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Swap button
                Center(
                  child: IconButton(
                    onPressed:
                        viewModel.fromUnit != null && viewModel.toUnit != null
                        ? viewModel.swapUnits
                        : null,
                    icon: const Icon(Icons.swap_vert),
                    iconSize: 24,
                    tooltip: 'Swap units',
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 6),
                // Output section
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        child: Text(
                          viewModel.outputValue.isEmpty
                              ? '0'
                              : viewModel.outputValue,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 4,
                      child: _buildUnitDropdown(
                        context,
                        'To',
                        viewModel.toUnit,
                        viewModel.availableUnits,
                        (unit) => viewModel.setToUnit(unit),
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

  Widget _buildUnitDropdown(
    BuildContext context,
    String label,
    Unit? selectedUnit,
    List<Unit> units,
    Function(Unit) onChanged,
  ) {
    return DropdownButtonFormField<Unit>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        isDense: true,
      ),
      value: selectedUnit,
      style: const TextStyle(fontSize: 12),
      isExpanded: true,
      selectedItemBuilder: (BuildContext context) {
        return units.map<Widget>((Unit unit) {
          return Text(
            unit.symbol.isNotEmpty ? unit.symbol : unit.name.substring(0, unit.name.length > 8 ? 8 : unit.name.length),
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: units.map((unit) {
        return DropdownMenuItem<Unit>(
          value: unit,
          child: Text(
            unit.symbol.isNotEmpty ? '${unit.name} (${unit.symbol})' : unit.name,
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: (unit) {
        if (unit != null) {
          onChanged(unit);
        }
      },
    );
  }

  Widget _buildResultsDisplay(
    BuildContext context,
    UnitConverterViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultMargin),
      child: Column(
        children: [
          _buildMainResultCard(context, viewModel),
          const SizedBox(height: AppConstants.defaultMargin),
          _buildDetailedResults(context, viewModel),
          if (viewModel.getCommonConversions().isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultMargin),
            _buildQuickConversions(context, viewModel),
          ],
          if (viewModel.conversions.isNotEmpty) ...[
            const SizedBox(height: AppConstants.defaultMargin),
            _buildHistoryCard(context, viewModel),
          ],
          // Add bottom padding for better scrolling
          const SizedBox(height: AppConstants.defaultMargin),
        ],
      ),
    );
  }

  Widget _buildMainResultCard(
    BuildContext context,
    UnitConverterViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.straighten,
              size: 24,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(height: 4),
            Text(
              'Result',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${viewModel.inputValue} ${viewModel.fromUnit?.symbol ?? ''} = ${viewModel.outputValue} ${viewModel.toUnit?.symbol ?? ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResults(
    BuildContext context,
    UnitConverterViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final details = viewModel.getConversionDetails();

    if (details.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversion Details',
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
                    Text(entry.key, style: theme.textTheme.bodyMedium),
                    Flexible(
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.end,
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

  Widget _buildQuickConversions(
    BuildContext context,
    UnitConverterViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final commonConversions = viewModel.getCommonConversions();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Conversions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultMargin),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonConversions.map((conversion) {
                return ActionChip(
                  label: Text(conversion['label']!),
                  onPressed: () {
                    viewModel.setQuickConversion(
                      conversion['from']!,
                      conversion['to']!,
                      '1',
                    );
                    _inputController.text = '1';
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    UnitConverterViewModel viewModel,
  ) {
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
                  'Recent Conversions',
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
            ...viewModel.conversions.take(5).map((conversion) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    // Tap to reuse conversion
                    viewModel.setCategory(conversion.fromUnit.category);
                    viewModel.setFromUnit(conversion.fromUnit);
                    viewModel.setToUnit(conversion.toUnit);
                    _inputController.text = conversion.value.toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.formatConversionText(conversion),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
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

  Widget _buildInstructionsDisplay(
    BuildContext context,
    UnitConverterViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.straighten, color: theme.primaryColor, size: 48),
              const SizedBox(height: AppConstants.defaultMargin),
              Text(
                'Unit Converter',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultMargin / 2),
              Text(
                'Convert between units with precision',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultMargin),
              const Text(
                '1. Select a category\n'
                '2. Choose units to convert\n'
                '3. Enter a value',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
