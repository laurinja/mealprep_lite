import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/refeicao_dto.dart';

class MealRemoteDataSource {
  final SupabaseClient client;

  MealRemoteDataSource(this.client);

  Future<List<RefeicaoDTO>> getAll() async {
    try {
      final response = await client.from('refeicoes').select();
      return (response as List).map((e) => RefeicaoDTO.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar refeições remotas: $e');
    }
  }

  Future<void> update(RefeicaoDTO refeicao) async {
    final data = refeicao.toJson();
    data.remove('is_dirty'); 
    
    await client.from('refeicoes').upsert(data);
  }
}