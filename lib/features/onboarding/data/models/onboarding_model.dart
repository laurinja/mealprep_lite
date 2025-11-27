class OnboardingModel {
  final bool? marketingConsent;

  const OnboardingModel({
    required this.marketingConsent,
  });

  factory OnboardingModel.fromMap(Map<String, dynamic> map) {
    return OnboardingModel(
      marketingConsent: map['marketingConsent'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'marketingConsent': marketingConsent,
    };
  }

  OnboardingModel copyWith({
    bool? marketingConsent,
  }) {
    return OnboardingModel(
      marketingConsent: marketingConsent ?? this.marketingConsent,
    );
  }
}

