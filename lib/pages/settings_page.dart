import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../widgets/policy_dialog.dart';
import '../constants/legal_texts.dart';

class SettingsPage extends StatelessWidget {
  final PrefsService prefs;
  const SettingsPage({super.key, required this.prefs});

  // --- Métodos de Ação ---

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PolicyDialog(
        title: 'Política de Privacidade',
        content: privacyPolicyContent,
      ),
    );
  }

  void _showTermsOfUse(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PolicyDialog(
        title: 'Termos de Uso',
        content: termsOfUseContent,
      ),
    );
  }

  void _revokeConsent(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revogar Consentimento'),
        content: const Text('Você tem certeza que deseja revogar o seu consentimento? Você será levado à tela de aceite novamente.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Revogar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await prefs.setMarketingConsent(false);
              
              Navigator.of(context).pushReplacementNamed(
                '/onboarding',
                arguments: {
                  'startAtPage': 2,
                  'initialConsent': false,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _refazerOnboarding(BuildContext context) async {
    // A SettingsPage é aberta com Navigator.pushNamed, então usamos pop.
    Navigator.of(context).pop(); 
    await prefs.setOnboardingCompleted(false);
    bool currentConsent = prefs.getMarketingConsent();
    Navigator.of(context).pushReplacementNamed(
      '/onboarding',
      arguments: {
        'startAtPage': 0,
        'initialConsent': currentConsent,
      },
    );
  }

  void _limparDados(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar Aplicativo'),
        content: const Text('CUIDADO! Isso apagará todos os seus dados salvos (foto, consentimento e status do onboarding) e reiniciará o app. Deseja continuar?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Resetar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Fecha o dialog
              await prefs.clearAll();
              
              // Remove todas as rotas e volta para a Splash Page
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  // --- Widgets de Construção ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    // --- CORREÇÃO AQUI ---
    // Definimos o 'theme' aqui dentro, usando o 'context' do método
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary, // Agora 'theme' existe
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasConsent = prefs.getMarketingConsent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'Privacidade e Dados'),
          ListTile(
            leading: Icon(
              Icons.check_circle_outline,
              color: hasConsent ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            title: const Text('Status do Consentimento'),
            subtitle: Text(hasConsent ? 'Consentimento ativo' : 'Consentimento revogado'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidade'),
            subtitle: const Text('Revisar como seus dados são tratados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(context),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Termos de Uso'),
            subtitle: const Text('Revisar termos e condições'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTermsOfUse(context),
          ),
          ListTile(
            leading: const Icon(Icons.highlight_off, color: Colors.red),
            title: const Text('Revogar Consentimento', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Retirar permissão para uso de dados'),
            onTap: () => _revokeConsent(context),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSectionTitle(context, 'Informações'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o MealPrep Lite'),
            subtitle: const Text('Versão 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MealPrep Lite',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 {{Seu Nome Aqui}}',
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          _buildSectionTitle(context, 'Debug'),
          ListTile(
            leading: const Icon(Icons.replay_outlined),
            title: const Text('Refazer Onboarding'),
            subtitle: const Text('Reiniciar o tutorial (sem limpar dados)'),
            onTap: () => _refazerOnboarding(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Limpar Dados', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Reset completo do app (Cuidado!)'),
            onTap: () => _limparDados(context),
          ),
        ],
      ),
    );
  }
}