import 'package:flutter/material.dart';

class MealActionsDialog extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const MealActionsDialog({
    super.key,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Opções da Refeição'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: colorScheme.primary),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context); 
              onEdit(); 
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: colorScheme.error),
            title: Text(
              'Remover',
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context); 
              onRemove(); 
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}