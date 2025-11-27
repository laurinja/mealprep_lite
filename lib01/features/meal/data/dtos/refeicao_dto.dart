class RefeicaoDTO {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tag_ids;
  final List<String> ingrediente_ids;

  RefeicaoDTO({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tag_ids,
    required this.ingrediente_ids,
  });

  factory RefeicaoDTO.fromJson(Map<String, dynamic> json) {
    return RefeicaoDTO(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      tag_ids: List<String>.from(json['tag_ids'] ?? []),
      ingrediente_ids: List<String>.from(json['ingrediente_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'tag_ids': tag_ids,
      'ingrediente_ids': ingrediente_ids,
    };
  }
}