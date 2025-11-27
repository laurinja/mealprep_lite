import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../user_profile/presentation/providers/user_profile_provider.dart';
import '../../../user_profile/presentation/widgets/app_drawer.dart';
import '../providers/meal_provider.dart';
import '../widgets/meal_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];
  final ImagePicker _picker = ImagePicker();

  Future<void> _onEditAvatarPressed() async {
    Navigator.pop(context);
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        final profileProvider = context.read<UserProfileProvider>();
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar Foto (Câmera)'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (profileProvider.userPhotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    profileProvider.removePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null || !mounted) return;

      final profileProvider = context.read<UserProfileProvider>();
      await profileProvider.savePhoto(pickedFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Falha ao selecionar imagem. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MealProvider, UserProfileProvider>(
      builder: (context, mealProvider, profileProvider, child) {
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            leadingWidth: 100,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: profileProvider.userPhotoPath != null
                        ? FileImage(File(profileProvider.userPhotoPath!))
                        : null,
                    backgroundColor: theme.colorScheme.background,
                    child: profileProvider.userPhotoPath == null
                        ? Text('A',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  iconSize: 24,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
              ],
            ),
            title: const Text('MealPrep Lite'),
            centerTitle: true,
            backgroundColor: theme.colorScheme.secondary,
            elevation: 0,
            actions: const [],
          ),
          endDrawer: AppDrawer(
            userPhotoPath: profileProvider.userPhotoPath,
            onEditAvatarPressed: _onEditAvatarPressed,
          ),
          body: _buildBody(mealProvider, theme),
        );
      },
    );
  }

  Widget _buildBody(MealProvider mealProvider, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSearchBar(theme),
        const SizedBox(height: 24),
        _buildPreferencesCard(mealProvider, theme),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Gerar Cardápio Semanal'),
            onPressed: () => mealProvider.generatePlan(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Plano Gerado',
          style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildMealList(mealProvider, theme),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar...',
        hintStyle:
            TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
        prefixIcon: Icon(Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.4)),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(MealProvider mealProvider, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rule, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '1. Escolha suas Preferências',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione as tags para filtrar seu plano semanal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: _todasPreferencias.map((preferencia) {
                final isSelected =
                    mealProvider.selectedPreferences.contains(preferencia);
                return FilterChip(
                  label: Text(preferencia),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    mealProvider.togglePreference(preferencia);
                  },
                  selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                  checkmarkColor: theme.colorScheme.secondary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealList(MealProvider mealProvider, ThemeData theme) {
    if (mealProvider.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 60,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum plano gerado',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Text(
                'Gere um plano usando suas preferências acima.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mealProvider.meals.length,
      itemBuilder: (context, index) {
        return MealCard(meal: mealProvider.meals[index]);
      },
    );
  }
}