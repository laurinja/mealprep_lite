import 'dart:io';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? userPhotoPath;
  final VoidCallback onEditAvatarPressed;

  const AppDrawer({
    super.key,
    required this.userPhotoPath,
    required this.onEditAvatarPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.secondary),
            accountName: const Text('Usuário'),
            accountEmail: const Text('MealPrep Lite'),
            currentAccountPicture: GestureDetector(
              onTap: onEditAvatarPressed,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userPhotoPath != null ? FileImage(File(userPhotoPath!)) : null,
                child: userPhotoPath == null
                    ? Icon(Icons.person, color: theme.colorScheme.primary)
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