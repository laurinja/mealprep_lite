import '../../domain/entities/refeicao.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_datasource.dart';
import '../mappers/refeicao_mapper.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDataSource dataSource;

  MealRepositoryImpl(this.dataSource);

  @override
  Future<List<Refeicao>> getRefeicoes() async {
    final dtos = await dataSource.getAllMeals();
    return dtos.map(RefeicaoMapper.toEntity).toList();
  }
}