import '../../domain/entities/refeicao.dart';
import '../dtos/refeicao_dto.dart';

class RefeicaoMapper {
  
  Refeicao toEntity(RefeicaoDTO dto) {
    return Refeicao(
      id: dto.id,
      nome: dto.nome,
      tipo: dto.tipo,
      tagIds: dto.tag_ids,
      ingredienteIds: dto.ingrediente_ids,
    );
  }

  RefeicaoDTO toDto(Refeicao entity) {
    return RefeicaoDTO(
      id: entity.id,
      nome: entity.nome,
      tipo: entity.tipo,
      tag_ids: entity.tagIds,
      ingrediente_ids: entity.ingredienteIds,
    );
  }
}