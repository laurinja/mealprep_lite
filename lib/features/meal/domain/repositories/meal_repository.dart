import '../entities/refeicao.dart';

abstract class MealRepository {
  Future<List<Refeicao>> getRefeicoes();
}