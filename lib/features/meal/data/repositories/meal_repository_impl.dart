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
    
    return localDtos
        .where((dto) => dto.deletedAt == null) 
        .map((dto) => _mapper.toEntity(dto))
        .toList();
  }

  @override
  Future<List<Refeicao>> listAll() async {
    return loadFromCache();
  }

  @override
  Future<int> syncFromServer([String? userEmail]) async {
    int totalChanges = 0;
    
    try {
      final localDtos = await localDataSource.getCachedMeals();
      final dirtyMeals = localDtos.where((e) => e.isDirty).toList();
      
      if (dirtyMeals.isNotEmpty) {
        final pushedCount = await remoteDataSource.upsertRefeicoes(dirtyMeals);
        
        if (pushedCount > 0) {
          final cleanedMeals = dirtyMeals.map((m) => m.copyWith(isDirty: false)).toList();
          await localDataSource.upsertMeals(cleanedMeals);
          if (kDebugMode) print('✅ Repository: $pushedCount itens sincronizados e limpos localmente.');
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
         final safeTime = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
         
         await localDataSource.saveLastSync(safeTime);
         
         totalChanges += remoteMeals.length;
         if (kDebugMode) print('⬇️ Repository: Baixados $totalChanges novos itens.');
      }
      
      return totalChanges;

    } catch (e) {
      if (kDebugMode) print('❌ Erro Fatal no Sync: $e');
      return 0;
    }
  }

  @override
  Future<void> save(Refeicao meal) async {
    final dto = _mapper.toDto(meal);
    final dirtyDto = dto.copyWith(isDirty: true);
    await localDataSource.updateMealLocally(dirtyDto);
    
    syncFromServer(meal.createdBy);
  }

  @override
  Future<void> syncWeeklyPlan(String email, Map<String, Map<String, String>> localPlan) async {
    if (email.isEmpty) return;
    
    try {
      final currentRemotePlan = await fetchWeeklyPlan(email);

      for (var day in currentRemotePlan.keys) {
        final remoteDaySlots = currentRemotePlan[day]!;
        final localDaySlots = localPlan[day];

        for (var type in remoteDaySlots.keys) {
          if (localDaySlots == null || !localDaySlots.containsKey(type)) {
            await _supabase.from('weekly_plans')
                .update({ 'deleted_at': DateTime.now().toIso8601String() })
                .match({
                  'user_email': email,
                  'day_of_week': day,
                  'meal_type': type
                })
                .filter('deleted_at', 'is', 'null');
          }
        }
      }

      final List<Map<String, dynamic>> rowsToUpsert = [];
      
      localPlan.forEach((day, mealsByType) {
        mealsByType.forEach((type, mealId) {
          rowsToUpsert.add({
            'user_email': email, 
            'day_of_week': day, 
            'meal_type': type, 
            'meal_id': mealId,
            'deleted_at': null
          });
        });
      });

      if (rowsToUpsert.isNotEmpty) {
        await _supabase.from('weekly_plans').upsert(
          rowsToUpsert, 
          onConflict: 'user_email, day_of_week, meal_type'
        );
      }
      
    } catch (e) { 
      debugPrint('Erro sync plan: $e'); 
    }
  }

  @override
  Future<Map<String, Map<String, String>>> fetchWeeklyPlan(String email) async {
    if (email.isEmpty) return {};
    
    try {
      final response = await _supabase
          .from('weekly_plans')
          .select()
          .eq('user_email', email)
          .filter('deleted_at', 'is', 'null');
      
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
  Future<List<Refeicao>> getMealsPaged({
    required int page, 
    required int pageSize, 
    String? query, 
    String? typeFilter
  }) async {
    final allDtos = await localDataSource.getCachedMeals();
    
    var allEntities = allDtos.map((dto) => _mapper.toEntity(dto)).toList();

    allEntities = allEntities.where((m) => m.deletedAt == null).toList();

    if (query != null && query.isNotEmpty) {
      allEntities = allEntities.where((m) => m.nome.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (typeFilter != null) {
      allEntities = allEntities.where((m) => m.tipo == typeFilter).toList();
    }

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= allEntities.length) return [];
    
    final endIndex = (startIndex + pageSize) < allEntities.length 
        ? startIndex + pageSize 
        : allEntities.length;
        
    return allEntities.sublist(startIndex, endIndex);
  }
}