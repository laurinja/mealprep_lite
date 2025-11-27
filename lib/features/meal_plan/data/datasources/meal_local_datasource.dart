import '../models/meal_model.dart';

abstract class MealLocalDataSource {
  List<MealModel> getMealsByPreferences(Set<String> preferences);
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  final List<MealModel> _cardapioExemplo = const [
    MealModel(
      nome: 'Aveia com Frutas',
      tipo: 'Café da Manhã',
      tags: {'Rápido', 'Saudável'},
    ),
    MealModel(
      nome: 'Ovos Mexidos com Pão Integral',
      tipo: 'Café da Manhã',
      tags: {'Rápido'},
    ),
    MealModel(
      nome: 'Salada de Grão de Bico com Frango',
      tipo: 'Almoço',
      tags: {'Saudável'},
    ),
    MealModel(
      nome: 'Macarrão com Pesto e Tomate',
      tipo: 'Almoço',
      tags: {'Rápido', 'Vegetariano'},
    ),
    MealModel(
      nome: 'Wrap de Frango e Salada',
      tipo: 'Almoço',
      tags: {'Rápido'},
    ),
    MealModel(
      nome: 'Sopa de Legumes',
      tipo: 'Jantar',
      tags: {'Saudável', 'Vegetariano'},
    ),
    MealModel(
      nome: 'Omelete com Queijo e Espinafre',
      tipo: 'Jantar',
      tags: {'Rápido'},
    ),
    MealModel(
      nome: 'Peixe Grelhado com Brócolis',
      tipo: 'Jantar',
      tags: {'Saudável'},
    ),
  ];

  @override
  List<MealModel> getMealsByPreferences(Set<String> preferences) {
    if (preferences.isEmpty) {
      final shuffled = List<MealModel>.from(_cardapioExemplo)..shuffle();
      return shuffled.take(3).toList();
    }

    final filtered = _cardapioExemplo.where((meal) {
      return preferences.every((tag) => meal.tags.contains(tag));
    }).toList();

    filtered.shuffle();
    return filtered.take(3).toList();
  }
}