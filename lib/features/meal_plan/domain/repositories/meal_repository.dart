import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal.dart';

abstract class MealRepository {
  Future<Either<Failure, List<Meal>>> generateMealPlan(Set<String> preferences);
}