import 'dart:io';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  // Dados do usuário que vêm da HomePage
  final String? userPhotoPath;
  final String userName;
  final String userEmail;
  
  // Funções para abrir os diálogos de edição
  final VoidCallback onEditAvatarPressed;
  final VoidCallback onEditProfilePressed; 

  const AppDrawer({
    super.key,
    required this.onEditAvatarPressed,
    required this.onEditProfilePressed,
    this.userPhotoPath,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Verifica se a imagem existe no caminho salvo
    ImageProvider? imageProvider;
    if (userPhotoPath != null && userPhotoPath!.isNotEmpty) {
      final file = File(userPhotoPath!);
      if (file.existsSync()) {
        imageProvider = FileImage(file);
      }
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.secondary),
            // Linha do Nome com botão de editar
            accountName: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    userName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                  tooltip: 'Editar Perfil',
                  onPressed: () {
                    Navigator.pop(context); // Fecha o drawer antes de abrir o diálogo
                    onEditProfilePressed();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            accountEmail: Text(userEmail),
            // Avatar clicável
            currentAccountPicture: GestureDetector(
              onTap: onEditAvatarPressed,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                // Se tiver imagem válida, usa. Senão, null.
                backgroundImage: imageProvider,
                // Se NÃO tiver imagem, mostra o ícone.
                child: imageProvider == null
                    ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                    : null,
              ),
            ),
          ),
          // Botão de Configurações/Revogar
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}