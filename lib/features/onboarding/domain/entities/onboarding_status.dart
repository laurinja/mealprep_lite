import 'package:equatable/equatable.dart';

class OnboardingStatus extends Equatable {
  final bool isCompleted;
  final bool hasMarketingConsent;

  const OnboardingStatus({
    required this.isCompleted,
    required this.hasMarketingConsent,
  });

  @override
  List<Object?> get props => [isCompleted, hasMarketingConsent];
}