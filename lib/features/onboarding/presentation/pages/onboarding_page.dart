import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/set_marketing_consent.dart';
import '../../domain/usecases/set_onboarding_completed.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final onboardingPages = const [
    _OnboardImageItem(
      title: "Bem-vindo ao MealPrep Lite",
      description: "Organize suas refeições com facilidade.",
      assetPath: 'assets/images/onboarding1.png',
    ),
    _OnboardImageItem(
      title: "Planejamento Rápido",
      description: "Selecione suas tags e gere um cardápio em segundos.",
      assetPath: 'assets/images/onboarding2.png',
    ),
    _OnboardImageItem(
      title: "Sua Privacidade em Primeiro Lugar",
      description:
          "Seus dados ficam apenas no seu dispositivo. Não coletamos ou compartilhamos informações pessoais. (RNF-2)",
      assetPath: 'assets/images/onboarding4.png',
    ),
    _OnboardImageItem(
      title: "Tudo Pronto!",
      description: "Toque em 'Começar' e acesse o planejador de refeições.",
      assetPath: 'assets/images/onboarding4.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => onboardingPages[i],
              ),
            ),
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final isLast = _currentPage == onboardingPages.length - 1;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              onboardingPages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: _currentPage == i ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? theme.colorScheme.primary
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isLast) {
                await ref.read(setMarketingConsentProvider).call(true);
                await ref.read(setOnboardingCompletedProvider).call();

                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            child: Text(isLast ? "Começar" : "Próximo"),
          )
        ],
      ),
    );
  }
}

class _OnboardImageItem extends StatelessWidget {
  final String title;
  final String description;
  final String assetPath;

  const _OnboardImageItem({
    required this.title,
    required this.description,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath,
            height: 200,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
