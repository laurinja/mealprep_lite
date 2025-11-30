import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/presentation/dialogs/meal_actions_dialog.dart';
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
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final prefs = context.read<PrefsService>();
    setState(() {
      _userPhotoPath = prefs.userPhotoPath;
      _userName = prefs.userName;
      _userEmail = prefs.userEmail;
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
        minWidth: 512, minHeight: 512, quality: 80,
      );

      if (result != null) {
        await context.read<PrefsService>().setUserPhotoPath(result.path);
        _loadUserData();
      }
    }
  }

  void _editProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final prefs = context.read<PrefsService>();
              await prefs.setUserName(nameCtrl.text);
              await prefs.setUserEmail(emailCtrl.text);
              _loadUserData();
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _gerarPlano() {
    context.read<MealController>().gerarPlano(_preferenciasSelecionadas);
  }

  void _showActionsDialog(Refeicao refeicao) {
    showDialog(
      context: context,
      builder: (context) {
        return MealActionsDialog(
          onEdit: () => _handleSwap(refeicao), 
          onRemove: () => _handleRemoveConfirmation(refeicao),
        );
      },
    );
  }

  void _handleSwap(Refeicao refeicao) {
    context.read<MealController>().trocarRefeicao(refeicao);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Buscando substituição...')),
    );
  }

  void _handleRemoveConfirmation(Refeicao refeicao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: Text('Deseja remover "${refeicao.nome}" do plano?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MealController>().removerRefeicao(refeicao.id);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showIngredients(Refeicao refeicao) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(refeicao.nome, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Ingredientes:', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (refeicao.ingredienteIds.isEmpty)
              const Text('Nenhum ingrediente listado.')
            else
              ...refeicao.ingredienteIds.map((ing) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(ing),
                  ],
                ),
              )),
            const SizedBox(height: 20),
          ],
        ),
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
            userName: _userName,
            userEmail: _userEmail,
            onEditAvatarPressed: _pickImage,
            onEditProfilePressed: _editProfileDialog,
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
                label: Text(mealController.planoSemanal.isEmpty ? 'Gerar Cardápio' : 'Gerar Novo Cardápio'),
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
                  child: InkWell(
                    onTap: () => _showIngredients(r), 
                    onLongPress: () => _showActionsDialog(r), 
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          child: Text(r.tipo[0], style: TextStyle(color: theme.colorScheme.primary)),
                        ),
                        title: Text(r.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.tipo),
                            const SizedBox(height: 4),
                            // Mostra tags como texto pequeno
                            Text(r.tagIds.join(', '), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: const Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                ))
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Seu plano está vazio.\nSelecione preferências e gere um cardápio!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}