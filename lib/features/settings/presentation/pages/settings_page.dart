import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/presentation/widgets/policy_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // -----------------------
          //     PRIVACIDADE
          // -----------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Privacidade",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SwitchListTile(
            title: const Text("Permitir notificações de marketing"),
            subtitle: const Text(
              "Você pode ativar ou desativar quando quiser.",
            ),
            value: onboardingState.marketingConsent,
            onChanged: (value) {
              onboardingNotifier.updateMarketingConsent(value);
            },
          ),

          ListTile(
            title: const Text("Política de Privacidade"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const PolicyDialog(
                  title: "Política de Privacidade",
                  description:
                      "Aqui você insere o texto completo da sua política. "
                      "Pode deixar longo mesmo, o dialog é rolável.",
                ),
              );
            },
          ),

          ListTile(
            title: const Text("Termos de Uso"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const PolicyDialog(
                  title: "Termos de Uso",
                  description:
                      "Aqui você coloca seus termos do serviço. "
                      "Se quiser posso gerar um texto padrão para app.",
                ),
              );
            },
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Sobre",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: const Text("Versão"),
            subtitle: const Text("1.0.0"),
            leading: const Icon(Icons.info_outline),
          ),

          ListTile(
            title: const Text("Contato / Suporte"),
            leading: const Icon(Icons.mail_outline),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Função de contato ainda não configurada."),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
