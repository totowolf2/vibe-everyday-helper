enum UnitCategory {
  length,
  weight,
  volume,
  temperature,
  area,
  energy,
  power,
  time,
  speed,
  pressure,
}

class Unit {
  final String id;
  final String name;
  final String symbol;
  final UnitCategory category;
  final double conversionFactor; // Factor to convert to base unit
  final double offset; // Offset for temperature conversions

  const Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.category,
    required this.conversionFactor,
    this.offset = 0.0,
  });

  String get displayName {
    return '$name ($symbol)';
  }

  bool get isBaseUnit {
    return conversionFactor == 1.0 && offset == 0.0;
  }

  Unit copyWith({
    String? id,
    String? name,
    String? symbol,
    UnitCategory? category,
    double? conversionFactor,
    double? offset,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      category: category ?? this.category,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'category': category.name,
      'conversionFactor': conversionFactor,
      'offset': offset,
    };
  }

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      category: UnitCategory.values.firstWhere(
        (cat) => cat.name == map['category'],
        orElse: () => UnitCategory.length,
      ),
      conversionFactor: (map['conversionFactor'] ?? 1.0).toDouble(),
      offset: (map['offset'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Unit(id: $id, name: $name, symbol: $symbol, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Unit &&
        other.id == id &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^ category.hashCode;
  }
}

class UnitConversion {
  final Unit fromUnit;
  final Unit toUnit;
  final double value;
  final double result;
  final DateTime timestamp;

  UnitConversion({
    required this.fromUnit,
    required this.toUnit,
    required this.value,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get conversionText {
    return '$value ${fromUnit.symbol} = $result ${toUnit.symbol}';
  }

  String get formattedResult {
    return result.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
  }

  UnitConversion copyWith({
    Unit? fromUnit,
    Unit? toUnit,
    double? value,
    double? result,
    DateTime? timestamp,
  }) {
    return UnitConversion(
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      value: value ?? this.value,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUnit': fromUnit.toMap(),
      'toUnit': toUnit.toMap(),
      'value': value,
      'result': result,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory UnitConversion.fromMap(Map<String, dynamic> map) {
    return UnitConversion(
      fromUnit: Unit.fromMap(map['fromUnit']),
      toUnit: Unit.fromMap(map['toUnit']),
      value: (map['value'] ?? 0.0).toDouble(),
      result: (map['result'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'UnitConversion(${fromUnit.symbol} → ${toUnit.symbol}: $value → $result)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitConversion &&
        other.fromUnit == fromUnit &&
        other.toUnit == toUnit &&
        other.value == value &&
        other.result == result;
  }

  @override
  int get hashCode {
    return fromUnit.hashCode ^
        toUnit.hashCode ^
        value.hashCode ^
        result.hashCode;
  }
}

class UnitRegistry {
  static const Map<UnitCategory, List<Unit>> _units = {
    UnitCategory.length: [
      Unit(id: 'mm', name: 'Millimeter', symbol: 'mm', category: UnitCategory.length, conversionFactor: 0.001),
      Unit(id: 'cm', name: 'Centimeter', symbol: 'cm', category: UnitCategory.length, conversionFactor: 0.01),
      Unit(id: 'm', name: 'Meter', symbol: 'm', category: UnitCategory.length, conversionFactor: 1.0),
      Unit(id: 'km', name: 'Kilometer', symbol: 'km', category: UnitCategory.length, conversionFactor: 1000.0),
      Unit(id: 'in', name: 'Inch', symbol: 'in', category: UnitCategory.length, conversionFactor: 0.0254),
      Unit(id: 'ft', name: 'Foot', symbol: 'ft', category: UnitCategory.length, conversionFactor: 0.3048),
      Unit(id: 'yd', name: 'Yard', symbol: 'yd', category: UnitCategory.length, conversionFactor: 0.9144),
      Unit(id: 'mi', name: 'Mile', symbol: 'mi', category: UnitCategory.length, conversionFactor: 1609.344),
    ],
    
    UnitCategory.weight: [
      Unit(id: 'mg', name: 'Milligram', symbol: 'mg', category: UnitCategory.weight, conversionFactor: 0.000001),
      Unit(id: 'g', name: 'Gram', symbol: 'g', category: UnitCategory.weight, conversionFactor: 0.001),
      Unit(id: 'kg', name: 'Kilogram', symbol: 'kg', category: UnitCategory.weight, conversionFactor: 1.0),
      Unit(id: 't', name: 'Metric Ton', symbol: 't', category: UnitCategory.weight, conversionFactor: 1000.0),
      Unit(id: 'oz', name: 'Ounce', symbol: 'oz', category: UnitCategory.weight, conversionFactor: 0.0283495),
      Unit(id: 'lb', name: 'Pound', symbol: 'lb', category: UnitCategory.weight, conversionFactor: 0.453592),
      Unit(id: 'st', name: 'Stone', symbol: 'st', category: UnitCategory.weight, conversionFactor: 6.35029),
    ],
    
    UnitCategory.volume: [
      Unit(id: 'ml', name: 'Milliliter', symbol: 'ml', category: UnitCategory.volume, conversionFactor: 0.001),
      Unit(id: 'l', name: 'Liter', symbol: 'l', category: UnitCategory.volume, conversionFactor: 1.0),
      Unit(id: 'cup', name: 'Cup', symbol: 'cup', category: UnitCategory.volume, conversionFactor: 0.236588),
      Unit(id: 'pt', name: 'Pint', symbol: 'pt', category: UnitCategory.volume, conversionFactor: 0.473176),
      Unit(id: 'qt', name: 'Quart', symbol: 'qt', category: UnitCategory.volume, conversionFactor: 0.946353),
      Unit(id: 'gal', name: 'Gallon', symbol: 'gal', category: UnitCategory.volume, conversionFactor: 3.78541),
      Unit(id: 'fl_oz', name: 'Fluid Ounce', symbol: 'fl oz', category: UnitCategory.volume, conversionFactor: 0.0295735),
    ],
    
    UnitCategory.temperature: [
      Unit(id: 'c', name: 'Celsius', symbol: '°C', category: UnitCategory.temperature, conversionFactor: 1.0),
      Unit(id: 'f', name: 'Fahrenheit', symbol: '°F', category: UnitCategory.temperature, conversionFactor: 5/9, offset: -32 * 5/9),
      Unit(id: 'k', name: 'Kelvin', symbol: 'K', category: UnitCategory.temperature, conversionFactor: 1.0, offset: -273.15),
    ],
    
    UnitCategory.area: [
      Unit(id: 'mm2', name: 'Square Millimeter', symbol: 'mm²', category: UnitCategory.area, conversionFactor: 0.000001),
      Unit(id: 'cm2', name: 'Square Centimeter', symbol: 'cm²', category: UnitCategory.area, conversionFactor: 0.0001),
      Unit(id: 'm2', name: 'Square Meter', symbol: 'm²', category: UnitCategory.area, conversionFactor: 1.0),
      Unit(id: 'km2', name: 'Square Kilometer', symbol: 'km²', category: UnitCategory.area, conversionFactor: 1000000.0),
      Unit(id: 'in2', name: 'Square Inch', symbol: 'in²', category: UnitCategory.area, conversionFactor: 0.00064516),
      Unit(id: 'ft2', name: 'Square Foot', symbol: 'ft²', category: UnitCategory.area, conversionFactor: 0.092903),
      Unit(id: 'ac', name: 'Acre', symbol: 'ac', category: UnitCategory.area, conversionFactor: 4046.86),
    ],
    
    UnitCategory.energy: [
      Unit(id: 'j', name: 'Joule', symbol: 'J', category: UnitCategory.energy, conversionFactor: 1.0),
      Unit(id: 'kj', name: 'Kilojoule', symbol: 'kJ', category: UnitCategory.energy, conversionFactor: 1000.0),
      Unit(id: 'cal', name: 'Calorie', symbol: 'cal', category: UnitCategory.energy, conversionFactor: 4.184),
      Unit(id: 'kcal', name: 'Kilocalorie', symbol: 'kcal', category: UnitCategory.energy, conversionFactor: 4184.0),
      Unit(id: 'wh', name: 'Watt Hour', symbol: 'Wh', category: UnitCategory.energy, conversionFactor: 3600.0),
      Unit(id: 'kwh', name: 'Kilowatt Hour', symbol: 'kWh', category: UnitCategory.energy, conversionFactor: 3600000.0),
      Unit(id: 'btu', name: 'British Thermal Unit', symbol: 'BTU', category: UnitCategory.energy, conversionFactor: 1055.06),
    ],
    
    UnitCategory.power: [
      Unit(id: 'w', name: 'Watt', symbol: 'W', category: UnitCategory.power, conversionFactor: 1.0),
      Unit(id: 'kw', name: 'Kilowatt', symbol: 'kW', category: UnitCategory.power, conversionFactor: 1000.0),
      Unit(id: 'mw', name: 'Megawatt', symbol: 'MW', category: UnitCategory.power, conversionFactor: 1000000.0),
      Unit(id: 'hp', name: 'Horsepower', symbol: 'hp', category: UnitCategory.power, conversionFactor: 745.7),
      Unit(id: 'ps', name: 'Metric Horsepower', symbol: 'PS', category: UnitCategory.power, conversionFactor: 735.5),
      Unit(id: 'btu_h', name: 'BTU per Hour', symbol: 'BTU/h', category: UnitCategory.power, conversionFactor: 0.293071),
    ],
    
    UnitCategory.time: [
      Unit(id: 'ns', name: 'Nanosecond', symbol: 'ns', category: UnitCategory.time, conversionFactor: 0.000000001),
      Unit(id: 'μs', name: 'Microsecond', symbol: 'μs', category: UnitCategory.time, conversionFactor: 0.000001),
      Unit(id: 'ms', name: 'Millisecond', symbol: 'ms', category: UnitCategory.time, conversionFactor: 0.001),
      Unit(id: 's', name: 'Second', symbol: 's', category: UnitCategory.time, conversionFactor: 1.0),
      Unit(id: 'min', name: 'Minute', symbol: 'min', category: UnitCategory.time, conversionFactor: 60.0),
      Unit(id: 'h', name: 'Hour', symbol: 'h', category: UnitCategory.time, conversionFactor: 3600.0),
      Unit(id: 'd', name: 'Day', symbol: 'd', category: UnitCategory.time, conversionFactor: 86400.0),
      Unit(id: 'week', name: 'Week', symbol: 'week', category: UnitCategory.time, conversionFactor: 604800.0),
      Unit(id: 'month', name: 'Month', symbol: 'month', category: UnitCategory.time, conversionFactor: 2629746.0),
      Unit(id: 'year', name: 'Year', symbol: 'year', category: UnitCategory.time, conversionFactor: 31556952.0),
    ],
    
    UnitCategory.speed: [
      Unit(id: 'm_s', name: 'Meter per Second', symbol: 'm/s', category: UnitCategory.speed, conversionFactor: 1.0),
      Unit(id: 'km_h', name: 'Kilometer per Hour', symbol: 'km/h', category: UnitCategory.speed, conversionFactor: 0.277778),
      Unit(id: 'mph', name: 'Mile per Hour', symbol: 'mph', category: UnitCategory.speed, conversionFactor: 0.44704),
      Unit(id: 'ft_s', name: 'Foot per Second', symbol: 'ft/s', category: UnitCategory.speed, conversionFactor: 0.3048),
      Unit(id: 'knot', name: 'Knot', symbol: 'kn', category: UnitCategory.speed, conversionFactor: 0.514444),
      Unit(id: 'mach', name: 'Mach', symbol: 'Ma', category: UnitCategory.speed, conversionFactor: 343.0),
    ],
    
    UnitCategory.pressure: [
      Unit(id: 'pa', name: 'Pascal', symbol: 'Pa', category: UnitCategory.pressure, conversionFactor: 1.0),
      Unit(id: 'kpa', name: 'Kilopascal', symbol: 'kPa', category: UnitCategory.pressure, conversionFactor: 1000.0),
      Unit(id: 'mpa', name: 'Megapascal', symbol: 'MPa', category: UnitCategory.pressure, conversionFactor: 1000000.0),
      Unit(id: 'bar', name: 'Bar', symbol: 'bar', category: UnitCategory.pressure, conversionFactor: 100000.0),
      Unit(id: 'atm', name: 'Atmosphere', symbol: 'atm', category: UnitCategory.pressure, conversionFactor: 101325.0),
      Unit(id: 'psi', name: 'Pound per Square Inch', symbol: 'psi', category: UnitCategory.pressure, conversionFactor: 6894.76),
      Unit(id: 'torr', name: 'Torr', symbol: 'Torr', category: UnitCategory.pressure, conversionFactor: 133.322),
      Unit(id: 'mmhg', name: 'Millimeter of Mercury', symbol: 'mmHg', category: UnitCategory.pressure, conversionFactor: 133.322),
    ],
  };

  static List<Unit> getUnitsForCategory(UnitCategory category) {
    return _units[category] ?? [];
  }

  static List<UnitCategory> get allCategories {
    return UnitCategory.values;
  }

  static Unit? getUnitById(String id) {
    for (final units in _units.values) {
      for (final unit in units) {
        if (unit.id == id) return unit;
      }
    }
    return null;
  }

  static String getCategoryDisplayName(UnitCategory category) {
    switch (category) {
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.weight:
        return 'Weight';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.temperature:
        return 'Temperature';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.energy:
        return 'Energy';
      case UnitCategory.power:
        return 'Power';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.speed:
        return 'Speed';
      case UnitCategory.pressure:
        return 'Pressure';
    }
  }

  static double convert(double value, Unit fromUnit, Unit toUnit) {
    if (fromUnit.category != toUnit.category) {
      throw ArgumentError('Cannot convert between different unit categories');
    }

    if (fromUnit == toUnit) {
      return value;
    }

    // Special handling for temperature
    if (fromUnit.category == UnitCategory.temperature) {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    // Standard conversion through base unit
    final baseValue = (value + fromUnit.offset) * fromUnit.conversionFactor;
    return (baseValue / toUnit.conversionFactor) - toUnit.offset;
  }

  static double _convertTemperature(double value, Unit fromUnit, Unit toUnit) {
    // Convert to Celsius first
    double celsius;
    switch (fromUnit.id) {
      case 'c':
        celsius = value;
        break;
      case 'f':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'k':
        celsius = value - 273.15;
        break;
      default:
        throw ArgumentError('Unknown temperature unit: ${fromUnit.id}');
    }

    // Convert from Celsius to target unit
    switch (toUnit.id) {
      case 'c':
        return celsius;
      case 'f':
        return celsius * 9 / 5 + 32;
      case 'k':
        return celsius + 273.15;
      default:
        throw ArgumentError('Unknown temperature unit: ${toUnit.id}');
    }
  }
}