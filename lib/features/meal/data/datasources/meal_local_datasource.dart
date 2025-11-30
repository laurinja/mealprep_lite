import '../dtos/refeicao_dto.dart';

abstract class MealLocalDataSource {
  Future<List<RefeicaoDTO>> getAllMeals();
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  @override
  Future<List<RefeicaoDTO>> getAllMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      RefeicaoDTO(
        id: '1', 
        nome: 'Aveia com Frutas', 
        tipo: 'Café da Manhã', 
        tag_ids: ['Rápido', 'Saudável'], 
        ingrediente_ids: [], 
      ),
      RefeicaoDTO(
        id: '2', 
        nome: 'Ovos Mexidos', 
        tipo: 'Café da Manhã', 
        tag_ids: ['Rápido'], 
        ingrediente_ids: [],
      ),
      RefeicaoDTO(
        id: '3', 
        nome: 'Salada de Grão de Bico', 
        tipo: 'Almoço', 
        tag_ids: ['Saudável'], 
        ingrediente_ids: [],
      ),
      RefeicaoDTO(
        id: '4', 
        nome: 'Macarrão com Pesto', 
        tipo: 'Almoço', 
        tag_ids: ['Rápido', 'Vegetariano'], 
        ingrediente_ids: [],
      ),
      RefeicaoDTO(
        id: '5', 
        nome: 'Wrap de Frango', 
        tipo: 'Almoço', 
        tag_ids: ['Rápido'], 
        ingrediente_ids: [],
      ),
      RefeicaoDTO(
        id: '6', 
        nome: 'Sopa de Legumes', 
        tipo: 'Jantar', 
        tag_ids: ['Saudável', 'Vegetariano'], 
        ingrediente_ids: [],
      ),
      RefeicaoDTO(
        id: '7', 
        nome: 'Peixe Grelhado', 
        tipo: 'Jantar', 
        tag_ids: ['Saudável'], 
        ingrediente_ids: [],
      ),
    ];
  }
}