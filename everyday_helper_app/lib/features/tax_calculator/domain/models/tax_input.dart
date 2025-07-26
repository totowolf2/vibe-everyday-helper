import 'package:decimal/decimal.dart';

class TaxInput {
  static final Decimal _zero = Decimal.fromInt(0);
  static final Decimal _personalAllowanceAmount = Decimal.fromInt(60000);
  static final Decimal _childAllowanceAmount = Decimal.fromInt(30000);

  final Decimal annualIncome;
  final Decimal spouseAllowance;
  final int numberOfChildren;
  final Decimal insurancePremium;
  final Decimal retirementFund;
  final Decimal mortgageInterest;
  final Decimal educationDonation;
  final Decimal generalDonation;
  final Decimal socialSecurityContribution;
  final Decimal providentFund;
  final Decimal lifeInsurance;
  final Decimal healthInsurance;
  final Map<String, dynamic> additionalDeductions;

  TaxInput({
    Decimal? annualIncome,
    Decimal? spouseAllowance,
    this.numberOfChildren = 0,
    Decimal? insurancePremium,
    Decimal? retirementFund,
    Decimal? mortgageInterest,
    Decimal? educationDonation,
    Decimal? generalDonation,
    Decimal? socialSecurityContribution,
    Decimal? providentFund,
    Decimal? lifeInsurance,
    Decimal? healthInsurance,
    this.additionalDeductions = const {},
  }) : annualIncome = annualIncome ?? _zero,
       spouseAllowance = spouseAllowance ?? _zero,
       insurancePremium = insurancePremium ?? _zero,
       retirementFund = retirementFund ?? _zero,
       mortgageInterest = mortgageInterest ?? _zero,
       educationDonation = educationDonation ?? _zero,
       generalDonation = generalDonation ?? _zero,
       socialSecurityContribution = socialSecurityContribution ?? _zero,
       providentFund = providentFund ?? _zero,
       lifeInsurance = lifeInsurance ?? _zero,
       healthInsurance = healthInsurance ?? _zero;

  Decimal get personalAllowance => _personalAllowanceAmount;

  Decimal get childAllowance =>
      _childAllowanceAmount * Decimal.fromInt(numberOfChildren);

  Decimal get totalAllowances {
    return personalAllowance + spouseAllowance + childAllowance;
  }

  Decimal get totalDeductions {
    Decimal total =
        insurancePremium +
        retirementFund +
        mortgageInterest +
        educationDonation +
        generalDonation +
        socialSecurityContribution +
        providentFund +
        lifeInsurance +
        healthInsurance;

    for (final value in additionalDeductions.values) {
      if (value is Decimal) {
        total += value;
      } else if (value is num) {
        total += Decimal.parse(value.toString());
      }
    }

    return total;
  }

  Decimal get taxableIncome {
    final netIncome = annualIncome - totalAllowances - totalDeductions;
    return netIncome < _zero ? _zero : netIncome;
  }

  bool get isValid {
    return annualIncome > _zero &&
        spouseAllowance >= _zero &&
        numberOfChildren >= 0 &&
        insurancePremium >= _zero &&
        retirementFund >= _zero &&
        mortgageInterest >= _zero;
  }

  bool get hasSpouse => spouseAllowance > _zero;
  bool get hasChildren => numberOfChildren > 0;
  bool get hasDeductions => totalDeductions > _zero;

  TaxInput copyWith({
    Decimal? annualIncome,
    Decimal? spouseAllowance,
    int? numberOfChildren,
    Decimal? insurancePremium,
    Decimal? retirementFund,
    Decimal? mortgageInterest,
    Decimal? educationDonation,
    Decimal? generalDonation,
    Decimal? socialSecurityContribution,
    Decimal? providentFund,
    Decimal? lifeInsurance,
    Decimal? healthInsurance,
    Map<String, dynamic>? additionalDeductions,
  }) {
    return TaxInput(
      annualIncome: annualIncome ?? this.annualIncome,
      spouseAllowance: spouseAllowance ?? this.spouseAllowance,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      insurancePremium: insurancePremium ?? this.insurancePremium,
      retirementFund: retirementFund ?? this.retirementFund,
      mortgageInterest: mortgageInterest ?? this.mortgageInterest,
      educationDonation: educationDonation ?? this.educationDonation,
      generalDonation: generalDonation ?? this.generalDonation,
      socialSecurityContribution:
          socialSecurityContribution ?? this.socialSecurityContribution,
      providentFund: providentFund ?? this.providentFund,
      lifeInsurance: lifeInsurance ?? this.lifeInsurance,
      healthInsurance: healthInsurance ?? this.healthInsurance,
      additionalDeductions: additionalDeductions ?? this.additionalDeductions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'annualIncome': annualIncome.toString(),
      'spouseAllowance': spouseAllowance.toString(),
      'numberOfChildren': numberOfChildren,
      'insurancePremium': insurancePremium.toString(),
      'retirementFund': retirementFund.toString(),
      'mortgageInterest': mortgageInterest.toString(),
      'educationDonation': educationDonation.toString(),
      'generalDonation': generalDonation.toString(),
      'socialSecurityContribution': socialSecurityContribution.toString(),
      'providentFund': providentFund.toString(),
      'lifeInsurance': lifeInsurance.toString(),
      'healthInsurance': healthInsurance.toString(),
      'additionalDeductions': additionalDeductions,
    };
  }

  factory TaxInput.fromMap(Map<String, dynamic> map) {
    return TaxInput(
      annualIncome: Decimal.parse(map['annualIncome']?.toString() ?? '0'),
      spouseAllowance: Decimal.parse(map['spouseAllowance']?.toString() ?? '0'),
      numberOfChildren: map['numberOfChildren']?.toInt() ?? 0,
      insurancePremium: Decimal.parse(
        map['insurancePremium']?.toString() ?? '0',
      ),
      retirementFund: Decimal.parse(map['retirementFund']?.toString() ?? '0'),
      mortgageInterest: Decimal.parse(
        map['mortgageInterest']?.toString() ?? '0',
      ),
      educationDonation: Decimal.parse(
        map['educationDonation']?.toString() ?? '0',
      ),
      generalDonation: Decimal.parse(map['generalDonation']?.toString() ?? '0'),
      socialSecurityContribution: Decimal.parse(
        map['socialSecurityContribution']?.toString() ?? '0',
      ),
      providentFund: Decimal.parse(map['providentFund']?.toString() ?? '0'),
      lifeInsurance: Decimal.parse(map['lifeInsurance']?.toString() ?? '0'),
      healthInsurance: Decimal.parse(map['healthInsurance']?.toString() ?? '0'),
      additionalDeductions: Map<String, dynamic>.from(
        map['additionalDeductions'] ?? {},
      ),
    );
  }

  @override
  String toString() {
    return 'TaxInput(annualIncome: $annualIncome, taxableIncome: $taxableIncome, totalDeductions: $totalDeductions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxInput &&
        other.annualIncome == annualIncome &&
        other.spouseAllowance == spouseAllowance &&
        other.numberOfChildren == numberOfChildren &&
        other.insurancePremium == insurancePremium &&
        other.retirementFund == retirementFund &&
        other.mortgageInterest == mortgageInterest;
  }

  @override
  int get hashCode {
    return annualIncome.hashCode ^
        spouseAllowance.hashCode ^
        numberOfChildren.hashCode ^
        insurancePremium.hashCode ^
        retirementFund.hashCode ^
        mortgageInterest.hashCode;
  }
}
