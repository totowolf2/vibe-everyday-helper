import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_response.dart';

class FrankfurterApiDataSource {
  static const String _baseUrl = 'https://api.frankfurter.dev/v1';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _httpClient;

  FrankfurterApiDataSource({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Future<ExchangeRateResponse> getLatestRates({
    required String baseCurrency,
    String? targetCurrency,
    List<String>? targetCurrencies,
  }) async {
    try {
      final uri = _buildLatestRatesUri(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        targetCurrencies: targetCurrencies,
      );

      final response = await _httpClient.get(uri).timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ExchangeRateException(
        'Network error: Please check your internet connection',
        ExchangeRateErrorType.networkError,
      );
    } on HttpException {
      throw const ExchangeRateException(
        'HTTP error: Unable to connect to exchange rate service',
        ExchangeRateErrorType.networkError,
      );
    } on FormatException {
      throw const ExchangeRateException(
        'Invalid response format from exchange rate service',
        ExchangeRateErrorType.invalidResponse,
      );
    } catch (e) {
      throw ExchangeRateException(
        'Unexpected error: ${e.toString()}',
        ExchangeRateErrorType.unknown,
      );
    }
  }

  Future<List<String>> getSupportedCurrencies() async {
    try {
      final uri = Uri.parse('$_baseUrl/currencies');
      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.keys.toList();
      } else {
        throw ExchangeRateException(
          'Failed to fetch supported currencies: ${response.statusCode}',
          ExchangeRateErrorType.apiError,
        );
      }
    } on SocketException {
      throw const ExchangeRateException(
        'Network error: Please check your internet connection',
        ExchangeRateErrorType.networkError,
      );
    } catch (e) {
      throw ExchangeRateException(
        'Failed to fetch supported currencies: ${e.toString()}',
        ExchangeRateErrorType.unknown,
      );
    }
  }

  Uri _buildLatestRatesUri({
    required String baseCurrency,
    String? targetCurrency,
    List<String>? targetCurrencies,
  }) {
    final queryParams = <String, String>{'base': baseCurrency.toUpperCase()};

    if (targetCurrency != null) {
      queryParams['symbols'] = targetCurrency.toUpperCase();
    } else if (targetCurrencies != null && targetCurrencies.isNotEmpty) {
      queryParams['symbols'] = targetCurrencies
          .map((c) => c.toUpperCase())
          .join(',');
    }

    return Uri.parse('$_baseUrl/latest').replace(queryParameters: queryParams);
  }

  ExchangeRateResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        return ExchangeRateResponse.fromJson(data);
      } on FormatException {
        throw const ExchangeRateException(
          'Invalid JSON response from exchange rate service',
          ExchangeRateErrorType.invalidResponse,
        );
      }
    } else if (response.statusCode == 404) {
      throw const ExchangeRateException(
        'Currency not found or not supported',
        ExchangeRateErrorType.currencyNotSupported,
      );
    } else if (response.statusCode >= 500) {
      throw const ExchangeRateException(
        'Exchange rate service is temporarily unavailable',
        ExchangeRateErrorType.serverError,
      );
    } else {
      throw ExchangeRateException(
        'API error: ${response.statusCode} - ${response.reasonPhrase}',
        ExchangeRateErrorType.apiError,
      );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

enum ExchangeRateErrorType {
  networkError,
  serverError,
  apiError,
  invalidResponse,
  currencyNotSupported,
  rateLimitExceeded,
  unknown,
}

class ExchangeRateException implements Exception {
  final String message;
  final ExchangeRateErrorType type;

  const ExchangeRateException(this.message, this.type);

  @override
  String toString() => 'ExchangeRateException: $message (type: $type)';

  bool get isNetworkError => type == ExchangeRateErrorType.networkError;
  bool get isServerError => type == ExchangeRateErrorType.serverError;
  bool get isApiError => type == ExchangeRateErrorType.apiError;
  bool get isInvalidResponse => type == ExchangeRateErrorType.invalidResponse;
  bool get isCurrencyNotSupported =>
      type == ExchangeRateErrorType.currencyNotSupported;
  bool get isRateLimitExceeded =>
      type == ExchangeRateErrorType.rateLimitExceeded;
  bool get isUnknown => type == ExchangeRateErrorType.unknown;

  String get userFriendlyMessage {
    switch (type) {
      case ExchangeRateErrorType.networkError:
        return 'No internet connection. Please check your network and try again.';
      case ExchangeRateErrorType.serverError:
        return 'Exchange rate service is temporarily unavailable. Please try again later.';
      case ExchangeRateErrorType.apiError:
        return 'Unable to fetch exchange rates. Please try again.';
      case ExchangeRateErrorType.invalidResponse:
        return 'Invalid response from exchange rate service. Please try again.';
      case ExchangeRateErrorType.currencyNotSupported:
        return 'One or more currencies are not supported.';
      case ExchangeRateErrorType.rateLimitExceeded:
        return 'Too many requests. Please wait a moment and try again.';
      case ExchangeRateErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
