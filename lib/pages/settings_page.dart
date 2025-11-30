import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          // A opção "Refazer Onboarding" foi removida daqui.
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Revogar Consentimento e Conta', 
              style: TextStyle(color: Colors.red)
            ),
            subtitle: const Text('Apagar todos os dados e sair'),
            onTap: () => _handleRevocation(context),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _handleRevocation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text(
          'Isso apagará seu perfil, preferências e histórico. Você voltará para a tela inicial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            child: const Text('REVOGAR TUDO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              
              final prefs = context.read<PrefsService>();
              await prefs.clearAll(); 
              
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dados apagados. Reiniciando...'),
                  duration: Duration(seconds: 2),
                ),
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
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