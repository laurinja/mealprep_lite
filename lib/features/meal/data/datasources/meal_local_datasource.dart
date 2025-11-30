import '../dtos/refeicao_dto.dart';

abstract class MealLocalDataSource {
  Future<List<RefeicaoDTO>> getAllMeals();
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  @override
  Future<List<RefeicaoDTO>> getAllMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      // --- CAFÉ DA MANHÃ ---
      RefeicaoDTO(
        id: '1', nome: 'Aveia com Frutas', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Aveia', 'Leite ou Água', 'Morangos', 'Mel'],
        imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '2', nome: 'Ovos Mexidos', tipo: 'Café da Manhã',
        tagIds: ['Rápido'],
        ingredienteIds: ['2 Ovos', 'Manteiga', 'Sal', 'Torrada'],
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414395d8?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '3', nome: 'Panqueca de Banana', tipo: 'Café da Manhã',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Banana', 'Ovo', 'Canela', 'Aveia'],
        imageUrl: 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '4', nome: 'Iogurte com Granola', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Iogurte', 'Granola', 'Mel'],
        imageUrl: 'https://images.unsplash.com/photo-1511690656952-34342d5c71df?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '5', nome: 'Pão de Queijo', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Vegetariano'],
        ingredienteIds: ['Polvilho', 'Queijo', 'Ovo', 'Leite'],
        imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '6', nome: 'Suco Verde Detox', tipo: 'Café da Manhã',
        tagIds: ['Rápido', 'Saudável', 'Vegetariano'],
        ingredienteIds: ['Couve', 'Abacaxi', 'Gengibre'],
        imageUrl: 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=500&q=80',
      ),

      // --- ALMOÇO ---
      RefeicaoDTO(
        id: '7', nome: 'Salada de Grão de Bico', tipo: 'Almoço',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Grão de bico', 'Tomate', 'Pepino'],
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '8', nome: 'Macarrão ao Pesto', tipo: 'Almoço',
        tagIds: ['Rápido', 'Vegetariano'],
        ingredienteIds: ['Macarrão', 'Pesto', 'Parmesão'],
        imageUrl: 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '9', nome: 'Wrap de Frango', tipo: 'Almoço',
        tagIds: ['Rápido'],
        ingredienteIds: ['Tortilha', 'Frango', 'Alface'],
        imageUrl: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '10', nome: 'Frango Grelhado', tipo: 'Almoço',
        tagIds: ['Saudável'],
        ingredienteIds: ['Frango', 'Batata Doce', 'Legumes'],
        imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '11', nome: 'Strogonoff', tipo: 'Almoço',
        tagIds: ['Rápido'],
        ingredienteIds: ['Carne', 'Creme de Leite', 'Arroz'],
        imageUrl: 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '12', nome: 'Escondidinho', tipo: 'Almoço',
        tagIds: ['Saudável'],
        ingredienteIds: ['Abóbora', 'Carne Moída', 'Queijo'],
        imageUrl: 'https://images.unsplash.com/photo-1604908177453-7462950a6a3b?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '13', nome: 'Poke Bowl', tipo: 'Almoço',
        tagIds: ['Saudável', 'Rápido'],
        ingredienteIds: ['Arroz', 'Atum/Salmão', 'Pepino', 'Manga'],
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
      ),

      // --- JANTAR ---
      RefeicaoDTO(
        id: '14', nome: 'Sopa de Legumes', tipo: 'Jantar',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Batata', 'Cenoura', 'Chuchu'],
        imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '15', nome: 'Peixe com Legumes', tipo: 'Jantar',
        tagIds: ['Saudável'],
        ingredienteIds: ['Tilápia', 'Limão', 'Cenoura'],
        imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '16', nome: 'Omelete Recheado', tipo: 'Jantar',
        tagIds: ['Rápido', 'Vegetariano'],
        ingredienteIds: ['Ovos', 'Espinafre', 'Queijo'],
        imageUrl: 'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '17', nome: 'Crepioca', tipo: 'Jantar',
        tagIds: ['Rápido', 'Saudável'],
        ingredienteIds: ['Tapioca', 'Ovo', 'Frango'],
        imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '18', nome: 'Sanduíche Natural', tipo: 'Jantar',
        tagIds: ['Rápido'],
        ingredienteIds: ['Pão Integral', 'Atum', 'Alface'],
        imageUrl: 'https://images.unsplash.com/photo-1553909489-cd47e3321174?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '19', nome: 'Salada Caesar', tipo: 'Jantar',
        tagIds: ['Saudável'],
        ingredienteIds: ['Alface', 'Frango', 'Croutons'],
        imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=500&q=80',
      ),
      RefeicaoDTO(
        id: '20', nome: 'Macarrão Abobrinha', tipo: 'Jantar',
        tagIds: ['Saudável', 'Vegetariano'],
        ingredienteIds: ['Abobrinha fatiada', 'Tomate'],
        imageUrl: 'https://images.unsplash.com/photo-1620916297397-a4a5402a3c6c?w=500&q=80',
      ),
    ];
  }
}