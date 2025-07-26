import 'dart:math' as math;

class StatisticalDataSet {
  final List<double> _values;
  final String? label;
  final DateTime timestamp;

  StatisticalDataSet({
    required List<double> values,
    this.label,
    DateTime? timestamp,
  }) : _values = List.from(values),
       timestamp = timestamp ?? DateTime.now();

  List<double> get values => List.unmodifiable(_values);
  int get count => _values.length;
  bool get isEmpty => _values.isEmpty;
  bool get isNotEmpty => _values.isNotEmpty;

  double get sum {
    if (isEmpty) return 0.0;
    return _values.reduce((a, b) => a + b);
  }

  double get mean {
    if (isEmpty) return 0.0;
    return sum / count;
  }

  double get median {
    if (isEmpty) return 0.0;

    final sortedValues = List<double>.from(_values)..sort();
    final middle = count ~/ 2;

    if (count % 2 == 0) {
      return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
    } else {
      return sortedValues[middle];
    }
  }

  List<double> get mode {
    if (isEmpty) return [];

    final frequencyMap = <double, int>{};
    for (final value in _values) {
      frequencyMap[value] = (frequencyMap[value] ?? 0) + 1;
    }

    final maxFrequency = frequencyMap.values.reduce(math.max);

    return frequencyMap.entries
        .where((entry) => entry.value == maxFrequency)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  double get range {
    if (isEmpty) return 0.0;
    return maximum - minimum;
  }

  double get minimum {
    if (isEmpty) return 0.0;
    return _values.reduce(math.min);
  }

  double get maximum {
    if (isEmpty) return 0.0;
    return _values.reduce(math.max);
  }

  double get variance {
    if (count < 2) return 0.0;

    final meanValue = mean;
    final sumOfSquaredDifferences = _values
        .map((value) => math.pow(value - meanValue, 2))
        .reduce((a, b) => a + b);

    return sumOfSquaredDifferences / (count - 1); // Sample variance
  }

  double get populationVariance {
    if (isEmpty) return 0.0;

    final meanValue = mean;
    final sumOfSquaredDifferences = _values
        .map((value) => math.pow(value - meanValue, 2))
        .reduce((a, b) => a + b);

    return sumOfSquaredDifferences / count; // Population variance
  }

  double get standardDeviation {
    return math.sqrt(variance);
  }

  double get populationStandardDeviation {
    return math.sqrt(populationVariance);
  }

  double get standardError {
    if (isEmpty) return 0.0;
    return standardDeviation / math.sqrt(count);
  }

  double get coefficientOfVariation {
    if (mean == 0) return 0.0;
    return (standardDeviation / mean) * 100;
  }

  double get skewness {
    if (count < 3) return 0.0;

    final meanValue = mean;
    final stdDev = standardDeviation;

    if (stdDev == 0) return 0.0;

    final sumOfCubedDifferences = _values
        .map((value) => math.pow((value - meanValue) / stdDev, 3))
        .reduce((a, b) => a + b);

    return (count / ((count - 1) * (count - 2))) * sumOfCubedDifferences;
  }

  double get kurtosis {
    if (count < 4) return 0.0;

    final meanValue = mean;
    final stdDev = standardDeviation;

    if (stdDev == 0) return 0.0;

    final sumOfFourthPowers = _values
        .map((value) => math.pow((value - meanValue) / stdDev, 4))
        .reduce((a, b) => a + b);

    final n = count;
    return ((n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3))) * sumOfFourthPowers -
        (3 * math.pow(n - 1, 2)) / ((n - 2) * (n - 3));
  }

  double percentile(double p) {
    if (isEmpty || p < 0 || p > 100) return 0.0;

    final sortedValues = List<double>.from(_values)..sort();
    final index = (p / 100) * (count - 1);

    if (index == index.floor()) {
      return sortedValues[index.floor()];
    } else {
      final lower = sortedValues[index.floor()];
      final upper = sortedValues[index.ceil()];
      final fraction = index - index.floor();
      return lower + (upper - lower) * fraction;
    }
  }

