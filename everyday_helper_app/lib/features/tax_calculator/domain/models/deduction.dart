import 'package:decimal/decimal.dart';

enum DeductionType {
  insurance,
  retirementFund,
  mortgageInterest,
  educationDonation,
  generalDonation,
  socialSecurity,
  providentFund,
  lifeInsurance,
  healthInsurance,
  parentCare,
  disabilitySupport,
  custom,
}

class Deduction {
  static final Decimal _zero = Decimal.fromInt(0);

  final String id;
  final DeductionType type;
  final String name;
  final String description;
  final Decimal amount;
  final Decimal maxLimit;
  final bool isPercentageBased;
  final Decimal percentageLimit;
  final String category;
  final List<String> requirements;
  final String helpText;
  final bool isEnabled;

  Deduction({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    Decimal? amount,
    Decimal? maxLimit,
    this.isPercentageBased = false,
    Decimal? percentageLimit,
    this.category = 'General',
    this.requirements = const [],
    this.helpText = '',
    this.isEnabled = true,
  }) : amount = amount ?? _zero,
       maxLimit = maxLimit ?? _zero,
       percentageLimit = percentageLimit ?? _zero;

  static List<Deduction> get standardThaiDeductions {
    return [
      Deduction(
        id: 'insurance_premium',
        type: DeductionType.insurance,
        name: 'Insurance Premium',
        description: 'Life/health insurance premiums paid',
        maxLimit: Decimal.fromInt(100000),
        category: 'Insurance',
        helpText:
            'Maximum 100,000 THB per year for life and health insurance premiums.',
        requirements: [
          'Insurance policy documents',
          'Premium payment receipts',
        ],
      ),
      Deduction(
        id: 'retirement_fund',
        type: DeductionType.retirementFund,
        name: 'Retirement Mutual Fund (RMF)',
        description: 'Contributions to retirement mutual funds',
        maxLimit: Decimal.fromInt(500000),
        isPercentageBased: true,
        percentageLimit: Decimal.fromInt(30),
        category: 'Retirement',
        helpText:
            'Maximum 500,000 THB or 30% of annual income, whichever is lower.',
        requirements: ['RMF investment certificates', 'Bank transfer receipts'],
      ),
      Deduction(
        id: 'mortgage_interest',
        type: DeductionType.mortgageInterest,
        name: 'Home Mortgage Interest',
        description: 'Interest paid on home mortgage loans',
        maxLimit: Decimal.fromInt(100000),
        category: 'Housing',
        helpText:
            'Maximum 100,000 THB per year for mortgage interest on primary residence.',
        requirements: [
          'Mortgage agreement',
          'Interest payment receipts from bank',
        ],
      ),
      Deduction(
        id: 'education_donation',
        type: DeductionType.educationDonation,
        name: 'Education Donation',
        description: 'Donations to educational institutions',
        maxLimit: _zero,
        isPercentageBased: true,
        percentageLimit: Decimal.fromInt(10),
        category: 'Donations',
        helpText:
            'Up to 10% of net income for donations to qualified educational institutions.',
        requirements: [
          'Official donation receipts',
          'Institution qualification certificate',
        ],
      ),
      Deduction(
        id: 'general_donation',
        type: DeductionType.generalDonation,
        name: 'General Charity Donation',
        description: 'Donations to approved charitable organizations',
        maxLimit: _zero,
        isPercentageBased: true,
        percentageLimit: Decimal.fromInt(10),
        category: 'Donations',
        helpText:
            'Up to 10% of net income for donations to approved charitable organizations.',
        requirements: [
          'Official donation receipts',
          'Organization approval certificate',
        ],
      ),
      Deduction(
        id: 'social_security',
        type: DeductionType.socialSecurity,
        name: 'Social Security Contribution',
        description: 'Employee social security contributions',
        maxLimit: Decimal.fromInt(9000),
        category: 'Social Security',
        helpText: 'Maximum 9,000 THB per year (750 THB per month).',
        requirements: [
          'Payroll deduction statements',
          'Social security payment receipts',
        ],
      ),
      Deduction(
        id: 'provident_fund',
        type: DeductionType.providentFund,
        name: 'Provident Fund',
        description: 'Employee contributions to company provident fund',
        maxLimit: Decimal.fromInt(500000),
        isPercentageBased: true,
        percentageLimit: Decimal.fromInt(15),
        category: 'Retirement',
        helpText:
            'Maximum 500,000 THB or 15% of annual salary, whichever is lower.',
        requirements: [
          'Provident fund statements',
          'Employer contribution certificates',
        ],
      ),
      Deduction(
        id: 'parent_care',
        type: DeductionType.parentCare,
        name: 'Parent Care Allowance',
        description: 'Allowance for caring for parents over 60',
        maxLimit: Decimal.fromInt(30000),
        category: 'Family',
        helpText:
            'Maximum 30,000 THB per parent (60,000 THB total for both parents).',
        requirements: ['Parent age verification', 'Care expense receipts'],
      ),
    ];
  }

