import 'package:flutter/material.dart';
import 'package:mealprep_lite/features/users/data/repositories/user_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealprep_lite/services/prefs_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/meal/domain/entities/refeicao.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/presentation/dialogs/meal_actions_dialog.dart';
import '../features/meal/presentation/dialogs/meal_form_dialog.dart';
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData(silent: true);
    });
  }

  Future<void> _refreshData({bool silent = false}) async {
    await context.read<MealController>().refreshData();
    
    if (!silent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plano sincronizado com a nuvem!'), 
          duration: Duration(milliseconds: 1000)
        ),
      );
    }
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
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 800, 
        imageQuality: 70 
      );

      if (pickedFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Enviando imagem...'), duration: Duration(seconds: 2))
        );

        final repo = context.read<UserRepositoryImpl>();
        final prefs = context.read<PrefsService>();
        
        final userId = Supabase.instance.client.auth.currentUser?.id;
        
        if (userId != null) {
          final url = await repo.uploadProfileImage(userId, pickedFile);
          
          if (url != null) {
             await repo.updateUserProfile(userId, _userName, photoUrl: url);

             await prefs.setUserPhotoPath(url); 
             _loadUserData();
             
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Foto de perfil atualizada!'))
             );
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Erro ao atualizar foto: $e'))
      );
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
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 16),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.black12), readOnly: true, enabled: false),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await context.read<MealController>().updateUserProfile(nameCtrl.text.trim());
                
                _loadUserData(); 
                
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil atualizado!')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showActionsDialog(Refeicao refeicao, String day, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return MealActionsDialog(
          onEdit: () => _handleEdit(refeicao, day, type),
          onRemove: () => _handleRemoveConfirmation(refeicao, day, type),
        );
      },
    );
  }

  void _handleEdit(Refeicao refeicao, String day, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MealFormDialog(
        meal: refeicao,
        onSave: (updatedMeal) async {
          await context.read<MealController>().editMealAndReplace(updatedMeal, updatedMeal, day, type);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refeição personalizada criada!')),
            );
          }
        },
      ),
    );
  }

  void _handleRemoveConfirmation(Refeicao refeicao, String day, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover do Plano?'),
        content: Text('Isso removerá "${refeicao.nome}" do cardápio de $day.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); 
              
              await context.read<MealController>().removeMealFromSchedule(day, type);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refeição removida do plano.')),
                );
              }
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMealSelectionDialog(String day, String type) async {
    final controller = context.read<MealController>();
    final options = await controller.getAvailableMealsForSlot(type, _preferencias);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.6, maxChildSize: 0.9,
        builder: (_, scrollController) => Column(children: [
          Padding(padding: const EdgeInsets.all(16.0), child: Text('Escolher para ${MealTypes.translate(type)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Expanded(child: ListView.builder(
            controller: scrollController, itemCount: options.length,
            itemBuilder: (ctx, index) {
              final meal = options[index];
              return ListTile(
                leading: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(meal.imageUrl ?? '', width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey, width: 50, height: 50))),
                title: Text(meal.nome),
                subtitle: Text(meal.tagIds.join(', ')),
                onTap: () { controller.updateSlot(day, type, meal); Navigator.pop(ctx); },
              );
            },
          )),
        ]),
      ),
    );
  }

  void _gerarSemana() {
    context.read<MealController>().generateFullWeek(_preferencias);
  }

  void _gerarDia(String day) {
    context.read<MealController>().generateDay(day, _preferencias);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gerando cardápio de $day...'), duration: const Duration(milliseconds: 800)));
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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Sincronizar Agora',
                onPressed: () => _refreshData(),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight),
              child: Align(
                alignment: Alignment.center,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.white,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: days.map((day) => Tab(text: day)).toList(),
                ),
              ),
            ),
          ),
          drawer: AppDrawer(
            userPhotoPath: _userPhotoPath, userName: _userName, userEmail: _userEmail,
            onEditAvatarPressed: _pickImage, onEditProfilePressed: _editProfileDialog,
          ),
          body: Column(
            children: [
              if (controller.isLoading)
                const LinearProgressIndicator(minHeight: 4),
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: _todasPreferencias.map((pref) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(pref), selected: _preferencias.contains(pref), onSelected: (val) => setState(() => val ? _preferencias.add(pref) : _preferencias.remove(pref))))).toList()),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _gerarSemana,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Gerar Semana Automática'),
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: days.map((day) {
                    final mealsForDay = controller.weeklyPlan[day] ?? {};
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
    
    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _gerarDia(day), icon: const Icon(Icons.flash_on), label: Text('Gerar Cardápio de $day'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
          const SizedBox(height: 16),
          ...types.map((type) {
            final meal = meals[type];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(MealTypes.translate(type), style: const TextStyle(fontWeight: FontWeight.bold)), TextButton.icon(onPressed: () => _showMealSelectionDialog(day, type), icon: const Icon(Icons.edit, size: 16), label: const Text('Trocar'), style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap))])),
                  if (meal != null)
                    InkWell( 
                      onLongPress: () => _showActionsDialog(meal, day, type),
                      child: ListTile(
                        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(meal.imageUrl ?? '', width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey, width: 50, height: 50))),
                        title: Text(meal.nome),
                        subtitle: Text(meal.tagIds.join(', ')),
                        onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: Text(meal.nome), content: Text(meal.ingredienteIds.join('\n')))),
                      ),
                    )
                  else
                    ListTile(title: const Text('Vazio', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)), trailing: const Icon(Icons.add_circle_outline, color: Colors.grey), onTap: () => _showMealSelectionDialog(day, type)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}