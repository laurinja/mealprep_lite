import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/refeicao_dto.dart';

class MealRemoteDataSource {
  final SupabaseClient client;

  MealRemoteDataSource(this.client);

  Future<List<RefeicaoDTO>> fetchRefeicoes({DateTime? since, required String userEmail}) async {
    try {
      var query = client.from('refeicoes').select().or('created_by.is.null,created_by.eq.$userEmail');

      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }
      
      if (kDebugMode) {
        print('📡 Remote: Buscando refeições para $userEmail desde: ${since ?? "INÍCIO"}');
      }

      final response = await query;
      final data = response as List;

      return data.map((e) => RefeicaoDTO.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) print('❌ Erro Remote Fetch: $e');
      return [];
    }
  }

  Future<void> update(RefeicaoDTO refeicao) async {
    final data = refeicao.toJson();
    data.remove('is_dirty'); 
    data['updated_at'] = DateTime.now().toUtc().toIso8601String();

    try {
      await client.from('refeicoes').upsert(data);
    } catch (e) {
      if (kDebugMode) print('❌ Erro Remote Update: $e');
      throw Exception('Falha ao salvar no servidor');
    }
  }
  
  Future<List<RefeicaoDTO>> getAll() async {
    return []; 
  }
}