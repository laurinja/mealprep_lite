import '../entities/refeicao.dart';

abstract class MealRepository {
  Future<List<Refeicao>> loadFromCache();

  Future<int> syncFromServer([String? userEmail]);

  Future<List<Refeicao>> listAll();

  Future<void> save(Refeicao meal);
  
  Future<Map<String, Map<String, String>>> fetchWeeklyPlan(String email);

  Future<void> syncWeeklyPlan(String email, Map<String, Map<String, String>> localPlan);

  Future<List<Refeicao>> getMealsPaged({
    required int page, 
    required int pageSize, 
    String? query, 
    String? typeFilter
  });
}