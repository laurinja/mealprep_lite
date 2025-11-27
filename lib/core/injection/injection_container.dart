import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/usecases/get_marketing_consent.dart';
import '../../features/onboarding/domain/usecases/set_marketing_consent.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_completed.dart';
import '../../features/onboarding/domain/usecases/set_onboarding_completed.dart';

/// ------------------------------
///  SHARED PREFERENCES
/// ------------------------------
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("SharedPreferences não carregado.");
});

/// ------------------------------
///  DATASOURCE
/// ------------------------------
final onboardingLocalDataSourceProvider =
    Provider<OnboardingLocalDataSource>((ref) {
  final prefs = ref.read(sharedPrefsProvider);
  return OnboardingLocalDataSourceImpl(prefs);
});

/// ------------------------------
///  REPOSITORY
/// ------------------------------
final onboardingRepositoryProvider = Provider((ref) {
  final ds = ref.read(onboardingLocalDataSourceProvider);
  return OnboardingRepositoryImpl(ds);
});

/// ------------------------------
///  USE CASES
/// ------------------------------
final getMarketingConsentProvider = Provider((ref) {
  final repo = ref.read(onboardingRepositoryProvider);
  return GetMarketingConsent(repo);
});

final setMarketingConsentProvider = Provider((ref) {
  final repo = ref.read(onboardingRepositoryProvider);
  return SetMarketingConsent(repo);
});

final getOnboardingCompletedProvider = Provider((ref) {
  final repo = ref.read(onboardingRepositoryProvider);
  return GetOnboardingCompleted(repo);
});

final setOnboardingCompletedProvider = Provider((ref) {
  final repo = ref.read(onboardingRepositoryProvider);
  return SetOnboardingCompleted(repo);
});