  Decimal get appliedAmount {
    if (!isEnabled || amount <= _zero) {
      return _zero;
    }

    if (maxLimit > _zero) {
      return amount < maxLimit ? amount : maxLimit;
    }

    return amount;
  }

  Decimal calculateActualDeduction(Decimal income) {
    if (!isEnabled || amount <= _zero) {
      return _zero;
    }

    if (isPercentageBased && percentageLimit > _zero) {
      final rate = percentageLimit.toDouble() / 100.0;
      final percentageAmount = income * Decimal.parse(rate.toString());

      if (maxLimit > _zero) {
        final maxAllowed = amount < maxLimit ? amount : maxLimit;
        return maxAllowed < percentageAmount ? maxAllowed : percentageAmount;
      } else {
        return amount < percentageAmount ? amount : percentageAmount;
      }
    }

    return appliedAmount;
  }

  bool get isValid {
    return name.isNotEmpty &&
        amount >= _zero &&
        maxLimit >= _zero &&
        percentageLimit >= _zero;
  }

  bool get hasLimit => maxLimit > _zero;
  bool get hasPercentageLimit => isPercentageBased && percentageLimit > _zero;
  bool get requiresDocumentation => requirements.isNotEmpty;

  String get formattedAmount => _formatCurrency(amount);
  String get formattedMaxLimit =>
      hasLimit ? _formatCurrency(maxLimit) : 'No limit';
  String get formattedPercentageLimit =>
      hasPercentageLimit ? '${percentageLimit.toStringAsFixed(0)}%' : 'N/A';

  String get limitDescription {
    if (isPercentageBased && hasLimit) {
      return 'Max $formattedMaxLimit THB or $formattedPercentageLimit of income';
    } else if (hasLimit) {
      return 'Max $formattedMaxLimit THB';
    } else if (isPercentageBased) {
      return 'Max $formattedPercentageLimit of income';
    }
    return 'No limit';
  }

  String get typeDisplay {
    switch (type) {
      case DeductionType.insurance:
        return 'Insurance';
      case DeductionType.retirementFund:
        return 'Retirement Fund';
      case DeductionType.mortgageInterest:
        return 'Mortgage Interest';
      case DeductionType.educationDonation:
        return 'Education Donation';
      case DeductionType.generalDonation:
        return 'General Donation';
      case DeductionType.socialSecurity:
        return 'Social Security';
      case DeductionType.providentFund:
        return 'Provident Fund';
      case DeductionType.lifeInsurance:
        return 'Life Insurance';
      case DeductionType.healthInsurance:
        return 'Health Insurance';
      case DeductionType.parentCare:
        return 'Parent Care';
      case DeductionType.disabilitySupport:
        return 'Disability Support';
      case DeductionType.custom:
        return 'Custom';
    }
  }

  String _formatCurrency(Decimal amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Deduction copyWith({
    String? id,
    DeductionType? type,
    String? name,
    String? description,
    Decimal? amount,
    Decimal? maxLimit,
    bool? isPercentageBased,
    Decimal? percentageLimit,
    String? category,
    List<String>? requirements,
    String? helpText,
    bool? isEnabled,
  }) {
    return Deduction(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      maxLimit: maxLimit ?? this.maxLimit,
      isPercentageBased: isPercentageBased ?? this.isPercentageBased,
      percentageLimit: percentageLimit ?? this.percentageLimit,
      category: category ?? this.category,
      requirements: requirements ?? this.requirements,
      helpText: helpText ?? this.helpText,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'amount': amount.toString(),
      'maxLimit': maxLimit.toString(),
      'isPercentageBased': isPercentageBased,
      'percentageLimit': percentageLimit.toString(),
      'category': category,
      'requirements': requirements,
      'helpText': helpText,
      'isEnabled': isEnabled,
    };
  }

  factory Deduction.fromMap(Map<String, dynamic> map) {
    return Deduction(
      id: map['id']?.toString() ?? '',
      type: DeductionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => DeductionType.custom,
      ),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      amount: Decimal.parse(map['amount']?.toString() ?? '0'),
      maxLimit: Decimal.parse(map['maxLimit']?.toString() ?? '0'),
      isPercentageBased: map['isPercentageBased'] ?? false,
      percentageLimit: Decimal.parse(map['percentageLimit']?.toString() ?? '0'),
      category: map['category']?.toString() ?? 'General',
      requirements: List<String>.from(map['requirements'] ?? []),
      helpText: map['helpText']?.toString() ?? '',
      isEnabled: map['isEnabled'] ?? true,
    );
  }

  @override
  String toString() {
    return 'Deduction(name: $name, amount: $formattedAmount THB, limit: $limitDescription)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Deduction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ amount.hashCode;
  }
}
