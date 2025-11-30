import '../entities/refeicao.dart';
import '../repositories/meal_repository.dart';
import 'dart:math';

class GenerateWeeklyPlanUseCase {
  final MealRepository repository;

  GenerateWeeklyPlanUseCase(this.repository);

  Future<List<Refeicao>> call(Set<String> preferencias) async {
    final allMeals = await repository.getRefeicoes();

    List<Refeicao> filtradas;
    if (preferencias.isEmpty) {
      filtradas = allMeals;
    } else {
      filtradas = allMeals.where((meal) {
        return meal.tagIds.any((tag) => preferencias.contains(tag));
      }).toList();
    }

    if (filtradas.isEmpty) {
      return [];
    }

    final Map<String, List<Refeicao>> refeicoesPorTipo = {};
    for (var meal in filtradas) {
      if (!refeicoesPorTipo.containsKey(meal.tipo)) {
        refeicoesPorTipo[meal.tipo] = [];
      }
      refeicoesPorTipo[meal.tipo]!.add(meal);
    }

    final List<Refeicao> planoFinal = [];
    final random = Random();

    for (var tipo in refeicoesPorTipo.keys) {
      final opcoesDoTipo = refeicoesPorTipo[tipo]!;
      if (opcoesDoTipo.isNotEmpty) {
        final escolhida = opcoesDoTipo[random.nextInt(opcoesDoTipo.length)];
        planoFinal.add(escolhida);
      }
    }
    

    return planoFinal;
  }
}