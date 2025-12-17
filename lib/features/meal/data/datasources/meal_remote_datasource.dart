import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/refeicao_dto.dart';

class MealRemoteDataSource {
  final SupabaseClient client;

  MealRemoteDataSource(this.client);

  Future<List<RefeicaoDTO>> fetchRefeicoes({DateTime? since, required String userEmail}) async {
    try {
      final filterString = 'created_by.is.null,created_by.eq."$userEmail"';
      
      var query = client.from('refeicoes').select().or(filterString);

      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }
      
      if (kDebugMode) {
        print('📡 Remote: Buscando com filtro: $filterString');
      }

      final response = await query;
      final data = response as List;

      if (kDebugMode) {
        print('📡 Remote: Download concluído. ${data.length} itens encontrados.');
      }

      return data.map((e) => RefeicaoDTO.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) print('❌ Erro Remote Fetch: $e');
      return [];
    }
  }

  Future<int> upsertRefeicoes(List<RefeicaoDTO> meals) async {
    if (meals.isEmpty) return 0;

    final List<Map<String, dynamic>> batchData = meals.map((m) {
      final json = m.toJson();
      json.remove('is_dirty'); 
      return json;
    }).toList();

    try {
      if (kDebugMode) print('⬆️ Remote: Enviando ${meals.length} itens...');
      
      await client.from('refeicoes').upsert(batchData).select();
      
      return meals.length;
    } catch (e) {
      if (kDebugMode) print('❌ Erro Remote Batch Upsert: $e');
      return 0;
    }
  }

  Future<void> update(RefeicaoDTO refeicao) async {
    await upsertRefeicoes([refeicao]);
  }
  
  Future<List<RefeicaoDTO>> getAll() async {
    return []; 
  }
}