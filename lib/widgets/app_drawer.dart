import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';

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

  ImageProvider? _getAvatarProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return NetworkImage(path);
    if (!kIsWeb) return FileImage(File(path));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDark(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
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
                ),
              ],
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: GestureDetector(
              onTap: onEditAvatarPressed,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: _getAvatarProvider(userPhotoPath),
                child: (userPhotoPath == null || userPhotoPath!.isEmpty)
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 40.0, color: theme.colorScheme.primary),
                      )
                    : null,
              ),
            ),
          ),
          
          // --- Itens do Menu ---
          
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Catálogo de Refeições'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/catalog');
            },
          ),
          
          // --- Toggle de Tema ---
          SwitchListTile(
            title: const Text('Modo Escuro'),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            value: isDark,
            onChanged: (val) {
               themeCtrl.toggleTheme(context);
            },
          ),
          
          const Divider(),
          
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