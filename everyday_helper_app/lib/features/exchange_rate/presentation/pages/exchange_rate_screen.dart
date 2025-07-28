import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view_models/exchange_rate_view_model.dart';
import '../widgets/exchange_rate_header.dart';
import '../widgets/currency_selector.dart';
import '../widgets/multiplier_list.dart';
import '../widgets/calculation_results.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../data/datasources/frankfurter_api_datasource.dart';

class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  ExchangeRateViewModel? _viewModel;
  final TextEditingController _amountController = TextEditingController();
  bool _isInitializing = true;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataSource = FrankfurterApiDataSource();
      final repository = ExchangeRateRepositoryImpl(
        dataSource: dataSource,
        preferences: prefs,
      );

      final viewModel = ExchangeRateViewModel(
        repository: repository,
        preferences: prefs,
      );

      // Set initial amount but clear 0.0 if it's the default
      if (viewModel.baseAmount == 0.0) {
        _amountController.text = '';
      } else {
        _amountController.text = viewModel.baseAmount.toString();
      }
      _amountController.addListener(_onAmountChanged);

      await viewModel.initialize();

      if (mounted) {
        setState(() {
          _viewModel = viewModel;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initializationError = e.toString();
        });
      }
    }
  }

  void _onAmountChanged() {
    final text = _amountController.text.trim();
    // Handle empty string as 0.0
    if (text.isEmpty) {
      _viewModel?.setBaseAmount(0.0);
      return;
    }
    
    // Parse the amount, default to 0.0 if invalid
    final amount = double.tryParse(text) ?? 0.0;
    _viewModel?.setBaseAmount(amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('💱 Exchange Rate Calculator'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing exchange rate calculator...'),
            ],
          ),
        ),
      );
    }

    if (_initializationError != null || _viewModel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('💱 Exchange Rate Calculator'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize exchange rate calculator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_initializationError != null)
                Text(
                  _initializationError!,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initializationError = null;
                  });
                  _initializeViewModel();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('💱 Exchange Rate Calculator'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<ExchangeRateViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  onPressed: viewModel.isRefreshing
                      ? null
                      : () {
                          viewModel.refreshExchangeRate();
                        },
                  icon: viewModel.isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Refresh rates',
                );
              },
            ),
          ],
        ),
        body: Consumer<ExchangeRateViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading exchange rates...'),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error banner
                  if (viewModel.hasError)
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: viewModel.clearError,
                              icon: const Icon(Icons.close),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Exchange rate header
                  const ExchangeRateHeader(),

                  const SizedBox(height: 16),

                  // Currency selector
                  CurrencySelector(
                    baseCurrency: viewModel.baseCurrency,
                    targetCurrency: viewModel.targetCurrency,
                    onBaseCurrencyChanged: viewModel.setBaseCurrency,
                    onTargetCurrencyChanged: viewModel.setTargetCurrency,
                    onSwapCurrencies: viewModel.swapCurrencies,
                  ),

                  const SizedBox(height: 16),

                  // Amount input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.monetization_on),
                              const SizedBox(width: 8),
                              Text(
                                'ใส่จำนวนเงิน',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: 'กรอกจำนวนเงิน',
                              suffixText: viewModel.baseCurrency.code,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.attach_money),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Multiplier list
                  const MultiplierList(),

                  const SizedBox(height: 16),

                  // Calculation results
                  const CalculationResults(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
