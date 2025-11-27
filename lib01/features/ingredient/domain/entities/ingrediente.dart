class Ingrediente {
  final String id;
  final String nome;

  Ingrediente({
    required this.id,
    required this.nome,
  }) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome do ingrediente não pode ser vazio');
    }
  }

  @override
  String toString() {
    return 'Ingrediente(id: $id, nome: $nome)';
  }
}