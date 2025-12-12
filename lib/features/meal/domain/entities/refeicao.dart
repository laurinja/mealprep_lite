class Refeicao {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tagIds;
  final List<String> ingredienteIds;
  final String? imageUrl; 
  final String? createdBy;

  Refeicao({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tagIds,
    required this.ingredienteIds,
    this.imageUrl,
    this.createdBy,
  }) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome da refeição não pode ser vazio');
    }
  }
}