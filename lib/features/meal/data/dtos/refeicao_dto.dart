class RefeicaoDTO {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tagIds;
  final List<String> ingredienteIds;
  final String? imageUrl;
  final bool isDirty; // Controle local de sincronização

  RefeicaoDTO({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tagIds,
    required this.ingredienteIds,
    this.imageUrl,
    this.isDirty = false,
  });

  factory RefeicaoDTO.fromJson(Map<String, dynamic> json) {
    return RefeicaoDTO(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? '',
      // Garante conversão segura de listas JSON
      tagIds: List<String>.from(json['tag_ids'] ?? []),
      ingredienteIds: List<String>.from(json['ingrediente_ids'] ?? []),
      imageUrl: json['image_url'],
      isDirty: json['is_dirty'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'tag_ids': tagIds,
      'ingrediente_ids': ingredienteIds,
      'image_url': imageUrl,
      'is_dirty': isDirty,
    };
  }

  RefeicaoDTO copyWith({bool? isDirty}) {
    return RefeicaoDTO(
      id: id,
      nome: nome,
      tipo: tipo,
      tagIds: tagIds,
      ingredienteIds: ingredienteIds,
      imageUrl: imageUrl,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}