import '../repositories/onboarding_repository.dart';

class GetMarketingConsent {
  final OnboardingRepository repository;

  GetMarketingConsent(this.repository);

  Future<bool?> call() async {
    return await repository.getMarketingConsent();
  }
}
