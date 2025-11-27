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
    _OnboardItem(
      title: "Bem-vindo ao MealPrep Lite",
      description: "Organize suas refeições com facilidade.",
      icon: Icons.fastfood,
    ),
    _OnboardItem(
      title: "Receitas práticas",
      description: "Acompanhe receitas pensadas para sua rotina.",
      icon: Icons.book,
    ),
    _OnboardItem(
      title: "Planejamento rápido",
      description: "Monte cardápios semanais em minutos.",
      icon: Icons.calendar_today,
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // dots
          Row(
            children: List.generate(
              onboardingPages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: _currentPage == i ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              if (isLast) {
                // finaliza onboarding
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

class _OnboardItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Colors.blue),
          const SizedBox(height: 32),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
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
