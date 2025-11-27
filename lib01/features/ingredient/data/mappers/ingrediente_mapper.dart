import '../../domain/entities/ingrediente.dart';
import '../dtos/ingrediente_dto.dart';

class IngredienteMapper {
  
  Ingrediente toEntity(IngredienteDTO dto) {
    return Ingrediente(
      id: dto.id,
      nome: dto.nome,
    );
  }

  IngredienteDTO toDto(Ingrediente entity) {
    return IngredienteDTO(
      id: entity.id,
      nome: entity.nome,
    );
  }
}