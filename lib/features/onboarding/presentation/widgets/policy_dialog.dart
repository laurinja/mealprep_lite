import 'package:flutter/material.dart';

class PolicyDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? htmlContent; 
  final VoidCallback? onAccept;

  const PolicyDialog({
    super.key,
    required this.title,
    required this.description,
    this.htmlContent,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Conteúdo scrollável
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Fechar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onAccept != null) onAccept!();
                    },
                    child: const Text("Aceitar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
