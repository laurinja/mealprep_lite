import '../entities/refeicao.dart';
import '../repositories/meal_repository.dart';

class GenerateWeeklyPlanUseCase {
  final MealRepository repository;

  GenerateWeeklyPlanUseCase(this.repository);

  Future<List<Refeicao>> call(Set<String> preferencias) async {
    final todasRefeicoes = await repository.getRefeicoes();
    
    if (preferencias.isEmpty) {
      return (todasRefeicoes..shuffle()).take(3).toList();
    }

    final filtradas = todasRefeicoes.where((refeicao) {
      return preferencias.every((pref) => refeicao.tagIds.contains(pref));
    }).toList();
    return (filtradas..shuffle()).take(3).toList();
  }
}