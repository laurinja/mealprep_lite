import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart'; // Certifique-se de ter este import

class PolicyDialog extends StatelessWidget {
  final String title;
  final String content;

  const PolicyDialog({super.key, required this.title, required this.content});

  Future<void> _launchUrl(String? url) async {
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: MarkdownBody(
            data: content,
            onTapLink: (text, href, title) => _launchUrl(href), // Habilita o clique
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Li e Concordo'),
        ),
      ],
    );
  }
}