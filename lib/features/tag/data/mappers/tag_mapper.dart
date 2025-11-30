import '../../domain/entities/tag.dart';
import '../dtos/tag_dto.dart';

class TagMapper {
  
  Tag toEntity(TagDTO dto) {
    return Tag(
      id: dto.id,
      nome: dto.nome,
    );
  }

  TagDTO toDto(Tag entity) {
    return TagDTO(
      id: entity.id,
      nome: entity.nome,
    );
  }
}