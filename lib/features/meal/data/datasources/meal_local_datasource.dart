import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/refeicao_dto.dart';
import '../../../../core/constants/meal_types.dart'; 

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

  List<RefeicaoDTO> _getInitialData() {
    return [
      RefeicaoDTO(id: '1', nome: 'Aveia com Frutas', tipo: MealTypes.breakfast, tagIds: ['Rápido', 'Saudável', 'Vegetariano'], ingredienteIds: ['Aveia', 'Leite', 'Frutas'], imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500&q=80'),
      RefeicaoDTO(id: '2', nome: 'Ovos Mexidos', tipo: MealTypes.breakfast, tagIds: ['Rápido'], ingredienteIds: ['Ovos', 'Manteiga', 'Torrada'], imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414395d8?w=500&q=80'),
      RefeicaoDTO(id: '3', nome: 'Pão de Queijo', tipo: MealTypes.breakfast, tagIds: ['Rápido', 'Vegetariano'], ingredienteIds: ['Polvilho', 'Queijo'], imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&q=80'),
      RefeicaoDTO(id: '4', nome: 'Iogurte e Granola', tipo: MealTypes.breakfast, tagIds: ['Saudável', 'Rápido'], ingredienteIds: ['Iogurte', 'Granola', 'Mel'], imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&q=80'),
      RefeicaoDTO(id: '5', nome: 'Crepioca', tipo: MealTypes.breakfast, tagIds: ['Saudável', 'Rápido'], ingredienteIds: ['Ovo', 'Tapioca', 'Requeijão'], imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80'),
      RefeicaoDTO(id: '6', nome: 'Suco Verde', tipo: MealTypes.breakfast, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Couve', 'Laranja', 'Pão'], imageUrl: 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=500&q=80'),

      RefeicaoDTO(id: '7', nome: 'Salada Grão de Bico', tipo: MealTypes.lunch, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Grão de Bico', 'Tomate', 'Pepino'], imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80'),
      RefeicaoDTO(id: '8', nome: 'Frango Grelhado', tipo: MealTypes.lunch, tagIds: ['Saudável', 'Rápido'], ingredienteIds: ['Frango', 'Batata Doce', 'Salada'], imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500&q=80'),
      RefeicaoDTO(id: '9', nome: 'Macarrão Bolonhesa', tipo: MealTypes.lunch, tagIds: ['Rápido'], ingredienteIds: ['Macarrão', 'Carne Moída', 'Molho'], imageUrl: 'https://images.unsplash.com/photo-1622973536968-3ead9e780960?w=500&q=80'),
      RefeicaoDTO(id: '10', nome: 'Strogonoff', tipo: MealTypes.lunch, tagIds: ['Rápido'], ingredienteIds: ['Frango/Carne', 'Creme de Leite', 'Batata Palha'], imageUrl: 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=500&q=80'),
      RefeicaoDTO(id: '11', nome: 'Feijoada Simples', tipo: MealTypes.lunch, tagIds: [], ingredienteIds: ['Feijão Preto', 'Carnes', 'Couve'], imageUrl: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=500&q=80'),
      RefeicaoDTO(id: '12', nome: 'Peixe Assado', tipo: MealTypes.lunch, tagIds: ['Saudável'], ingredienteIds: ['Peixe', 'Batatas', 'Azeite'], imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80'),
      RefeicaoDTO(id: '13', nome: 'Poke Bowl', tipo: MealTypes.lunch, tagIds: ['Saudável', 'Rápido'], ingredienteIds: ['Arroz', 'Salmão', 'Manga'], imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80'),

      RefeicaoDTO(id: '14', nome: 'Sopa de Legumes', tipo: MealTypes.dinner, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Batata', 'Cenoura', 'Macarrão'], imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=500&q=80'),
      RefeicaoDTO(id: '15', nome: 'Omelete', tipo: MealTypes.dinner, tagIds: ['Rápido', 'Vegetariano'], ingredienteIds: ['Ovos', 'Queijo', 'Tomate'], imageUrl: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=500&q=80'),
      RefeicaoDTO(id: '16', nome: 'Wrap de Atum', tipo: MealTypes.dinner, tagIds: ['Rápido', 'Saudável'], ingredienteIds: ['Rap10', 'Atum', 'Alface'], imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=80'),
      RefeicaoDTO(id: '17', nome: 'Salada Caesar', tipo: MealTypes.dinner, tagIds: ['Saudável'], ingredienteIds: ['Alface', 'Frango', 'Molho', 'Croutons'], imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=500&q=80'),
      RefeicaoDTO(id: '18', nome: 'Hamburguer', tipo: MealTypes.dinner, tagIds: ['Rápido'], ingredienteIds: ['Pão', 'Carne', 'Queijo', 'Salada'], imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80'),
      RefeicaoDTO(id: '19', nome: 'Macarrão Abobrinha', tipo: MealTypes.dinner, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Abobrinha', 'Molho Tomate'], imageUrl: 'https://images.unsplash.com/photo-1620916297397-a4a5402a3c6c?w=500&q=80'),
      RefeicaoDTO(id: '20', nome: 'Pizza Frigideira', tipo: MealTypes.dinner, tagIds: ['Rápido'], ingredienteIds: ['Massa', 'Queijo', 'Orégano'], imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80'),
    ];
  }
}