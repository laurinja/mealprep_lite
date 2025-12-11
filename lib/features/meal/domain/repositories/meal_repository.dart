import '../entities/refeicao.dart';

abstract class MealRepository {
  Future<List<Refeicao>> getRefeicoes();
  Future<void> syncRefeicoes();
  
  Future<void> syncUserProfile(String name, String email, String? photoPath);
  
  Future<void> syncWeeklyPlan(String email, Map<String, Map<String, String>> localPlan);
  
  Future<Map<String, Map<String, String>>> fetchWeeklyPlan(String email);

  Future<Map<String, dynamic>?> authenticateUser(String email, String password);
  Future<bool> registerUser(String name, String email, String password);
  Future<void> deleteUserAccount(String email);

  Future<List<Refeicao>> getMealsPaged({
    required int page, 
    required int pageSize, 
    String? query,
    String? typeFilter 
  });
}