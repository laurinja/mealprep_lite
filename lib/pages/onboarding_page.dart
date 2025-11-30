import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealprep_lite/services/prefs_service.dart';
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
  bool _termsAccepted = false;

  void _finishOnboarding() async {
    if (!_termsAccepted) return;

    final prefs = context.read<PrefsService>();
    await prefs.setOnboardingCompleted(true);
    await prefs.setMarketingConsent(true);
    
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.ease
    );
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.ease
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> pages = [
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
      _buildLastPage(theme),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: pages,
          ),
          
          // Indicador de Páginas (Dots)
          Positioned(
            bottom: 100,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? theme.colorScheme.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Botões de Navegação (Voltar e Próximo)
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão VOLTAR (Só aparece se não for a primeira página)
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text('Voltar', style: TextStyle(fontSize: 16)),
                  )
                else
                  const SizedBox(width: 60), // Espaço vazio para manter alinhamento

                // Botão PRÓXIMO / COMEÇAR
                ElevatedButton(
                  onPressed: (_currentPage == pages.length - 1 && !_termsAccepted)
                      ? null 
                      : () {
                          if (_currentPage == pages.length - 1) {
                            _finishOnboarding();
                          } else {
                            _nextPage();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    _currentPage == pages.length - 1 ? 'Continuar' : 'Próximo',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String subtitle, required IconData icon, bool isPrivacy = false}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          if (isPrivacy) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.description),
              label: const Text('Ler Política'),
              onPressed: () => showDialog(context: context, builder: (_) => const PolicyDialog(title: 'Política', content: privacyPolicyContent)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLastPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 120, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          const Text('Tudo Pronto!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Para continuar, aceite nossos termos.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
          CheckboxListTile(
            value: _termsAccepted,
            title: const Text('Li e aceito os Termos de Uso e Política de Privacidade.'),
            activeColor: theme.colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _termsAccepted = val ?? false),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}