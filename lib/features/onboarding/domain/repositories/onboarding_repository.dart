import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/onboarding_status.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus();
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, bool>> getMarketingConsent();
  Future<Either<Failure, void>> setMarketingConsent(bool value);
  Future<Either<Failure, void>> clearAllData();
}