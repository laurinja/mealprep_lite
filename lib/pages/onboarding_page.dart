import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';
import '../widgets/policy_dialog.dart';
import '../core/constants/legal.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    await context.read<PrefsService>().setOnboardingCompleted(true);
    await context.read<PrefsService>().setMarketingConsent(true);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildPage('Bem-vindo', 'Planeje suas refeições facilmente.', Icons.restaurant),
              _buildPage('Privacidade', 'Seus dados ficam no dispositivo.', Icons.lock, isPrivacy: true),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: ElevatedButton(
              onPressed: _currentPage == 1 ? _finishOnboarding : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
              child: Text(_currentPage == 1 ? 'Começar' : 'Próximo'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage(String title, String subtitle, IconData icon, {bool isPrivacy = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(subtitle, textAlign: TextAlign.center),
        ),
        if (isPrivacy)
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const PolicyDialog(title: 'Privacidade', content: privacyPolicyContent),
            ),
            child: const Text('Ler Política de Privacidade'),
          )
      ],
    );
  }
}