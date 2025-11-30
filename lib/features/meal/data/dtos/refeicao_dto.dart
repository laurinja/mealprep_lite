class RefeicaoDTO {
  final String id;
  final String nome;
  final String tipo;
  final List<String> tagIds;

  RefeicaoDTO({
    required this.id, 
    required this.nome, 
    required this.tipo, 
    required this.tagIds
  });
}