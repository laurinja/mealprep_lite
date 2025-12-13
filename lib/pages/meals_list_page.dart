import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/meal/presentation/controllers/meal_list_controller.dart';
import '../features/meal/presentation/controllers/meal_controller.dart';
import '../features/meal/domain/entities/refeicao.dart';
import '../core/constants/meal_types.dart';
import '../services/prefs_service.dart';

import '../features/meal/presentation/dialogs/meal_actions_dialog.dart';
import '../features/meal/presentation/dialogs/meal_form_dialog.dart';

class MealsListPage extends StatefulWidget {
  const MealsListPage({super.key});

  @override
  State<MealsListPage> createState() => _MealsListPageState();
}

class _MealsListPageState extends State<MealsListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  void _showActionsDialog(Refeicao meal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MealActionsDialog(
        onEdit: () => _handleEdit(meal),
        onRemove: () => _handleDelete(meal),
      ),
    );
  }

  void _handleEdit(Refeicao meal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => MealFormDialog(
        meal: meal,
        onSave: (updatedMeal) async {
          
          final controller = context.read<MealController>();
          
          final myEmail = context.read<PrefsService>().userEmail;
          
          if (meal.createdBy == myEmail) {
             await context.read<MealController>().editMeal(updatedMeal);
          } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edição de pratos públicos no catálogo virá em breve.')));
             return;
          }
          
          _onRefresh();
        },
      ),
    );
  }

  void _handleDelete(Refeicao meal) {
    final myEmail = context.read<PrefsService>().userEmail;
    if (meal.createdBy != myEmail) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você só pode excluir pratos criados por você.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir do Catálogo?'),
        content: const Text('Isso apagará o prato permanentemente da sua lista.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<MealController>().softDeleteMeal(meal);
              _onRefresh();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = context.read<PrefsService>().userEmail;
      context.read<MealListController>().loadMeals(refresh: true, userEmail: email);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<MealListController>().loadMeals();
      }
    });
  }

  Future<void> _onRefresh() async {
    final email = context.read<PrefsService>().userEmail;
    await context.read<MealListController>().loadMeals(refresh: true, userEmail: email);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Refeições'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Lista',
            onPressed: () {
              _onRefresh(); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Atualizando lista...'), duration: Duration(milliseconds: 800))
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<MealListController>(
            builder: (_, controller, __) {
              if (controller.isLoading) {
                return const LinearProgressIndicator(minHeight: 4);
              }
              return const SizedBox(height: 0); 
            },
          ),

          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar refeição...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<MealListController>().updateSearch('');
                      },
                    ),
                  ),
                  onChanged: (val) => context.read<MealListController>().updateSearch(val),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Consumer<MealListController>(
                    builder: (context, controller, _) {
                      return Row(
                        children: [
                          _buildFilterChip(context, 'Todos', null, controller),
                          ...MealTypes.values.map((type) => 
                            _buildFilterChip(context, MealTypes.translate(type), type, controller)
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<MealListController>(
              builder: (context, controller, _) {
                if (controller.meals.isEmpty && !controller.isLoading) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Nenhuma refeição encontrada.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              Text('Puxe para atualizar ou use o botão acima.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.meals.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final meal = controller.meals[index];
                      return _buildMealItem(meal);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? typeValue, MealListController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => controller.updateTypeFilter(typeValue),
      ),
    );
  }

  Widget _buildMealItem(Refeicao meal) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          meal.imageUrl ?? '',
          width: 60, height: 60, fit: BoxFit.cover,
          errorBuilder: (_,__,___) => Container(color: Colors.grey[300], width: 60, height: 60, child: const Icon(Icons.restaurant, color: Colors.grey)),
        ),
      ),
      title: Text(meal.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(MealTypes.translate(meal.tipo), style: TextStyle(color: Colors.green[700], fontSize: 12)),
      onLongPress: () => _showActionsDialog(meal),
      onTap: () {
        showDialog(
          context: context, 
          builder: (_) => AlertDialog(
            title: Text(meal.nome),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ingredientes:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (meal.ingredienteIds.isEmpty) const Text('Nenhum ingrediente cadastrado.'),
                ...meal.ingredienteIds.map((i) => Text('• $i')),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
          )
        );
      },
    );
  }
}