class IngredienteDTO {
  final String id;
  final String nome;

  IngredienteDTO({
    required this.id,
    required this.nome,
  });

  factory IngredienteDTO.fromJson(Map<String, dynamic> json) {
    return IngredienteDTO(
      id: json['id'] as String,
      nome: json['nome'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}