import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_marketing_consent.dart';
import '../../domain/usecases/set_marketing_consent.dart';
import '../../domain/usecases/get_onboarding_completed.dart';
import '../../domain/usecases/set_onboarding_completed.dart';

class OnboardingState {
  final bool isLoading;
  final bool onboardingCompleted;
  final bool marketingConsent;

  OnboardingState({
    required this.isLoading,
    required this.onboardingCompleted,
    required this.marketingConsent,
  });

  OnboardingState copyWith({
    bool? isLoading,
    bool? onboardingCompleted,
    bool? marketingConsent,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      onboardingCompleted:
          onboardingCompleted ?? this.onboardingCompleted,
      marketingConsent: marketingConsent ?? this.marketingConsent,
    );
  }

  factory OnboardingState.initial() => OnboardingState(
        isLoading: true,
        onboardingCompleted: false,
        marketingConsent: false,
      );
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final GetMarketingConsent getMarketingConsent;
  final SetMarketingConsent setMarketingConsent;
  final GetOnboardingCompleted getOnboardingCompleted;
  final SetOnboardingCompleted setOnboardingCompleted;

  OnboardingNotifier({
    required this.getMarketingConsent,
    required this.setMarketingConsent,
    required this.getOnboardingCompleted,
    required this.setOnboardingCompleted,
  }) : super(OnboardingState.initial());

  Future<void> loadOnboardingStatus() async {
    state = state.copyWith(isLoading: true);

    final completed = await getOnboardingCompleted.call();
    final consent = await getMarketingConsent.call();

    state = state.copyWith(
      isLoading: false,
      onboardingCompleted: completed,
      marketingConsent: consent,
    );
  }

  Future<void> updateMarketingConsent(bool value) async {
    await setMarketingConsent.call(value);
    state = state.copyWith(marketingConsent: value);
  }

  Future<void> completeOnboarding() async {
    await setOnboardingCompleted.call();
    state = state.copyWith(onboardingCompleted: true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) {
    return OnboardingNotifier(
      getMarketingConsent: ref.read(getMarketingConsentProvider),
      setMarketingConsent: ref.read(setMarketingConsentProvider),
      getOnboardingCompleted: ref.read(getOnboardingCompletedProvider),
      setOnboardingCompleted: ref.read(setOnboardingCompletedProvider),
    )..loadOnboardingStatus();
  },
);
