import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PrefsService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Refazer Onboarding'),
            subtitle: const Text('Visualizar a introdução novamente'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Revogar Consentimento', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Apagar dados e retirar permissões'),
            onTap: () => _confirmRevocation(context, prefs),
          ),
        ],
      ),
    );
  }

  void _confirmRevocation(BuildContext context, PrefsService prefs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text('Isso removerá seu acesso ao app até que você aceite os termos novamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            child: const Text('Revogar', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(ctx); 
              
              final bool wasOnboardingDone = prefs.onboardingCompleted;
              
              await prefs.clearAll(); 
              
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Consentimento revogado e dados limpos.'),
                  action: SnackBarAction(
                    label: 'DESFAZER',
                    onPressed: () async {
                      await prefs.setOnboardingCompleted(wasOnboardingDone);
                      await prefs.setMarketingConsent(true); 
                    },
                  ),
                  duration: const Duration(seconds: 4),
                ),
              ).closed.then((reason) {
                if (reason != SnackBarClosedReason.action && context.mounted) {
                   Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}