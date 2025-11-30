import '../../domain/entities/refeicao.dart';
import '../dtos/refeicao_dto.dart';

class RefeicaoMapper {
  Refeicao toEntity(RefeicaoDTO dto) {
    return Refeicao(
      id: dto.id,
      nome: dto.nome,
      tipo: dto.tipo,
      // Agora acessamos as propriedades em camelCase do DTO
      tagIds: dto.tagIds, 
      ingredienteIds: dto.ingredienteIds,
    );
  }

  RefeicaoDTO toDto(Refeicao entity) {
    return RefeicaoDTO(
      id: entity.id,
      nome: entity.nome,
      tipo: entity.tipo,
      // Passamos os valores para o construtor atualizado (camelCase)
      tagIds: entity.tagIds,
      ingredienteIds: entity.ingredienteIds,
    );
  }
}