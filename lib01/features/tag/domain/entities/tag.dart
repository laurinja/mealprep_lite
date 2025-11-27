class Tag {
  final String id;
  final String nome;

  Tag({
    required this.id,
    required this.nome,
  }) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome da tag não pode ser vazio');
    }
  }

  @override
  String toString() {
    return 'Tag(id: $id, nome: $nome)';
  }
}