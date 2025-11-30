import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mealprep_lite/services/prefs_service.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/presentation/dialogs/meal_actions_dialog.dart';
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
    final prefs = Provider.of<PrefsService>(context, listen: false);
    setState(() {
      _userPhotoPath = prefs.userPhotoPath;
      _userName = prefs.userName;
      _userEmail = prefs.userEmail;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      
      if (pickedFile != null) {
        final dir = await getApplicationDocumentsDirectory();
        final name = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final targetPath = p.join(dir.path, name);

        final XFile? result = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path, targetPath, minWidth: 500, minHeight: 500, quality: 85,
        );

        if (result != null) {
          await Provider.of<PrefsService>(context, listen: false).setUserPhotoPath(result.path);
          _loadUserData();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada!')));
        }
      }
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  // --- MUDANÇA: Diálogo com Email Bloqueado ---
  void _editProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome', hintText: 'Seu nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email', 
                filled: true, 
                fillColor: Colors.black12
              ),
              readOnly: true, // Bloqueia escrita
              enabled: false, // Bloqueia foco
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('O email não pode ser alterado.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final prefs = context.read<PrefsService>();
                // Salva apenas o nome
                await prefs.setUserName(nameCtrl.text.trim());
                _loadUserData();
                if (mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome atualizado!')));
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _gerarPlano() => context.read<MealController>().gerarPlano(_preferenciasSelecionadas);

  void _showActionsDialog(Refeicao r) {
    showDialog(context: context, builder: (_) => MealActionsDialog(
      onEdit: () => _handleSwap(r),
      onRemove: () => _handleRemove(r),
    ));
  }

  Future<void> _handleSwap(Refeicao r) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buscando troca...'), duration: Duration(milliseconds: 800)));
    final novo = await context.read<MealController>().trocarRefeicao(r);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (novo != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trocado por: $novo'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sem opções.'), backgroundColor: Colors.orange));
    }
  }

  void _handleRemove(Refeicao r) => context.read<MealController>().removerRefeicao(r.id);

  void _showIngredients(Refeicao r) {
    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.nome, style: Theme.of(context).textTheme.headlineSmall),
          const Divider(),
          if (r.ingredienteIds.isEmpty) const Text('Sem ingredientes.') else ...r.ingredienteIds.map((i) => Text('• $i')),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<MealController>(
      builder: (context, controller, _) => Scaffold(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preferências', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _todasPreferencias.map((pref) => FilterChip(
                        label: Text(pref),
                        selected: _preferenciasSelecionadas.contains(pref),
                        onSelected: (val) => setState(() => val ? _preferenciasSelecionadas.add(pref) : _preferenciasSelecionadas.remove(pref)),
                      )).toList(),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _gerarPlano,
              icon: const Icon(Icons.restaurant_menu),
              label: Text(controller.planoSemanal.isEmpty ? 'Gerar Cardápio' : 'Gerar Novo'),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            if (controller.isLoading) const Center(child: CircularProgressIndicator())
            else if (controller.planoSemanal.isNotEmpty)
              ...controller.planoSemanal.map((r) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(r.tipo[0])),
                  title: Text(r.nome),
                  subtitle: Text(r.tipo),
                  onTap: () => _showIngredients(r),
                  onLongPress: () => _showActionsDialog(r),
                  trailing: const Icon(Icons.more_vert),
                ),
              ))
            else const Center(child: Text('Nenhum plano gerado.', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}