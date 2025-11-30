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
  bool _termsAccepted = false; // Controla o checkbox

  // Função para ir para o Login (Chamada na última tela)
  void _goToLogin() async {
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
      // 0: Bem-vindo
      _buildPage(
        title: 'Bem-vindo',
        subtitle: 'O MealPrep Lite ajuda você a planejar suas refeições da semana em segundos.',
        icon: Icons.restaurant_menu,
      ),
      // 1: Como Funciona
      _buildPage(
        title: 'Como Funciona',
        subtitle: '1. Defina preferências.\n2. Gere o cardápio.\n3. Veja os ingredientes.',
        icon: Icons.lightbulb_outline,
      ),
      // 2: Políticas (Obrigatório aceitar aqui)
      _buildPolicyPage(theme),
      // 3: Tudo Pronto
      _buildReadyPage(theme), 
    ];

    // Verifica se é a última página
    bool isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            // Bloqueia swipe na tela de termos se não aceitou
            physics: (_currentPage == 2 && !_termsAccepted) 
                ? const NeverScrollableScrollPhysics() 
                : const BouncingScrollPhysics(),
            children: pages,
          ),
          
          // --- INDICADORES DE PÁGINA (BOLINHAS) ---
          // AQUI ESTÁ A MUDANÇA: Só exibe se NÃO for a última página
          if (!isLastPage)
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
                    // Esconde visualmente a bolinha da última página se ela for renderizada na lista,
                    // ou apenas deixa transparente para não quebrar a lógica de índices.
                    // Mas como estamos escondendo o bloco todo com o if(!isLastPage), isso é seguro.
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? theme.colorScheme.primary : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // --- BARRA DE NAVEGAÇÃO INFERIOR (Voltar / Próximo) ---
          // Também só aparece se não for a última página
          if (!isLastPage)
            Positioned(
              bottom: 30, left: 20, right: 20,
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
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

  Widget _buildPage({required String title, required String subtitle, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPolicyPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, size: 100, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          const Text('Termos e Privacidade', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                  content: privacyPolicyContent + '\n\n' + termsOfUseContent
                )
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
            title: const Text('Li e concordo com os Termos de Uso e Política de Privacidade.'),
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
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 32),
          const Text('Tudo Pronto!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text(
            'Agora é só criar sua conta ou fazer login para começar a planejar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 60),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('IR PARA LOGIN'),
            ),
          ),
        ],
      ),
    );
  }
}