  double get q1 => percentile(25);
  double get q3 => percentile(75);
  double get iqr => q3 - q1;

  List<double> get outliers {
    if (count < 4) return [];

    final q1Value = q1;
    final q3Value = q3;
    final iqrValue = iqr;

    final lowerBound = q1Value - 1.5 * iqrValue;
    final upperBound = q3Value + 1.5 * iqrValue;

    return _values
        .where((value) => value < lowerBound || value > upperBound)
        .toList();
  }

  String get summary {
    if (isEmpty) return 'No data available';

    return '''
Count: $count
Mean: ${mean.toStringAsFixed(2)}
Median: ${median.toStringAsFixed(2)}
Mode: ${mode.map((m) => m.toStringAsFixed(2)).join(', ')}
Range: ${range.toStringAsFixed(2)}
Standard Deviation: ${standardDeviation.toStringAsFixed(2)}
Variance: ${variance.toStringAsFixed(2)}
''';
  }

  StatisticalDataSet copyWith({
    List<double>? values,
    String? label,
    DateTime? timestamp,
  }) {
    return StatisticalDataSet(
      values: values ?? _values,
      label: label ?? this.label,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'values': _values,
      'label': label,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory StatisticalDataSet.fromMap(Map<String, dynamic> map) {
    return StatisticalDataSet(
      values: List<double>.from(map['values'] ?? []),
      label: map['label'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  factory StatisticalDataSet.fromString(String input, {String? label}) {
    final cleanInput = input.trim();
    if (cleanInput.isEmpty) {
      return StatisticalDataSet(values: [], label: label);
    }

    final values = <double>[];
    final parts = cleanInput.split(RegExp(r'[,\s]+'));

    for (final part in parts) {
      final trimmedPart = part.trim();
      if (trimmedPart.isNotEmpty) {
        final value = double.tryParse(trimmedPart);
        if (value != null) {
          values.add(value);
        }
      }
    }

    return StatisticalDataSet(values: values, label: label);
  }

  @override
  String toString() {
    return 'StatisticalDataSet(count: $count, mean: ${mean.toStringAsFixed(2)}, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatisticalDataSet &&
        listEquals(_values, other._values) &&
        other.label == label;
  }

  @override
  int get hashCode {
    return _values.hashCode ^ label.hashCode;
  }
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

class StatisticalResult {
  final StatisticalDataSet dataSet;
  final Map<String, double> measures;
  final DateTime calculatedAt;

  StatisticalResult({
    required this.dataSet,
    required this.measures,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  factory StatisticalResult.fromDataSet(StatisticalDataSet dataSet) {
    final measures = <String, double>{
      'count': dataSet.count.toDouble(),
      'sum': dataSet.sum,
      'mean': dataSet.mean,
      'median': dataSet.median,
      'minimum': dataSet.minimum,
      'maximum': dataSet.maximum,
      'range': dataSet.range,
      'variance': dataSet.variance,
      'standardDeviation': dataSet.standardDeviation,
      'standardError': dataSet.standardError,
      'coefficientOfVariation': dataSet.coefficientOfVariation,
      'q1': dataSet.q1,
      'q3': dataSet.q3,
      'iqr': dataSet.iqr,
      'skewness': dataSet.skewness,
      'kurtosis': dataSet.kurtosis,
    };

    return StatisticalResult(dataSet: dataSet, measures: measures);
  }

  String getFormattedMeasure(String key, {int decimals = 2}) {
    final value = measures[key];
    if (value == null) return 'N/A';
    return value.toStringAsFixed(decimals);
  }

  Map<String, dynamic> toMap() {
    return {
      'dataSet': dataSet.toMap(),
      'measures': measures,
      'calculatedAt': calculatedAt.millisecondsSinceEpoch,
    };
  }

  factory StatisticalResult.fromMap(Map<String, dynamic> map) {
    return StatisticalResult(
      dataSet: StatisticalDataSet.fromMap(map['dataSet']),
      measures: Map<String, double>.from(map['measures'] ?? {}),
      calculatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['calculatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
