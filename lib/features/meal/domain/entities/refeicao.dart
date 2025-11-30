class Refeicao {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tagIds;
  final List<String> ingredienteIds;

  Refeicao({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.tagIds,
    required this.ingredienteIds,
  }) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome da refeição não pode ser vazio');
    }
  }

  @override
  String toString() {
    return 'Refeicao(id: $id, nome: $nome, tipo: $tipo, tags: ${tagIds.length}, ingredientes: ${ingredienteIds.length})';
  }
}