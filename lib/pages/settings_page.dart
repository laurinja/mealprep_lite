import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Sair (Logout)'),
            subtitle: const Text('Sair deste dispositivo'),
            onTap: () async {
              final prefs = context.read<PrefsService>();
              
              await prefs.clearAll(); 
              
              if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Excluir Conta Permanentemente', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Apagar dados do banco e sair'),
            onTap: () => _handleDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    final email = context.read<PrefsService>().userEmail;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('EXCLUIR CONTA?'),
        content: const Text(
          'Esta ação é irreversível. Seus dados serão apagados dos nossos servidores.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            child: const Text('EXCLUIR TUDO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              
              try {
                await context.read<MealController>().deleteAccount(email);
                
                if (!context.mounted) return;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conta excluída com sucesso.')),
                );

                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}