import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/basic_calculator_view_model.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_button.dart';
import '../../../../shared/constants/app_constants.dart';

class BasicCalculatorScreen extends StatelessWidget {
  const BasicCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BasicCalculatorViewModel(),
      child: const _BasicCalculatorView(),
    );
  }
}

class _BasicCalculatorView extends StatelessWidget {
  const _BasicCalculatorView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Calculator'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          Consumer<BasicCalculatorViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear_history':
                      viewModel.clearHistory();
                      break;
                    case 'toggle_history':
                      // History toggle handled in display
                      break;
                  }
                },
                itemBuilder: (context) => [
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
              // Display
              Expanded(
                flex: 2,
                child: Consumer<BasicCalculatorViewModel>(
                  builder: (context, viewModel, child) {
                    return CalculatorDisplay(
                      expression: viewModel.expression,
                      result: viewModel.result,
                      errorMessage: viewModel.errorMessage,
                      showHistory: viewModel.calculations.isNotEmpty,
                      history: viewModel.historyStrings.take(3).toList(),
                      onClearHistory: viewModel.clearHistory,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              // Button Grid
              Expanded(
                flex: 3,
                child: Consumer<BasicCalculatorViewModel>(
                  builder: (context, viewModel, child) {
                    return _buildButtonGrid(context, viewModel);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid(
    BuildContext context,
    BasicCalculatorViewModel viewModel,
  ) {
    return CalculatorButtonGrid(
      buttonRows: [
        // Row 1: Clear, Clear Entry, Backspace, Divide
        [
          CalculatorButton(
            text: 'C',
            onPressed: viewModel.clear,
            type: CalculatorButtonType.control,
          ),
          CalculatorButton(
            text: 'CE',
            onPressed: viewModel.clearEntry,
            type: CalculatorButtonType.control,
          ),
          CalculatorButton(
            text: '⌫',
            onPressed: viewModel.clearEntry,
            type: CalculatorButtonType.control,
          ),
          CalculatorButton(
            text: '÷',
            onPressed: () => viewModel.inputOperator('/'),
            type: CalculatorButtonType.operator,
          ),
        ],
        // Row 2: 7, 8, 9, Multiply
        [
          CalculatorButton(
            text: '7',
            onPressed: () => viewModel.onNumberPressed('7'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '8',
            onPressed: () => viewModel.onNumberPressed('8'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '9',
            onPressed: () => viewModel.onNumberPressed('9'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '×',
            onPressed: () => viewModel.inputOperator('*'),
            type: CalculatorButtonType.operator,
          ),
        ],
        // Row 3: 4, 5, 6, Subtract
        [
          CalculatorButton(
            text: '4',
            onPressed: () => viewModel.onNumberPressed('4'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '5',
            onPressed: () => viewModel.onNumberPressed('5'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '6',
            onPressed: () => viewModel.onNumberPressed('6'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '-',
            onPressed: () => viewModel.inputOperator('-'),
            type: CalculatorButtonType.operator,
          ),
        ],
        // Row 4: 1, 2, 3, Add
        [
          CalculatorButton(
            text: '1',
            onPressed: () => viewModel.onNumberPressed('1'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '2',
            onPressed: () => viewModel.onNumberPressed('2'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '3',
            onPressed: () => viewModel.onNumberPressed('3'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '+',
            onPressed: () => viewModel.inputOperator('+'),
            type: CalculatorButtonType.operator,
          ),
        ],
        // Row 5: +/-, 0, ., Equals
        [
          CalculatorButton(
            text: '±',
            onPressed: viewModel.negate,
            type: CalculatorButtonType.function,
          ),
          CalculatorButton(
            text: '0',
            onPressed: () => viewModel.onNumberPressed('0'),
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '.',
            onPressed: viewModel.inputDecimal,
            type: CalculatorButtonType.number,
          ),
          CalculatorButton(
            text: '=',
            onPressed: viewModel.calculate,
            type: CalculatorButtonType.special,
          ),
        ],
      ],
    );
  }
}

class BasicCalculatorHelper {
  static const List<List<String>> buttonLayout = [
    ['C', 'CE', '⌫', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  static CalculatorButtonType getButtonType(String text) {
    switch (text) {
      case 'C':
      case 'CE':
      case '⌫':
        return CalculatorButtonType.control;
      case '÷':
      case '×':
      case '-':
      case '+':
        return CalculatorButtonType.operator;
      case '±':
        return CalculatorButtonType.function;
      case '=':
        return CalculatorButtonType.special;
      default:
        return CalculatorButtonType.number;
    }
  }

  static bool isOperator(String text) {
    return ['÷', '×', '-', '+'].contains(text);
  }

  static bool isNumber(String text) {
    return RegExp(r'^[0-9.]$').hasMatch(text);
  }

  static bool isControl(String text) {
    return ['C', 'CE', '⌫'].contains(text);
  }
}
