import '../../domain/entities/refeicao.dart';
import '../dtos/refeicao_dto.dart';

class RefeicaoMapper {
  static Refeicao toEntity(RefeicaoDTO dto) {
    return Refeicao(
      id: dto.id,
      nome: dto.nome,
      tipo: dto.tipo,
      tagIds: dto.tagIds,
    );
  }
}