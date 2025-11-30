import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

class AppDrawer extends StatelessWidget {
 
  final VoidCallback onEditAvatarPressed;

  const AppDrawer({
    super.key,
    required this.onEditAvatarPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    
    final prefs = context.watch<PrefsService>();
    final userPhotoPath = prefs.userPhotoPath;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.secondary),
            
            accountName: const Text(
              'Estudante MealPrep', 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            accountEmail: const Text('estudante@email.com'),
            currentAccountPicture: GestureDetector(
              onTap: onEditAvatarPressed,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: userPhotoPath != null 
                    ? FileImage(File(userPhotoPath)) 
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