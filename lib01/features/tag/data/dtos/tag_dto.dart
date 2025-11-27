class TagDTO {
  final String id;
  final String nome;

  TagDTO({
    required this.id,
    required this.nome,
  });

  factory TagDTO.fromJson(Map<String, dynamic> json) {
    return TagDTO(
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