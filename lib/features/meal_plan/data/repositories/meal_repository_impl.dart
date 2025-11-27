import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_datasource.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDataSource localDataSource;

  MealRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Meal>>> generateMealPlan(
    Set<String> preferences,
  ) async {
    try {
      final meals = localDataSource.getMealsByPreferences(preferences);
      return Right(meals);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}