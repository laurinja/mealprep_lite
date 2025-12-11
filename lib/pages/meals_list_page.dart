import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/meal/presentation/controllers/meal_list_controller.dart';
import '../features/meal/domain/entities/refeicao.dart';
import '../core/constants/meal_types.dart';

class MealsListPage extends StatefulWidget {
  const MealsListPage({super.key});

  @override
  State<MealsListPage> createState() => _MealsListPageState();
}

class _MealsListPageState extends State<MealsListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealListController>().loadMeals(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<MealListController>().loadMeals();
      }
    });
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
      ),
      body: Column(
        children: [
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
                  return const Center(
                    child: Text('Nenhuma refeição encontrada.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  itemCount: controller.meals.length + (controller.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == controller.meals.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final meal = controller.meals[index];
                    return _buildMealItem(meal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? typeValue, MealListController controller) {
    bool isSelected = false; 
    
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
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return Container(color: Colors.grey[200], width: 60, height: 60);
          },
          errorBuilder: (ctx, error, stack) {
            return Container(
              color: Colors.grey[300], 
              width: 60, height: 60, 
              child: const Icon(Icons.restaurant, color: Colors.grey)
            );
          },
        ),
      ),
      title: Text(meal.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(MealTypes.translate(meal.tipo), style: TextStyle(color: Colors.green[700], fontSize: 12)),
          const SizedBox(height: 4),
          if (meal.tagIds.isNotEmpty)
            Text(meal.tagIds.join(', '), style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
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