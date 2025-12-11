import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/refeicao.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_datasource.dart';
import '../datasources/meal_remote_datasource.dart';
import '../mappers/refeicao_mapper.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDataSource localDataSource;
  final MealRemoteDataSource remoteDataSource;
  final RefeicaoMapper _mapper = RefeicaoMapper();
  final SupabaseClient _supabase = Supabase.instance.client;

  MealRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<List<Refeicao>> getRefeicoes() async {
    final localDtos = await localDataSource.getCachedMeals();
    return localDtos.map((dto) => _mapper.toEntity(dto)).toList();
  }

  @override
  Future<void> syncRefeicoes() async {
    try {
      final localDtos = await localDataSource.getCachedMeals();
      final dirtyMeals = localDtos.where((e) => e.isDirty).toList();
      if (dirtyMeals.isNotEmpty) {
        for (var meal in dirtyMeals) {
          try {
            await remoteDataSource.update(meal);
            await localDataSource.updateMealLocally(meal.copyWith(isDirty: false));
          } catch (e) { debugPrint('Erro push: $e'); }
        }
      }
      final remoteMeals = await remoteDataSource.getAll();
      if (remoteMeals.isNotEmpty) await localDataSource.cacheMeals(remoteMeals);
    } catch (e) { debugPrint('Erro geral sync: $e'); }
  }

  @override
  Future<void> syncUserProfile(String name, String email, String? photoPath) async {
    if (email.isEmpty) return;
    try {
      await _supabase.from('profiles').update({
        'name': name,
        'photo_url': photoPath,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('email', email);
    } catch (e) { debugPrint('Erro sync profile: $e'); }
  }

  @override
  Future<void> syncWeeklyPlan(String email, Map<String, Map<String, String>> localPlan) async {
    if (email.isEmpty) return;
    try {
      await _supabase.from('weekly_plans').delete().eq('user_email', email);
      final List<Map<String, dynamic>> rows = [];
      localPlan.forEach((day, mealsByType) {
        mealsByType.forEach((type, mealId) {
          rows.add({
            'user_email': email,
            'day_of_week': day,
            'meal_type': type,
            'meal_id': mealId,
          });
        });
      });
      if (rows.isNotEmpty) await _supabase.from('weekly_plans').insert(rows);
    } catch (e) { debugPrint('Erro sync plan: $e'); }
  }

  @override
  Future<Map<String, Map<String, String>>> fetchWeeklyPlan(String email) async {
    if (email.isEmpty) return {};
    try {
      final response = await _supabase
          .from('weekly_plans')
          .select()
          .eq('user_email', email);
      
      final Map<String, Map<String, String>> plan = {};
      
      for (var row in response) {
        final day = row['day_of_week'] as String;
        final type = row['meal_type'] as String;
        final mealId = row['meal_id'] as String;
        
        if (!plan.containsKey(day)) plan[day] = {};
        plan[day]![type] = mealId;
      }
      return plan;
    } catch (e) {
      debugPrint('Erro fetch plan: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      final response = await _supabase.from('profiles').select().eq('email', email).maybeSingle();
      if (response != null && response['password'] == password) return response;
    } catch (e) { debugPrint('Erro login: $e'); }
    return null;
  }

  @override
  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final existing = await _supabase.from('profiles').select().eq('email', email).maybeSingle();
      if (existing != null) return false;
      await _supabase.from('profiles').insert({
        'email': email, 'name': name, 'password': password, 'updated_at': DateTime.now().toIso8601String()
      });
      return true;
    } catch (e) { debugPrint('Erro cadastro: $e'); return false; }
  }

  @override
  Future<void> deleteUserAccount(String email) async {
    try {
      await _supabase.from('profiles').delete().eq('email', email);
    } catch (e) { throw Exception('Falha ao deletar conta'); }
  }

  @override
  Future<List<Refeicao>> getMealsPaged({
    required int page,
    required int pageSize,
    String? query,
    String? typeFilter,
  }) async {
    final allDtos = await localDataSource.getCachedMeals();
    var allEntities = allDtos.map((dto) => _mapper.toEntity(dto)).toList();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      allEntities = allEntities.where((m) => m.nome.toLowerCase().contains(q)).toList();
    }

    if (typeFilter != null && typeFilter.isNotEmpty) {
      allEntities = allEntities.where((m) => m.tipo == typeFilter).toList();
    }

    final startIndex = (page - 1) * pageSize;
    
    if (startIndex >= allEntities.length) {
      return [];
    }

    final endIndex = (startIndex + pageSize) < allEntities.length 
        ? startIndex + pageSize 
        : allEntities.length;

    return allEntities.sublist(startIndex, endIndex);
  }
}