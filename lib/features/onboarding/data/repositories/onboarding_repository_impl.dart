import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl(this.localDataSource);

  @override
  Future<bool?> getMarketingConsent() async {
    return await localDataSource.getMarketingConsent();
  }

  @override
  Future<void> setMarketingConsent(bool value) async {
    await localDataSource.setMarketingConsent(value);
  }
}
