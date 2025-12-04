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

  void _goToLogin() async {
    final prefs = context.read<PrefsService>();
    await prefs.setOnboardingCompleted(true);
    await prefs.setMarketingConsent(true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _previousPage() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> pages = [
      _buildWelcomePage(theme),
      _buildHowItWorksPage(theme),
      _buildPolicyPage(theme),
      _buildReadyPage(theme),
    ];

    bool isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            physics: (_currentPage == 2 && !_termsAccepted)
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            children: pages,
          ),
          if (!isLastPage)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
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
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          if (!isLastPage)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Voltar', style: TextStyle(fontSize: 16)),
                    )
                  else
                    const SizedBox(width: 60),
                  ElevatedButton(
                    onPressed: (_currentPage == 2 && !_termsAccepted)
                        ? null
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Próximo', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Card(
        elevation: 8,
        shadowColor: theme.colorScheme.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant_menu,
                    size: 80, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 32),
              Text(
                'MealPrep Lite',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Planeje suas refeições da semana em segundos e economize tempo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Como Funciona',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildStepCard(theme, '1', 'Defina suas preferências', Icons.tune),
          const SizedBox(height: 16),
          _buildStepCard(theme, '2', 'Gere o cardápio automático', Icons.auto_awesome),
          const SizedBox(height: 16),
          _buildStepCard(theme, '3', 'Veja a lista de ingredientes', Icons.list_alt),
        ],
      ),
    );
  }

  Widget _buildStepCard(ThemeData theme, String number, String text, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          child: Text(number, style: const TextStyle(color: Colors.white)),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(icon, color: Colors.grey),
      ),
    );
  }

  Widget _buildPolicyPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 100, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          const Text('Termos e Privacidade',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text(
            'Para sua segurança, leia e aceite nossos termos antes de prosseguir.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.description),
            label: const Text('Ler Documentos'),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (_) => const PolicyDialog(
                  title: 'Termos',
                  content: privacyPolicyContent + '\n\n' + termsOfUseContent,
                ),
              );
              if (result == true) {
                setState(() {
                  _termsAccepted = true;
                });
              }
            },
          ),
          const SizedBox(height: 40),
          CheckboxListTile(
            value: _termsAccepted,
            title: const Text(
                'Li e concordo com os Termos de Uso e Política de Privacidade.'),
            activeColor: theme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _termsAccepted = val ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage(ThemeData theme) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 100, color: Colors.green),
          ),
          const SizedBox(height: 40),
          const Text('Tudo Pronto!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text(
            'Agora é só criar sua conta ou fazer login para começar a planejar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text('IR PARA LOGIN'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}