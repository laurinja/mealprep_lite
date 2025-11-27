import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/onboarding_status.dart';
import '../repositories/onboarding_repository.dart';

class CheckOnboardingCompleted implements UseCase<OnboardingStatus, NoParams> {
  final OnboardingRepository repository;

  CheckOnboardingCompleted(this.repository);

  @override
  Future<Either<Failure, OnboardingStatus>> call(NoParams params) async {
    return await repository.getOnboardingStatus();
  }
}