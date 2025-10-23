import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart'; // NOVO: Seletor de imagem
import 'package:flutter_image_compress/flutter_image_compress.dart'; // NOVO: Compressor
import 'package:path_provider/path_provider.dart'; // NOVO: Local de salvamento
import 'package:path/path.dart' as p; // NOVO: Para manipular caminhos

import '../models/refeicao.dart';
import '../services/meal_service.dart';
import '../services/prefs_service.dart';

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
  final ImagePicker _picker = ImagePicker(); // NOVO: Instância do ImagePicker

  @override
  void initState() {
    super.initState();
    _userPhotoPath = widget.prefs.getUserPhotoPath();
  }

  // --- NOVO: Lógica de seleção e salvamento de imagem ---

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

      // 1. Comprimir (conforme PRD) [cite: 22]
      final File? compressedFile = await _compressImage(pickedFile);
      if (compressedFile == null) return;

      // 2. Salvar Localmente 
      final String savedPath = await _saveImageLocally(compressedFile);

      // 3. Atualizar Prefs e Estado [cite: 48, 113]
      await widget.prefs.setUserPhotoPath(savedPath);
      setState(() {
        _userPhotoPath = savedPath;
      });
    } catch (e) {
      // (PRD: Falha ao abrir câmera/galeria) [cite: 78]
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao selecionar imagem. Tente novamente.')),
        );
      }
    }
  }

  Future<File?> _compressImage(XFile file) async {
    // (PRD: Compressão 512x512, Q80, remove EXIF) [cite: 22, 54]
    final result = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 512,
      minHeight: 512,
      quality: 80,
      autoCorrectionAngle: true,
      keepExif: false, // (PRD: Remoção de EXIF sensíveis) [cite: 22, 54]
    );

    if (result == null) return null;
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'temp_compressed.jpg'));
    await tempFile.writeAsBytes(result);
    return tempFile;
  }

  Future<String> _saveImageLocally(File imageFile) async {
    // (PRD: Diretório app - Documentos) 
    final directory = await getApplicationDocumentsDirectory();
    // (PRD: Nome: avatar.jpg) 
    final String newPath = p.join(directory.path, 'avatar.jpg');
    
    await imageFile.copy(newPath);
    return newPath;
  }

  Future<void> _removeImage() async {
    // (PRD: "Remover foto" apaga arquivo local e limpa chave) [cite: 59]
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

  // --- Métodos de Lógica (MealPrep) ---
  @override
  Widget build(BuildContext context) {
    final mealService = context.watch<MealService>();
    final planoGerado = mealService.planoSemanal;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('MealPrep Lite'),
      ),
      endDrawer: _buildDrawer(theme),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            '1. Escolha suas preferências',
            style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Gerar Cardápio Semanal'),
              onPressed: () {
                context
                    .read<MealService>()
                    .gerarPlano(_preferenciasSelecionadas);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (planoGerado.isNotEmpty) ...[
            Text(
              '2. Seu plano base para a semana!',
              style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...planoGerado
                .map((refeicao) => _buildRefeicaoCard(refeicao, theme))
                .toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildRefeicaoCard(Refeicao refeicao, ThemeData theme) {
    // (Este método não foi alterado)
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

  // --- _buildDrawer (sem alteração da Etapa 2) ---
  Drawer _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary, // Marrom
            ),
            accountName: const Text(
              'Aluna MealPrep',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: const Text('meu.email@exemplo.com'),
            currentAccountPicture: Semantics(
              label: 'Foto do perfil',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 36.0,
                    backgroundImage: _userPhotoPath != null
                        ? FileImage(File(_userPhotoPath!))
                        : null,
                    backgroundColor: theme.colorScheme.background, // Fundo Creme
                    child: _userPhotoPath == null
                        ? Text(
                            'A', 
                            style: TextStyle(
                              fontSize: 40.0,
                              color: theme.colorScheme.primary, // Letra Verde
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.background, // Fundo Creme
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(Icons.edit,
                            color: theme.colorScheme.primary), // Ícone Verde
                        onPressed: _onEditAvatarPressed, // AGORA ESTA FUNÇÃO FUNCIONA
                        tooltip: 'Alterar foto do perfil',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refazer Onboarding'),
            subtitle: const Text('Sem limpar consentimento'),
            onTap: () async {
              Navigator.pop(context);
              await widget.prefs.setOnboardingCompleted(false);
              bool currentConsent = widget.prefs.getMarketingConsent();
              Navigator.of(context).pushReplacementNamed(
                '/onboarding',
                arguments: {
                  'startAtPage': 0,
                  'initialConsent': currentConsent,
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Limpar Consentimento'),
            subtitle: const Text('Revogar aceite da política'),
            onTap: () async {
              Navigator.pop(context);
              await widget.prefs.setMarketingConsent(false);
              Navigator.of(context).pushReplacementNamed(
                '/onboarding',
                arguments: {
                  'startAtPage': 2,
                  'initialConsent': false,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}