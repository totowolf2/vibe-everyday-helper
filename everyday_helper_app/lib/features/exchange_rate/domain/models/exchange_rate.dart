import 'currency.dart';

class ExchangeRate {
  final Currency baseCurrency;
  final Currency targetCurrency;
  final double rate;
  final DateTime lastUpdated;
  final String? source;

  const ExchangeRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.lastUpdated,
    this.source,
  });

  bool get isValid =>
      rate > 0 && baseCurrency.isValid && targetCurrency.isValid;

  String get displayRate =>
      '1 ${baseCurrency.code} = ${rate.toStringAsFixed(4)} ${targetCurrency.code}';

  String get formattedRate => rate.toStringAsFixed(4);

  double convertAmount(double amount) {
    if (!isValid || amount < 0) return 0.0;
    return amount * rate;
  }

  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    return difference.inHours > 24;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  ExchangeRate copyWith({
    Currency? baseCurrency,
    Currency? targetCurrency,
    double? rate,
    DateTime? lastUpdated,
    String? source,
  }) {
    return ExchangeRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      source: source ?? this.source,
    );
  }

  ExchangeRate reversed() {
    if (rate <= 0) {
      throw ArgumentError(
        'Cannot reverse exchange rate with zero or negative rate',
      );
    }

    return ExchangeRate(
      baseCurrency: targetCurrency,
      targetCurrency: baseCurrency,
      rate: 1.0 / rate,
      lastUpdated: lastUpdated,
      source: source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseCurrency': baseCurrency.toMap(),
      'targetCurrency': targetCurrency.toMap(),
      'rate': rate,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'source': source,
    };
  }

  factory ExchangeRate.fromMap(Map<String, dynamic> map) {
    return ExchangeRate(
      baseCurrency: Currency.fromMap(map['baseCurrency'] ?? {}),
      targetCurrency: Currency.fromMap(map['targetCurrency'] ?? {}),
      rate: (map['rate'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      source: map['source'],
    );
  }

  @override
  String toString() {
    return 'ExchangeRate(baseCurrency: $baseCurrency, targetCurrency: $targetCurrency, rate: $rate, lastUpdated: $lastUpdated, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExchangeRate &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency &&
        other.rate == rate &&
        other.lastUpdated == lastUpdated &&
        other.source == source;
  }

  @override
  int get hashCode {
    return baseCurrency.hashCode ^
        targetCurrency.hashCode ^
        rate.hashCode ^
        lastUpdated.hashCode ^
        source.hashCode;
  }
}
