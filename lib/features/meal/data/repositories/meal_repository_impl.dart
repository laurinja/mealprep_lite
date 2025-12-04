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
      // Nota: Não atualizamos a senha aqui para não sobrescrever com vazio durante o sync normal
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

  // --- IMPLEMENTAÇÃO DA AUTENTICAÇÃO REAL ---

  @override
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      // Busca o usuário pelo email
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('email', email)
          .maybeSingle(); // Retorna null se não encontrar

      if (response == null) return null; // Usuário não existe

      // Verifica a senha (Em produção real, use Auth do Supabase ou Hash, aqui é didático)
      if (response['password'] == password) {
        return response; // Retorna os dados do usuário
      }
    } catch (e) {
      debugPrint('Erro login: $e');
    }
    return null; // Senha errada ou erro
  }

  @override
  Future<bool> registerUser(String name, String email, String password) async {
    try {
      // Verifica se já existe
      final existing = await _supabase.from('profiles').select().eq('email', email).maybeSingle();
      if (existing != null) return false; // Já existe

      // Cria novo
      await _supabase.from('profiles').insert({
        'email': email,
        'name': name,
        'password': password, // Salvando no banco
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Erro cadastro: $e');
      return false;
    }
  }

  @override
  Future<void> deleteUserAccount(String email) async {
    try {
      // O banco tem "ON DELETE CASCADE", então apagar o perfil apaga os planos também
      await _supabase.from('profiles').delete().eq('email', email);
    } catch (e) {
      debugPrint('Erro ao deletar conta: $e');
      throw Exception('Não foi possível deletar a conta online.');
    }
  }
}