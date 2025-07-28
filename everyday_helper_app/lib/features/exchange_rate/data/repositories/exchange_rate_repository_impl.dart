import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/models/currency.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../datasources/frankfurter_api_datasource.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  static const String _cacheKeyPrefix = 'exchange_rate_';
  static const String _cacheTimestampPrefix = 'exchange_rate_timestamp_';
  static const Duration _cacheValidDuration = Duration(hours: 1);

  final FrankfurterApiDataSource _dataSource;
  final SharedPreferences _prefs;

  ExchangeRateRepositoryImpl({
    required FrankfurterApiDataSource dataSource,
    required SharedPreferences preferences,
  }) : _dataSource = dataSource,
       _prefs = preferences;

  @override
  Future<ExchangeRate> getExchangeRate({
    required Currency baseCurrency,
    required Currency targetCurrency,
  }) async {
    try {
      final cachedRate = await getCachedExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );

      if (cachedRate != null && !cachedRate.isStale) {
        return cachedRate;
      }

      final response = await _dataSource.getLatestRates(
        baseCurrency: baseCurrency.code,
        targetCurrency: targetCurrency.code,
      );

      final exchangeRate = response.toExchangeRate(targetCurrency.code);
      if (exchangeRate == null) {
        throw const ExchangeRateException(
          'Failed to parse exchange rate response',
          ExchangeRateErrorType.invalidResponse,
        );
      }

      await cacheExchangeRate(exchangeRate);
      return exchangeRate;
    } catch (e) {
      final cachedRate = await getCachedExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );

      if (cachedRate != null) {
        return cachedRate;
      }

      rethrow;
    }
  }

  @override
  Future<Map<Currency, double>> getMultipleRates({
    required Currency baseCurrency,
    required List<Currency> targetCurrencies,
  }) async {
    final targetCurrencyCodes = targetCurrencies.map((c) => c.code).toList();

    try {
      final response = await _dataSource.getLatestRates(
        baseCurrency: baseCurrency.code,
        targetCurrencies: targetCurrencyCodes,
      );

      final exchangeRates = response.toExchangeRates();
      final result = <Currency, double>{};

      for (final rate in exchangeRates) {
        if (targetCurrencies.contains(rate.targetCurrency)) {
          result[rate.targetCurrency] = rate.rate;
          await cacheExchangeRate(rate);
        }
      }

      return result;
    } catch (e) {
      final cachedRates = <Currency, double>{};
      for (final targetCurrency in targetCurrencies) {
        final cachedRate = await getCachedExchangeRate(
          baseCurrency: baseCurrency,
          targetCurrency: targetCurrency,
        );
        if (cachedRate != null) {
          cachedRates[targetCurrency] = cachedRate.rate;
        }
      }

      if (cachedRates.isNotEmpty) {
        return cachedRates;
      }

      rethrow;
    }
  }

  @override
  Future<List<Currency>> getSupportedCurrencies() async {
    try {
      final currencyCodes = await _dataSource.getSupportedCurrencies();
      final supportedCurrencies = <Currency>[];

      for (final code in currencyCodes) {
        final currency = Currency.fromCode(code);
        if (currency != null) {
          supportedCurrencies.add(currency);
        }
      }

      return supportedCurrencies;
    } catch (e) {
      return Currency.supportedCurrencies;
    }
  }

  @override
  Future<ExchangeRate?> getCachedExchangeRate({
    required Currency baseCurrency,
    required Currency targetCurrency,
  }) async {
    try {
      final cacheKey = _getCacheKey(baseCurrency, targetCurrency);
      final timestampKey = _getTimestampKey(baseCurrency, targetCurrency);

      final cachedData = _prefs.getString(cacheKey);
      final timestamp = _prefs.getInt(timestampKey);

      if (cachedData == null || timestamp == null) {
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheValidDuration) {
        await _removeCachedRate(baseCurrency, targetCurrency);
        return null;
      }

      final Map<String, dynamic> data = json.decode(cachedData);
      return ExchangeRate.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheExchangeRate(ExchangeRate exchangeRate) async {
    try {
      final cacheKey = _getCacheKey(
        exchangeRate.baseCurrency,
        exchangeRate.targetCurrency,
      );
      final timestampKey = _getTimestampKey(
        exchangeRate.baseCurrency,
        exchangeRate.targetCurrency,
      );

      final data = json.encode(exchangeRate.toMap());
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _prefs.setString(cacheKey, data);
      await _prefs.setInt(timestampKey, timestamp);
    } catch (e) {
      // Cache failure should not affect main functionality
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = _prefs
          .getKeys()
          .where(
            (key) =>
                key.startsWith(_cacheKeyPrefix) ||
                key.startsWith(_cacheTimestampPrefix),
          )
          .toList();

      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      // Cache clearing failure should not affect main functionality
    }
  }

  Future<void> _removeCachedRate(
    Currency baseCurrency,
    Currency targetCurrency,
  ) async {
    try {
      final cacheKey = _getCacheKey(baseCurrency, targetCurrency);
      final timestampKey = _getTimestampKey(baseCurrency, targetCurrency);

      await _prefs.remove(cacheKey);
      await _prefs.remove(timestampKey);
    } catch (e) {
      // Ignore cache removal errors
    }
  }

  String _getCacheKey(Currency baseCurrency, Currency targetCurrency) {
    return '$_cacheKeyPrefix${baseCurrency.code}_${targetCurrency.code}';
  }

  String _getTimestampKey(Currency baseCurrency, Currency targetCurrency) {
    return '$_cacheTimestampPrefix${baseCurrency.code}_${targetCurrency.code}';
  }

  void dispose() {
    _dataSource.dispose();
  }
}
