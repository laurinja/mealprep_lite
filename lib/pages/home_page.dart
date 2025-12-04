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
import '../../core/constants/meal_types.dart';

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
      final pickedFile = await picker.pickImage(
          source: ImageSource.gallery, maxWidth: 600);
      if (pickedFile != null) {
        final dir = await getApplicationDocumentsDirectory();
        final name = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final targetPath = p.join(dir.path, name);
        final XFile? result = await FlutterImageCompress.compressAndGetFile(
            pickedFile.path, targetPath,
            minWidth: 500, minHeight: 500, quality: 85);
        if (result != null) {
          await Provider.of<PrefsService>(context, listen: false)
              .setUserPhotoPath(result.path);
          _loadUserData();
        }
      }
    } catch (e) {
      debugPrint('Erro: $e');
    }
  }

  void _editProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 16),
          TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.black12),
              readOnly: true,
              enabled: false),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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

  void _showMealSelectionDialog(String day, String type) async {
    final controller = context.read<MealController>();
    final options =
        await controller.getAvailableMealsForSlot(type, _preferencias);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Escolher para ${MealTypes.translate(type)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: options.length,
                    itemBuilder: (ctx, index) {
                      final meal = options[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            meal.imageUrl ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey, width: 50, height: 50),
                          ),
                        ),
                        title: Text(meal.nome),
                        subtitle: Text(meal.tagIds.join(', ')),
                        onTap: () {
                          controller.updateSlot(day, type, meal);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Salvo!')));
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _gerarSemana() {
    context.read<MealController>().generateFullWeek(_preferencias);
  }

  void _gerarDia(String day) {
    context.read<MealController>().generateDay(day, _preferencias);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gerando cardápio de $day...'), duration: const Duration(milliseconds: 800)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = MealController.daysOfWeek;

    return Consumer<MealController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('MealPrep Lite'),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
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
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.surface,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _todasPreferencias
                        .map((pref) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(pref),
                                selected: _preferencias.contains(pref),
                                onSelected: (val) => setState(() => val
                                    ? _preferencias.add(pref)
                                    : _preferencias.remove(pref)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: days.map((day) {
                          final mealsForDay =
                              controller.weeklyPlan[day] ?? {};
                          return _buildDayView(day, mealsForDay);
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayView(String day, Map<String, Refeicao> meals) {
    final types = MealTypes.values;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _gerarDia(day),
            icon: const Icon(Icons.flash_on),
            label: Text('Gerar Cardápio de $day'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...types.map((type) {
          final meal = meals[type];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(MealTypes.translate(type),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _showMealSelectionDialog(day, type),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Trocar'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      )
                    ],
                  ),
                ),
                if (meal != null)
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.imageUrl ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey, width: 50, height: 50),
                      ),
                    ),
                    title: Text(meal.nome),
                    subtitle: Text(meal.tagIds.join(', ')),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                              title: Text(meal.nome),
                              content: Text(meal.ingredienteIds.join('\n'))));
                    },
                  )
                else
                  ListTile(
                    title: const Text('Vazio',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic)),
                    trailing:
                        const Icon(Icons.add_circle_outline, color: Colors.grey),
                    onTap: () => _showMealSelectionDialog(day, type),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}