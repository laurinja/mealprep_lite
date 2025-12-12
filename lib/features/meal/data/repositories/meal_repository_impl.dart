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
  Future<List<Refeicao>> loadFromCache() async {
    final localDtos = await localDataSource.getCachedMeals();
    return localDtos.map((dto) => _mapper.toEntity(dto)).toList();
  }

  @override
  Future<List<Refeicao>> listAll() async {
    return loadFromCache();
  }

  @override
  Future<int> syncFromServer([String? userEmail]) async {
    int changes = 0;
    try {
      final localDtos = await localDataSource.getCachedMeals();
      final dirtyMeals = localDtos.where((e) => e.isDirty).toList();
      
      if (dirtyMeals.isNotEmpty) {
        for (var meal in dirtyMeals) {
          try {
            await remoteDataSource.update(meal);
            await localDataSource.updateMealLocally(meal.copyWith(isDirty: false));
            changes++;
          } catch (e) {
            debugPrint('Erro push: $e');
          }
        }
      }

      final lastSync = await localDataSource.getLastSync();
      final emailToUse = userEmail ?? '';
      final remoteMeals = await remoteDataSource.fetchRefeicoes(
        since: lastSync, 
        userEmail: emailToUse
      );
      
      if (remoteMeals.isNotEmpty) {
         await localDataSource.upsertMeals(remoteMeals);
         await localDataSource.saveLastSync(DateTime.now().toUtc());
         changes += remoteMeals.length;
      }
      
      return changes;
    } catch (e) {
      debugPrint('Erro sync: $e');
      return 0;
    }
  }

  @override
  Future<void> save(Refeicao meal) async {
    final dto = _mapper.toDto(meal);
    final dirtyDto = dto.copyWith(isDirty: true);
    await localDataSource.updateMealLocally(dirtyDto);
    syncFromServer();
  }

  @override
  Future<void> syncWeeklyPlan(String email, Map<String, Map<String, String>> localPlan) async {
    if (email.isEmpty) return;
    try {
      await _supabase.from('weekly_plans').delete().eq('user_email', email);
      final List<Map<String, dynamic>> rows = [];
      localPlan.forEach((day, mealsByType) {
        mealsByType.forEach((type, mealId) {
          rows.add({'user_email': email, 'day_of_week': day, 'meal_type': type, 'meal_id': mealId});
        });
      });
      if (rows.isNotEmpty) await _supabase.from('weekly_plans').insert(rows);
    } catch (e) { debugPrint('Erro sync plan: $e'); }
  }

  @override
  Future<Map<String, Map<String, String>>> fetchWeeklyPlan(String email) async {
    if (email.isEmpty) return {};
    try {
      final response = await _supabase.from('weekly_plans').select().eq('user_email', email);
      final Map<String, Map<String, String>> plan = {};
      for (var row in response) {
        final day = row['day_of_week'];
        final type = row['meal_type'];
        final mealId = row['meal_id'];
        if (!plan.containsKey(day)) plan[day] = {};
        plan[day]![type] = mealId;
      }
      return plan;
    } catch (e) { return {}; }
  }

  @override
  Future<List<Refeicao>> getMealsPaged({required int page, required int pageSize, String? query, String? typeFilter}) async {
    final allDtos = await localDataSource.getCachedMeals();
    var allEntities = allDtos.map((dto) => _mapper.toEntity(dto)).toList();
    if (query != null && query.isNotEmpty) {
      allEntities = allEntities.where((m) => m.nome.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (typeFilter != null) {
      allEntities = allEntities.where((m) => m.tipo == typeFilter).toList();
    }
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= allEntities.length) return [];
    final endIndex = (startIndex + pageSize) < allEntities.length ? startIndex + pageSize : allEntities.length;
    return allEntities.sublist(startIndex, endIndex);
  }
}