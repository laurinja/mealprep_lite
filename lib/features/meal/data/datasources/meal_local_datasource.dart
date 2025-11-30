import '../dtos/refeicao_dto.dart';

abstract class MealLocalDataSource {
  Future<List<RefeicaoDTO>> getAllMeals();
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  @override
  Future<List<RefeicaoDTO>> getAllMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Helper para gerar URL com texto (cor de fundo verde claro, texto escuro)
    String getImg(String text) {
      // Codifica o texto para URL (espaço vira %20)
      final encoded = Uri.encodeComponent(text); 
      return 'https://placehold.co/600x400/DCFCE7/166534?text=$encoded'; 
    }

    return [
      // --- CAFÉ DA MANHÃ ---
      RefeicaoDTO(
        id: '1', nome: 'Aveia com Frutas', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Aveia', 'Leite', 'Morangos', 'Mel'],
        imageUrl: getImg('Aveia com Frutas'),
      ),
      RefeicaoDTO(
        id: '2', nome: 'Ovos Mexidos', tipo: 'Café da Manhã',
        tagIds: ['Rápido'],
        ingredienteIds: ['2 Ovos', 'Manteiga', 'Sal', 'Torrada'],
        imageUrl: getImg('Ovos Mexidos'),
      ),
      RefeicaoDTO(
        id: '3', nome: 'Panqueca de Banana', tipo: 'Café da Manhã',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Banana', 'Ovo', 'Canela', 'Aveia'],
        imageUrl: getImg('Panqueca de Banana'),
      ),
      RefeicaoDTO(
        id: '4', nome: 'Iogurte com Granola', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Iogurte', 'Granola', 'Mel'],
        imageUrl: getImg('Iogurte com Granola'),
      ),
      RefeicaoDTO(
        id: '5', nome: 'Tapioca com Queijo', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Vegetariano'],
        ingredienteIds: ['Goma de Tapioca', 'Queijo', 'Manteiga'],
        imageUrl: getImg('Tapioca com Queijo'),
      ),
      RefeicaoDTO(
        id: '6', nome: 'Smoothie Verde', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Couve', 'Abacaxi', 'Gengibre'],
        imageUrl: getImg('Smoothie Verde'),
      ),

      // --- ALMOÇO ---
      RefeicaoDTO(
        id: '7', nome: 'Salada de Grão de Bico', tipo: 'Almoço',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Grão de bico', 'Tomate', 'Pepino'],
        imageUrl: getImg('Salada de Grão de Bico'),
      ),
      RefeicaoDTO(
        id: '8', nome: 'Macarrão com Pesto', tipo: 'Almoço',
        tagIds: ['Rápido', 'Vegetariano'],
        ingredienteIds: ['Macarrão', 'Pesto', 'Parmesão'],
        imageUrl: getImg('Macarrão com Pesto'),
      ),
      RefeicaoDTO(
        id: '9', nome: 'Wrap de Frango', tipo: 'Almoço',
        tagIds: ['Rápido'],
        ingredienteIds: ['Tortilha', 'Frango', 'Alface'],
        imageUrl: getImg('Wrap de Frango'),
      ),
      RefeicaoDTO(
        id: '10', nome: 'Filé de Frango Grelhado', tipo: 'Almoço',
        tagIds: ['Saudável'],
        ingredienteIds: ['Frango', 'Batata Doce', 'Brócolis'],
        imageUrl: getImg('Frango Grelhado'),
      ),
      RefeicaoDTO(
        id: '11', nome: 'Strogonoff de Carne', tipo: 'Almoço',
        tagIds: ['Rápido'],
        ingredienteIds: ['Carne', 'Creme de Leite', 'Arroz'],
        imageUrl: getImg('Strogonoff'),
      ),
      RefeicaoDTO(
        id: '12', nome: 'Escondidinho de Abóbora', tipo: 'Almoço',
        tagIds: ['Saudável'],
        ingredienteIds: ['Abóbora', 'Carne Moída', 'Queijo'],
        imageUrl: getImg('Escondidinho'),
      ),
      RefeicaoDTO(
        id: '13', nome: 'Poke de Atum', tipo: 'Almoço',
        tagIds: ['Saudável', 'Rápido'],
        ingredienteIds: ['Arroz', 'Atum', 'Pepino', 'Manga'],
        imageUrl: getImg('Poke de Atum'),
      ),

      // --- JANTAR ---
      RefeicaoDTO(
        id: '14', nome: 'Sopa de Legumes', tipo: 'Jantar',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Batata', 'Cenoura', 'Chuchu'],
        imageUrl: getImg('Sopa de Legumes'),
      ),
      RefeicaoDTO(
        id: '15', nome: 'Peixe Grelhado', tipo: 'Jantar',
        tagIds: ['Saudável'],
        ingredienteIds: ['Tilápia', 'Limão', 'Legumes'],
        imageUrl: getImg('Peixe Grelhado'),
      ),
      RefeicaoDTO(
        id: '16', nome: 'Omelete de Forno', tipo: 'Jantar',
        tagIds: ['Rápido', 'Vegetariano'],
        ingredienteIds: ['Ovos', 'Espinafre', 'Queijo'],
        imageUrl: getImg('Omelete de Forno'),
      ),
      RefeicaoDTO(
        id: '17', nome: 'Crepioca de Frango', tipo: 'Jantar',
        tagIds: ['Rápido', 'Saudável'],
        ingredienteIds: ['Tapioca', 'Ovo', 'Frango'],
        imageUrl: getImg('Crepioca'),
      ),
      RefeicaoDTO(
        id: '18', nome: 'Sanduíche Natural', tipo: 'Jantar',
        tagIds: ['Rápido'],
        ingredienteIds: ['Pão Integral', 'Atum', 'Alface'],
        imageUrl: getImg('Sanduíche Natural'),
      ),
      RefeicaoDTO(
        id: '19', nome: 'Salada Caesar', tipo: 'Jantar',
        tagIds: ['Saudável'],
        ingredienteIds: ['Alface', 'Frango', 'Croutons'],
        imageUrl: getImg('Salada Caesar'),
      ),
      RefeicaoDTO(
        id: '20', nome: 'Macarrão de Abobrinha', tipo: 'Jantar',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Abobrinha', 'Tomate'],
        imageUrl: getImg('Macarrão Abobrinha'),
      ),
    ];
  }
}