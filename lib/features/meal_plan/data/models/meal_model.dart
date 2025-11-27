import '../../domain/entities/meal.dart';

class MealModel extends Meal {
  const MealModel({
    required super.nome,
    required super.tipo,
    required super.tags,
  });

  factory MealModel.fromEntity(Meal meal) {
    return MealModel(
      nome: meal.nome,
      tipo: meal.tipo,
      tags: meal.tags,
    );
  }

  Meal toEntity() {
    return Meal(
      nome: nome,
      tipo: tipo,
      tags: tags,
    );
  }
}