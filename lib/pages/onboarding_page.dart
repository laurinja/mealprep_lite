import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/prefs_service.dart';
import '../widgets/policy_dialog.dart';
import '../core/constants/legal.dart'; // Verifique se o nome do arquivo é legal.dart ou legal_texts.dart

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Lista de páginas para facilitar a contagem dos dots
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inicializa as páginas aqui para poder usar o contexto
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Movemos a construção das páginas para cá para ter acesso seguro ao Theme e Context
    _pages = [
      _buildPage(
        title: 'Bem-vindo',
        subtitle: 'Planeje suas refeições facilmente.',
        icon: Icons.restaurant_menu,
      ),
      _buildPage(
        title: 'Privacidade',
        subtitle: 'Seus dados ficam no dispositivo. Leia nossa política.',
        icon: Icons.security,
        isPrivacy: true,
      ),
      _buildPage(
        title: 'Tudo Pronto!',
        subtitle: 'Comece a gerar seus cardápios agora.',
        icon: Icons.check_circle_outline,
      ),
    ];
  }

  void _finishOnboarding() async {
    await context.read<PrefsService>().setOnboardingCompleted(true);
    await context.read<PrefsService>().setMarketingConsent(true);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. O PageView (Conteúdo)
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: _pages,
          ),

          // 2. Os Dots (Indicadores)
          Positioned(
            bottom: 80, // Subiu um pouco para não colar no botão
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length, // Usa o tamanho real da lista
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8, // O ativo é mais largo
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300, // Cinza visível para inativos
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // 3. O Botão de Navegação
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _finishOnboarding
                  : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentPage == _pages.length - 1 ? 'Começar' : 'Próximo'),
            ),
          ),
          
          // Botão de Pular (Opcional, mas boa prática)
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 40,
              right: 20,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Pular'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isPrivacy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Se você tiver as imagens (onboarding1.png, etc), troque o Icon pelo Image.asset
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (isPrivacy) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.description),
              label: const Text('Ler Política de Privacidade'),
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => const PolicyDialog(
                    title: 'Política de Privacidade',
                    content: privacyPolicyContent,
                  ),
                );
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Termos aceitos!')),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}