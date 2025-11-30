import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/refeicao_dto.dart';

abstract class MealLocalDataSource {
  Future<List<RefeicaoDTO>> getCachedMeals();
  Future<void> cacheMeals(List<RefeicaoDTO> meals);
  Future<void> updateMealLocally(RefeicaoDTO meal);
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  final SharedPreferences prefs;
  static const _keyMeals = 'cached_meals_list';

  MealLocalDataSourceImpl(this.prefs);

  @override
  Future<List<RefeicaoDTO>> getCachedMeals() async {
    final jsonString = prefs.getString(_keyMeals);
    
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => RefeicaoDTO.fromJson(e)).toList();
    } else {
      // Se não tem cache, carrega os dados iniciais (Seed)
      final initialData = _getInitialData();
      await cacheMeals(initialData);
      return initialData;
    }
  }

  @override
  Future<void> cacheMeals(List<RefeicaoDTO> meals) async {
    final jsonString = jsonEncode(meals.map((e) => e.toJson()).toList());
    await prefs.setString(_keyMeals, jsonString);
  }

  @override
  Future<void> updateMealLocally(RefeicaoDTO meal) async {
    final currentList = await getCachedMeals();
    final index = currentList.indexWhere((element) => element.id == meal.id);
    
    if (index != -1) {
      currentList[index] = meal;
    } else {
      currentList.add(meal);
    }
    await cacheMeals(currentList);
  }

  // Dados iniciais para não começar vazio (Backup do código anterior)
  List<RefeicaoDTO> _getInitialData() {
    return [
      RefeicaoDTO(
        id: '1', nome: 'Aveia com Frutas', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Aveia', 'Leite', 'Morangos', 'Mel'],
        imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '7', nome: 'Salada de Grão de Bico', tipo: 'Almoço',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Grão de bico', 'Tomate', 'Pepino'],
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '15', nome: 'Peixe com Legumes', tipo: 'Jantar',
        tagIds: ['Saudável'],
        ingredienteIds: ['Tilápia', 'Limão', 'Cenoura'],
        imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80',
      ),
    ];
  }
}