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
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _preferencias = {};
  final List<String> _todasPreferencias = ['Rápido', 'Saudável', 'Vegetariano'];
  
  String? _userPhotoPath;
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); 
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
          pickedFile.path, targetPath, minWidth: 500, minHeight: 500, quality: 85);
        if (result != null) {
          await Provider.of<PrefsService>(context, listen: false).setUserPhotoPath(result.path);
          _loadUserData();
        }
      }
    } catch (e) { debugPrint('Erro foto: $e'); }
  }

  void _editProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 16),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.black12), readOnly: true, enabled: false),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final prefs = context.read<PrefsService>();
                await prefs.setUserName(nameCtrl.text.trim());
                _loadUserData();
                if (mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _gerarSemana() {
    context.read<MealController>().generateFullWeek(_preferencias);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = MealController.daysOfWeek; 

    return Consumer<MealController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MealPrep Semanal'),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: theme.colorScheme.primary,
              tabs: days.map((day) => Tab(text: day)).toList(),
            ),
          ),
          endDrawer: AppDrawer(
            userPhotoPath: _userPhotoPath,
            userName: _userName,
            userEmail: _userEmail,
            onEditAvatarPressed: _pickImage,
            onEditProfilePressed: _editProfileDialog,
          ),
          body: Column(
            children: [
              // Barra de Filtros e Ação
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _todasPreferencias.map((pref) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(pref),
                            selected: _preferencias.contains(pref),
                            onSelected: (val) => setState(() => val ? _preferencias.add(pref) : _preferencias.remove(pref)),
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _gerarSemana,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Gerar Semana Completa'),
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: controller.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: days.map((day) {
                        final mealsForDay = controller.weeklyPlan[day] ?? {};
                        return _buildDayView(day, mealsForDay, controller);
                      }).toList(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Passamos o controller aqui para acessar o método regenerateSlot
  Widget _buildDayView(String day, Map<String, Refeicao> meals, MealController controller) {
    final types = MealController.mealTypes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: types.map((type) {
        final meal = meals[type];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (meal != null)
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: meal.imageUrl != null 
                        ? Image.network(meal.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                        : Container(color: Colors.green, width: 50, height: 50, child: const Icon(Icons.restaurant, color: Colors.white)),
                  ),
                  title: Text(meal.nome),
                  subtitle: Text(meal.tagIds.join(', ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Trocar prato',
                    onPressed: () {
                      // Chama a nova função de troca única
                      controller.regenerateSlot(day, type, _preferencias);
                      
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Trocando ${type.toLowerCase()}...'), duration: const Duration(milliseconds: 500))
                      );
                    },
                  ),
                  onTap: () => _showIngredients(meal),
                )
              else
                ListTile(
                  title: const Text('Vazio - Gere um cardápio', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.add_circle_outline),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showIngredients(Refeicao r) {
    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.nome, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        if (r.ingredienteIds.isEmpty) const Text('Sem ingredientes.') else ...r.ingredienteIds.map((i) => Text('• $i')),
        const SizedBox(height: 20),
      ]),
    ));
  }
}