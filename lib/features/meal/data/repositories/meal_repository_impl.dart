import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import necessário
import '../../domain/entities/refeicao.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_datasource.dart';
import '../datasources/meal_remote_datasource.dart';
import '../mappers/refeicao_mapper.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDataSource localDataSource;
  final MealRemoteDataSource remoteDataSource;
  final RefeicaoMapper _mapper = RefeicaoMapper();
  // Cliente Supabase direto para operações extras (poderia estar no datasource, mas simplificamos aqui)
  final SupabaseClient _supabase = Supabase.instance.client;

  MealRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<List<Refeicao>> getRefeicoes() async {
    final localDtos = await localDataSource.getCachedMeals();
    return localDtos.map((dto) => _mapper.toEntity(dto)).toList();
  }

  @override
  Future<void> syncRefeicoes() async {
    // ... (Mantenha sua lógica de sync de catálogo existente aqui) ...
    // Vou resumir para focar nas novidades:
    try {
      final remoteMeals = await remoteDataSource.getAll();
      if (remoteMeals.isNotEmpty) {
        await localDataSource.cacheMeals(remoteMeals);
      }
    } catch (e) {
      debugPrint('Sync Refeicoes Error: $e');
    }
  }

  // --- 1. Sincronizar Perfil ---
  @override
  Future<void> syncUserProfile(String name, String email, String? photoPath) async {
    if (email.isEmpty) return;
    try {
      await _supabase.from('profiles').upsert({
        'email': email,
        'name': name,
        'photo_url': photoPath, // Em um app real, faríamos upload da imagem para o Storage primeiro
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Perfil sincronizado com Supabase');
    } catch (e) {
      debugPrint('❌ Erro ao sincronizar perfil: $e');
    }
  }

  // --- 2. Sincronizar Plano Semanal ---
  @override
  Future<void> syncWeeklyPlan(String email, Map<String, Map<String, String>> localPlan) async {
    if (email.isEmpty) return;
    
    try {
      // Estratégia simples: Apagar o plano antigo do usuário e subir o novo
      // (Para produção, faríamos um diff mais inteligente)
      await _supabase.from('weekly_plans').delete().eq('user_email', email);

      final List<Map<String, dynamic>> rowsToInsert = [];

      localPlan.forEach((day, mealsByType) {
        mealsByType.forEach((type, mealId) {
          rowsToInsert.add({
            'user_email': email,
            'day_of_week': day,
            'meal_type': type,
            'meal_id': mealId,
          });
        });
      });

      if (rowsToInsert.isNotEmpty) {
        await _supabase.from('weekly_plans').insert(rowsToInsert);
      }
      debugPrint('✅ Plano semanal sincronizado (${rowsToInsert.length} itens)');
    } catch (e) {
      debugPrint('❌ Erro ao sincronizar plano: $e');
    }
  }
}