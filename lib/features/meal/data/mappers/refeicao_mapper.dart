import '../../domain/entities/refeicao.dart';
import '../dtos/refeicao_dto.dart';

class RefeicaoMapper {
  Refeicao toEntity(RefeicaoDTO dto) {
    return Refeicao(
      id: dto.id,
      nome: dto.nome,
      tipo: dto.tipo,
      tagIds: dto.tagIds,
      ingredienteIds: dto.ingredienteIds,
      imageUrl: dto.imageUrl,
    );
  }

  RefeicaoDTO toDto(Refeicao entity) {
    return RefeicaoDTO(
      id: entity.id,
      nome: entity.nome,
      tipo: entity.tipo,
      tagIds: entity.tagIds,
      ingredienteIds: entity.ingredienteIds,
      imageUrl: entity.imageUrl,
    );
  }
}