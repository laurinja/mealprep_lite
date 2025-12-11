import 'dart:io';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? userPhotoPath;
  final String userName;
  final String userEmail;
  
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
                    Navigator.pop(context);
                    onEditProfilePressed();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: GestureDetector(
              onTap: onEditAvatarPressed,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                    : null,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Catálogo de Refeições'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/catalog'); 
            },
          ),

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