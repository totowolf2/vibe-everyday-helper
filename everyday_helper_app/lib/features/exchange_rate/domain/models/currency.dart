class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  static const Currency usd = Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
  );

  static const Currency thb = Currency(
    code: 'THB',
    name: 'Thai Baht',
    symbol: '฿',
  );

  static const Currency eur = Currency(code: 'EUR', name: 'Euro', symbol: '€');

  static const Currency gbp = Currency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
  );

  static const Currency cny = Currency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
  );

  static const Currency aud = Currency(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
  );

  static const Currency cad = Currency(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
  );

  static const Currency chf = Currency(
    code: 'CHF',
    name: 'Swiss Franc',
    symbol: 'CHF',
  );

  static const Currency sgd = Currency(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: 'S\$',
  );

  static const List<Currency> supportedCurrencies = [
    usd,
    thb,
    eur,
    gbp,
    jpy,
    cny,
    aud,
    cad,
    chf,
    sgd,
  ];

  static Currency? fromCode(String code) {
    try {
      return supportedCurrencies.firstWhere(
        (currency) => currency.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  bool get isValid => code.isNotEmpty && name.isNotEmpty && symbol.isNotEmpty;

  String get displayName => '$name ($code)';

  Currency copyWith({String? code, String? name, String? symbol}) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
    );
  }

  Map<String, dynamic> toMap() {
    return {'code': code, 'name': name, 'symbol': symbol};
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Currency(code: $code, name: $name, symbol: $symbol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency &&
        other.code == code &&
        other.name == name &&
        other.symbol == symbol;
  }

  @override
  int get hashCode {
    return code.hashCode ^ name.hashCode ^ symbol.hashCode;
  }
}
