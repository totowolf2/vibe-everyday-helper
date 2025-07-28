import '../../domain/models/exchange_rate.dart';
import '../../domain/models/currency.dart';

class ExchangeRateResponse {
  final double amount;
  final String base;
  final String date;
  final Map<String, double> rates;

  const ExchangeRateResponse({
    required this.amount,
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      amount: (json['amount'] ?? 1.0).toDouble(),
      base: json['base'] ?? '',
      date: json['date'] ?? '',
      rates: Map<String, double>.from(
        (json['rates'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'base': base, 'date': date, 'rates': rates};
  }

  ExchangeRate? toExchangeRate(String targetCurrencyCode) {
    final baseCurrency = Currency.fromCode(base);
    final targetCurrency = Currency.fromCode(targetCurrencyCode);
    final rate = rates[targetCurrencyCode];

    if (baseCurrency == null || targetCurrency == null || rate == null) {
      return null;
    }

    return ExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      rate: rate,
      lastUpdated: _parseDate(date),
      source: 'Frankfurter API',
    );
  }

  List<ExchangeRate> toExchangeRates() {
    final baseCurrency = Currency.fromCode(base);
    if (baseCurrency == null) return [];

    final exchangeRates = <ExchangeRate>[];
    final lastUpdated = _parseDate(date);

    for (final entry in rates.entries) {
      final targetCurrency = Currency.fromCode(entry.key);
      if (targetCurrency != null) {
        exchangeRates.add(
          ExchangeRate(
            baseCurrency: baseCurrency,
            targetCurrency: targetCurrency,
            rate: entry.value,
            lastUpdated: lastUpdated,
            source: 'Frankfurter API',
          ),
        );
      }
    }

    return exchangeRates;
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  bool get isValid => base.isNotEmpty && rates.isNotEmpty;

  @override
  String toString() {
    return 'ExchangeRateResponse(amount: $amount, base: $base, date: $date, rates: $rates)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExchangeRateResponse &&
        other.amount == amount &&
        other.base == base &&
        other.date == date &&
        _mapEquals(other.rates, rates);
  }

  @override
  int get hashCode {
    return amount.hashCode ^ base.hashCode ^ date.hashCode ^ rates.hashCode;
  }

  static bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
