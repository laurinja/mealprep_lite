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
      try {
        final List decoded = jsonDecode(jsonString);
        return decoded.map((e) => RefeicaoDTO.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    } else {
      return [];
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
      RefeicaoDTO(id: '1', nome: 'Aveia com Frutas', tipo: MealTypes.breakfast, tagIds: ['Rápido', 'Saudável', 'Vegetariano'], ingredienteIds: ['Aveia', 'Leite', 'Morangos', 'Mel'], imageUrl: 'https://ovegetariano.pt/wp-content/uploads/2016/05/IMG_20160424_121250-600x750.jpg'),
      RefeicaoDTO(id: '2', nome: 'Ovos Mexidos', tipo: MealTypes.breakfast, tagIds: ['Rápido'], ingredienteIds: ['2 Ovos', 'Manteiga', 'Sal', 'Torrada'], imageUrl: 'https://receitas-airfryer.pt/wp-content/uploads/2025/02/Ovos-mexidos-na-airfryer.png'),
      RefeicaoDTO(id: '3', nome: 'Panqueca de Banana', tipo: MealTypes.breakfast, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Banana', 'Ovo', 'Canela', 'Aveia'], imageUrl: 'https://www.sabornamesa.com.br/media/k2/items/cache/7a0fedcef13e85a941dc364a9cbe4e6e_XL.jpg'),
      RefeicaoDTO(id: '4', nome: 'Iogurte com Granola', tipo: MealTypes.breakfast, tagIds: ['Rápido', 'Saudável', 'Vegetariano'], ingredienteIds: ['Iogurte', 'Granola', 'Mel'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVz8Fo7AAyFbM3CDchLdDwB9bbme-mnM0Q7Q&s'),
      RefeicaoDTO(id: '5', nome: 'Pão de Queijo', tipo: MealTypes.breakfast, tagIds: ['Rápido', 'Vegetariano'], ingredienteIds: ['Polvilho', 'Queijo', 'Ovo', 'Leite'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGdt_gMXmSj7Hbr14GwbBq9q4qf91JimRH2w&s'),
      RefeicaoDTO(id: '6', nome: 'Suco Verde', tipo: MealTypes.breakfast, tagIds: ['Rápido', 'Saudável', 'Vegetariano'], ingredienteIds: ['Couve', 'Abacaxi', 'Gengibre'], imageUrl: 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=500&q=80'),
      
      RefeicaoDTO(id: '7', nome: 'Salada Grão de Bico', tipo: MealTypes.lunch, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Grão de Bico', 'Tomate', 'Pepino'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ4tY6hY_oHQ_xjD6Yl2DYmxrTs0SASSi3Qg&s'),
      RefeicaoDTO(id: '8', nome: 'Macarrão ao Pesto', tipo: MealTypes.lunch, tagIds: ['Rápido', 'Vegetariano'], ingredienteIds: ['Macarrão', 'Pesto', 'Parmesão'], imageUrl: 'https://guiadacozinha.com.br/wp-content/uploads/2015/01/macarraocompesto.jpg'),
      RefeicaoDTO(id: '9', nome: 'Wrap de Frango', tipo: MealTypes.lunch, tagIds: ['Rápido'], ingredienteIds: ['Tortilha', 'Frango', 'Alface'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS1WsBh0rusV4OYueHyXZrEqBhLrkuBxnmQBA&s'),
      RefeicaoDTO(id: '10', nome: 'Frango Grelhado', tipo: MealTypes.lunch, tagIds: ['Saudável', 'Rápido'], ingredienteIds: ['Frango', 'Batata Doce', 'Salada'], imageUrl: 'https://bellami.com.br/2017/wp-content/uploads/2017/01/file-de-frango-grelhado-1.jpg'),
      RefeicaoDTO(id: '11', nome: 'Strogonoff', tipo: MealTypes.lunch, tagIds: ['Rápido'], ingredienteIds: ['Carne', 'Creme de Leite', 'Arroz'], imageUrl: 'https://minervafoods.com/wp-content/uploads/2022/12/Strogonoff-de-Carne-HOR-1-scaled-1-1920x1280.jpg'),
      RefeicaoDTO(id: '12', nome: 'Escondidinho', tipo: MealTypes.lunch, tagIds: ['Saudável'], ingredienteIds: ['Abóbora', 'Carne Moída', 'Queijo'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIvxgEdJQSScEzTPz9xxZRh1eO1P7us4VGFA&s'),
      RefeicaoDTO(id: '13', nome: 'Poke Bowl', tipo: MealTypes.lunch, tagIds: ['Saudável', 'Rápido'], ingredienteIds: ['Arroz', 'Salmão', 'Manga'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHwJ3ttigPOqr6UxBlPbWEJQnmuWoZYMlGzA&s'),

      RefeicaoDTO(id: '14', nome: 'Sopa de Legumes', tipo: MealTypes.dinner, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Batata', 'Cenoura', 'Macarrão'], imageUrl: 'https://areademulher.r7.com/wp-content/uploads/2021/02/como-fazer-sopa-de-legumes-historia-do-prato-receitas-deliciosas.jpg'),
      RefeicaoDTO(id: '15', nome: 'Peixe Grelhado', tipo: MealTypes.dinner, tagIds: ['Saudável'], ingredienteIds: ['Tilápia', 'Limão', 'Legumes'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSMM0Pti4TmpGQZqps9Q3cctl-DnDnBWV6SIA&s'),
      RefeicaoDTO(id: '16', nome: 'Omelete', tipo: MealTypes.dinner, tagIds: ['Rápido', 'Vegetariano'], ingredienteIds: ['Ovos', 'Queijo', 'Tomate'], imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEB9__WLlChjkHV5bY5kkkF9_uqN13800W7w&s'),
      RefeicaoDTO(id: '17', nome: 'Crepioca', tipo: MealTypes.dinner, tagIds: ['Rápido', 'Saudável'], ingredienteIds: ['Tapioca', 'Ovo', 'Frango'], imageUrl: 'https://assets.unileversolutions.com/recipes-v2/177907.jpg'),
      RefeicaoDTO(id: '18', nome: 'Sanduíche Natural', tipo: MealTypes.dinner, tagIds: ['Rápido'], ingredienteIds: ['Pão Integral', 'Atum', 'Alface'], imageUrl: 'https://www.receiteria.com.br/wp-content/uploads/sanduiche-natural-de-frango-com-iogurte.jpg'),
      RefeicaoDTO(id: '19', nome: 'Salada Caesar', tipo: MealTypes.dinner, tagIds: ['Saudável'], ingredienteIds: ['Alface', 'Frango', 'Molho', 'Croutons'], imageUrl: 'https://p2.trrsf.com/image/fget/cf/1200/900/middle/images.terra.com/2023/02/28/whatsapp-image-2023-02-28-at-01-53-47-(1)-1iyhprrq5e9tc.jpeg'),
      RefeicaoDTO(id: '20', nome: 'Macarrão Abobrinha', tipo: MealTypes.dinner, tagIds: ['Saudável', 'Vegetariano'], ingredienteIds: ['Abobrinha', 'Tomate'], imageUrl: 'https://www.sabornamesa.com.br/media/k2/items/cache/1018117f01c19c6ed27c0f2c97f37a79_XL.jpg'),
    ];
  }
}