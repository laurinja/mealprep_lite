class RefeicaoDTO {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tagIds;
  final List<String> ingredienteIds;
  final String? imageUrl;
  final bool isDirty;
  final DateTime? updatedAt;
  final String? createdBy;
  final DateTime? deletedAt;

  RefeicaoDTO({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tagIds,
    required this.ingredienteIds,
    this.imageUrl,
    this.isDirty = false,
    this.updatedAt,
    this.createdBy,
    this.deletedAt,
  });

  factory RefeicaoDTO.fromJson(Map<String, dynamic> json) {
    return RefeicaoDTO(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? '',
      tagIds: List<String>.from(json['tag_ids'] ?? []),
      ingredienteIds: List<String>.from(json['ingrediente_ids'] ?? []),
      imageUrl: json['image_url'],
      isDirty: json['is_dirty'] ?? false,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
      createdBy: json['created_by'],
      deletedAt: json['deleted_at'] != null 
          ? DateTime.tryParse(json['deleted_at'].toString()) 
          : null,
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
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'created_by': createdBy,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  RefeicaoDTO copyWith({bool? isDirty, DateTime? updatedAt, DateTime? deletedAt}) {
    return RefeicaoDTO(
      id: id,
      nome: nome,
      tipo: tipo,
      tagIds: tagIds,
      ingredienteIds: ingredienteIds,
      imageUrl: imageUrl,
      isDirty: isDirty ?? this.isDirty,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}