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
            title: const Text('Resetar Onboarding'),
            onTap: () async {
              await prefs.setOnboardingCompleted(false);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
          ListTile(
            title: const Text('Limpar Dados'),
            subtitle: const Text('Apaga fotos e consentimentos'),
            onTap: () async {
              await prefs.clearAll();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}