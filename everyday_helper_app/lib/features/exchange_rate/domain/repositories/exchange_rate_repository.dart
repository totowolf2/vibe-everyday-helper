import '../models/exchange_rate.dart';
import '../models/currency.dart';

abstract class ExchangeRateRepository {
  Future<ExchangeRate> getExchangeRate({
    required Currency baseCurrency,
    required Currency targetCurrency,
  });

  Future<Map<Currency, double>> getMultipleRates({
    required Currency baseCurrency,
    required List<Currency> targetCurrencies,
  });

  Future<List<Currency>> getSupportedCurrencies();

  Future<ExchangeRate?> getCachedExchangeRate({
    required Currency baseCurrency,
    required Currency targetCurrency,
  });

  Future<void> cacheExchangeRate(ExchangeRate exchangeRate);

  Future<void> clearCache();
}
