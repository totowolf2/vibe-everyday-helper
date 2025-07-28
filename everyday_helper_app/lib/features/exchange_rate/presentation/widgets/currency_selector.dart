import 'package:flutter/material.dart';
import '../../domain/models/currency.dart';

class CurrencySelector extends StatelessWidget {
  final Currency baseCurrency;
  final Currency targetCurrency;
  final Function(Currency) onBaseCurrencyChanged;
  final Function(Currency) onTargetCurrencyChanged;
  final VoidCallback onSwapCurrencies;

  const CurrencySelector({
    super.key,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.onBaseCurrencyChanged,
    required this.onTargetCurrencyChanged,
    required this.onSwapCurrencies,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz),
                const SizedBox(width: 8),
                Text(
                  'เลือกสกุลเงิน',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                // Use vertical layout for small screens
                if (constraints.maxWidth < 400) {
                  return Column(
                    children: [
                      // Base currency dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('จาก', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<Currency>(
                            value: baseCurrency,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: Currency.supportedCurrencies.map((currency) {
                              return DropdownMenuItem<Currency>(
                                value: currency,
                                child: Text(
                                  '${currency.symbol} ${currency.code}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (currency) {
                              if (currency != null) {
                                onBaseCurrencyChanged(currency);
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Swap button
                      Center(
                        child: IconButton(
                          onPressed: onSwapCurrencies,
                          icon: const Icon(Icons.swap_vert),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          tooltip: 'สลับสกุลเงิน',
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Target currency dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ไป', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<Currency>(
                            value: targetCurrency,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: Currency.supportedCurrencies.map((currency) {
                              return DropdownMenuItem<Currency>(
                                value: currency,
                                child: Text(
                                  '${currency.symbol} ${currency.code}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (currency) {
                              if (currency != null) {
                                onTargetCurrencyChanged(currency);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Use horizontal layout for larger screens
                return Row(
                  children: [
                    // Base currency dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('จาก', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<Currency>(
                            value: baseCurrency,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: Currency.supportedCurrencies.map((currency) {
                              return DropdownMenuItem<Currency>(
                                value: currency,
                                child: Text(
                                  '${currency.symbol} ${currency.code}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (currency) {
                              if (currency != null) {
                                onBaseCurrencyChanged(currency);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Swap button
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          onPressed: onSwapCurrencies,
                          icon: const Icon(Icons.swap_horiz),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          tooltip: 'สลับสกุลเงิน',
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // Target currency dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ไป', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<Currency>(
                            value: targetCurrency,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: Currency.supportedCurrencies.map((currency) {
                              return DropdownMenuItem<Currency>(
                                value: currency,
                                child: Text(
                                  '${currency.symbol} ${currency.code}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (currency) {
                              if (currency != null) {
                                onTargetCurrencyChanged(currency);
                              }
                            },
                          ),
                        ],
                      ),
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
}
