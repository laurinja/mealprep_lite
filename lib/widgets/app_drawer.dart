import 'dart:io';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? userPhotoPath;
  final String userName;
  final String userEmail;
  final VoidCallback onEditAvatarPressed;
  final VoidCallback onEditProfilePressed; // Novo callback para editar nome/email

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

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.secondary),
            accountName: Row(
              children: [
                Expanded(child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: onEditProfilePressed,
                  tooltip: 'Editar Nome',
                )
              ],
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: GestureDetector(
              onTap: onEditAvatarPressed,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userPhotoPath != null && userPhotoPath!.isNotEmpty
                    ? FileImage(File(userPhotoPath!))
                    : null,
                child: userPhotoPath == null
                    ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                    : null,
              ),
            ),
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