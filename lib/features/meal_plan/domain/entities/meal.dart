import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String nome;
  final String tipo;
  final Set<String> tags;

  const Meal({
    required this.nome,
    required this.tipo,
    required this.tags,
  });

  @override
  List<Object?> get props => [nome, tipo, tags];
}