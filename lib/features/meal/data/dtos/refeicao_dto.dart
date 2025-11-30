class RefeicaoDTO {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tagIds; // Corrigido para camelCase
  final List<String> ingredienteIds; // Corrigido para camelCase

  RefeicaoDTO({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tagIds,
    required this.ingredienteIds,
  });

  factory RefeicaoDTO.fromJson(Map<String, dynamic> json) {
    return RefeicaoDTO(
      id: json['id'] as String,
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      // Mapeando do JSON (snake_case) para a propriedade (camelCase)
      tagIds: List<String>.from(json['tag_ids'] ?? []),
      ingredienteIds: List<String>.from(json['ingrediente_ids'] ?? []),
    );
  }
  
  // Ajustar o toJson e o Mapper correspondente também...
}