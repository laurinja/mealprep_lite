import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class GenerateMealPlan implements UseCase<List<Meal>, Set<String>> {
  final MealRepository repository;

  GenerateMealPlan(this.repository);

  @override
  Future<Either<Failure, List<Meal>>> call(Set<String> preferences) async {
    return await repository.generateMealPlan(preferences);
  }
}