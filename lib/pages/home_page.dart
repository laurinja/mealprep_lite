import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/presentation/dialogs/meal_actions_dialog.dart'; // Import do novo diálogo
import '../services/prefs_service.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _preferenciasSelecionadas = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];
  String? _userPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  void _loadPhoto() {
    setState(() {
      _userPhotoPath = context.read<PrefsService>().userPhotoPath;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final dir = await getApplicationDocumentsDirectory();
      final name = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = p.join(dir.path, name);

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        minWidth: 512,
        minHeight: 512,
        quality: 80,
      );

      if (result != null) {
        await context.read<PrefsService>().setUserPhotoPath(result.path);
        _loadPhoto();
      }
    }
  }

  void _gerarPlano() {
    context.read<MealController>().gerarPlano(_preferenciasSelecionadas);
  }

  // --- Handlers de Ação ---

  void _showActionsDialog(Refeicao refeicao) {
    showDialog(
      context: context,
      barrierDismissible: false, // Exigido pelo prompt: não fechar ao tocar fora
      builder: (context) {
        return MealActionsDialog(
          onEdit: () => _handleEdit(refeicao),
          onRemove: () => _handleRemoveConfirmation(refeicao),
        );
      },
    );
  }

  void _handleEdit(Refeicao refeicao) {
    // TODO: Implementar showMealFormDialog aqui futuramente
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar refeição: ${refeicao.nome}')),
    );
  }

  void _handleRemoveConfirmation(Refeicao refeicao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text('Tem certeza que deseja remover "${refeicao.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Chamar controller.removeMeal(refeicao.id) futuramente
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refeição removida (simulação)')),
              );
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<MealController>(
      builder: (context, mealController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MealPrep Lite'),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
          endDrawer: AppDrawer(
            userPhotoPath: _userPhotoPath,
            onEditAvatarPressed: _pickImage,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preferências', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _todasPreferencias.map((pref) {
                          final isSelected = _preferenciasSelecionadas.contains(pref);
                          return FilterChip(
                            label: Text(pref),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                val ? _preferenciasSelecionadas.add(pref) : _preferenciasSelecionadas.remove(pref);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _gerarPlano,
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Gerar Cardápio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              if (mealController.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (mealController.planoSemanal.isNotEmpty)
                ...mealController.planoSemanal.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell( // Adicionado InkWell para gestos
                    onLongPress: () => _showActionsDialog(r), // Aciona o diálogo
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Padding movido para dentro do InkWell
                      child: ListTile(
                        leading: CircleAvatar(child: Text(r.tipo[0])),
                        title: Text(r.nome),
                        subtitle: Text(r.tipo),
                        trailing: const Icon(Icons.more_vert), // Indicador visual de ações
                      ),
                    ),
                  ),
                ))
              else
                const Center(child: Text('Nenhum plano gerado.', style: TextStyle(color: Colors.grey))),
            ],
          ),
        );
      },
    );
  }
}