import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/refeicao.dart';
import '../services/meal_service.dart';
import '../services/prefs_service.dart';
import '../widgets/app_drawer.dart'; // Importa o Drawer refatorado

class HomePage extends StatefulWidget {
  final PrefsService prefs;
  const HomePage({super.key, required this.prefs});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _preferenciasSelecionadas = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];

  String? _userPhotoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userPhotoPath = widget.prefs.getUserPhotoPath();
  }

  // --- Métodos de Ação do Avatar ---

  Future<void> _onEditAvatarPressed() async {
    Navigator.pop(context); // Fecha o drawer
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
            if (_userPhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final File? compressedFile = await _compressImage(pickedFile);
      if (compressedFile == null) return;

      final String savedPath = await _saveImageLocally(compressedFile);

      await widget.prefs.setUserPhotoPath(savedPath);
      setState(() {
        _userPhotoPath = savedPath;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao selecionar imagem. Tente novamente.')),
        );
      }
    }
  }

  Future<File?> _compressImage(XFile file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 512,
      minHeight: 512,
      quality: 80,
      autoCorrectionAngle: true,
      keepExif: false,
    );

    if (result == null) return null;
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'temp_compressed.jpg'));
    await tempFile.writeAsBytes(result);
    return tempFile;
  }

  Future<String> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String newPath = p.join(directory.path, 'avatar.jpg');
    
    await imageFile.copy(newPath);
    return newPath;
  }

  Future<void> _removeImage() async {
    if (_userPhotoPath != null) {
      final file = File(_userPhotoPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    await widget.prefs.removeUserPhotoPath();
    setState(() {
      _userPhotoPath = null;
    });
  }

  // --- Método de Lógica (MealPrep) ---
  void _gerarPlano() {
    context.read<MealService>().gerarPlano(_preferenciasSelecionadas);
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    return Consumer<MealService>(
      builder: (context, mealService, child) {
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.background, // Fundo Creme
          appBar: AppBar(
            // Ícones da Esquerda (Avatar e Configurações)
            leadingWidth: 100, // Aumenta o espaço para os dois ícones
            leading: Builder(
              builder: (context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar no AppBar
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: _userPhotoPath != null
                            ? FileImage(File(_userPhotoPath!))
                            : null,
                        backgroundColor: theme.colorScheme.background, // Fundo Creme
                        child: _userPhotoPath == null
                            ? Text(
                                'A', 
                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold) // Letra Verde
                              )
                            : null,
                      ),
                    ),
                    // Ícone de Configurações
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      iconSize: 24,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                    ),
                  ],
                );
              }
            ),
            title: const Text('MealPrep Lite'),
            centerTitle: true,
            backgroundColor: theme.colorScheme.secondary, // Marrom
            elevation: 0,
            // Ações da Direita (O ícone do Drawer aparecerá aqui)
            // Deixamos a lista de 'actions' vazia para que o Scaffold
            // mostre automaticamente o botão do 'endDrawer'
            actions: const [],
          ),
          endDrawer: AppDrawer(
            userPhotoPath: _userPhotoPath,
            onEditAvatarPressed: _onEditAvatarPressed,
          ),
          body: _buildBody(mealService, theme),
        );
      },
    );
  }

  // --- Widgets do Corpo ---

  Widget _buildBody(MealService mealService, ThemeData theme) {
    final planoGerado = mealService.planoSemanal;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSearchBar(theme),
        const SizedBox(height: 24),
        // Os 3 cards de resumo foram removidos
        _buildPreferencesCard(theme),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Gerar Cardápio Semanal'),
            onPressed: _gerarPlano,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary, // Verde
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Plano Gerado',
          style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRefeicaoList(planoGerado, theme),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar...',
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // Lógica de busca (pode ser implementada depois)
      },
    );
  }

  // _buildSummaryCards e _buildSummaryCard foram removidos

  Widget _buildPreferencesCard(ThemeData theme) {
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
                Icon(Icons.rule, color: theme.colorScheme.primary), // Ícone Verde
                const SizedBox(width: 8),
                Text(
                  '1. Escolha suas Preferências',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary, // Marrom
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
                final isSelected = _preferenciasSelecionadas.contains(preferencia);
                return FilterChip(
                  label: Text(preferencia),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _preferenciasSelecionadas.add(preferencia);
                      } else {
                        _preferenciasSelecionadas.remove(preferencia);
                      }
                    });
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

  Widget _buildRefeicaoList(List<Refeicao> planoGerado, ThemeData theme) {
    if (planoGerado.isEmpty) {
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
      itemCount: planoGerado.length,
      itemBuilder: (context, index) {
        return _buildRefeicaoCard(planoGerado[index], theme);
      },
    );
  }

  Widget _buildRefeicaoCard(Refeicao refeicao, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              refeicao.tipo.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              refeicao.nome,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            if (refeicao.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: refeicao.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                              color: theme.colorScheme.primary.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          side: BorderSide.none,
                        ))
                    .toList(),
              )
            ]
          ],
        ),
      ),
    );
  }
}