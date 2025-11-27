import '../repositories/onboarding_repository.dart';

class SetMarketingConsent {
  final OnboardingRepository repository;

  SetMarketingConsent(this.repository);

  Future<void> call(bool value) async {
    await repository.setMarketingConsent(value);
  }
}
