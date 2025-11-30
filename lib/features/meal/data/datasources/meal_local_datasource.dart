import '../dtos/refeicao_dto.dart';

abstract class MealLocalDataSource {
  Future<List<RefeicaoDTO>> getAllMeals();
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  @override
  Future<List<RefeicaoDTO>> getAllMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      RefeicaoDTO(id: '1', nome: 'Aveia com Frutas', tipo: 'Café da Manhã', tagIds: ['Rápido', 'Saudável']),
      RefeicaoDTO(id: '2', nome: 'Ovos Mexidos', tipo: 'Café da Manhã', tagIds: ['Rápido']),
      RefeicaoDTO(id: '3', nome: 'Salada de Grão de Bico', tipo: 'Almoço', tagIds: ['Saudável']),
      RefeicaoDTO(id: '4', nome: 'Macarrão com Pesto', tipo: 'Almoço', tagIds: ['Rápido', 'Vegetariano']),
      RefeicaoDTO(id: '5', nome: 'Wrap de Frango', tipo: 'Almoço', tagIds: ['Rápido']),
      RefeicaoDTO(id: '6', nome: 'Sopa de Legumes', tipo: 'Jantar', tagIds: ['Saudável', 'Vegetariano']),
      RefeicaoDTO(id: '7', nome: 'Peixe Grelhado', tipo: 'Jantar', tagIds: ['Saudável']),
    ];
  }
}