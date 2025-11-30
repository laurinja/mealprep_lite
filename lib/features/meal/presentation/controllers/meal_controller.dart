import 'package:flutter/material.dart';
import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';
import '../../domain/repositories/meal_repository.dart';
import 'package:mealprep_lite/services/prefs_service.dart';

class MealController extends ChangeNotifier {
  final GenerateWeeklyPlanUseCase _generateUseCase;
  final MealRepository _repository;
  final PrefsService _prefsService;

  MealController(this._generateUseCase, this._repository, this._prefsService) {
    _loadSavedPlan();
  }

  List<Refeicao> _planoSemanal = [];
  List<Refeicao> get planoSemanal => _planoSemanal;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Lógica de Ordenação (Novo) ---
  void _sortMeals() {
    // Define a ordem cronológica
    const order = {
      'Café da Manhã': 1,
      'Almoço': 2,
      'Jantar': 3,
    };

    _planoSemanal.sort((a, b) {
      final weightA = order[a.tipo] ?? 99; // 99 vai para o final se não for conhecido
      final weightB = order[b.tipo] ?? 99;
      return weightA.compareTo(weightB);
    });
  }
  // ---------------------------------

  Future<void> _loadSavedPlan() async {
    _isLoading = true;
    notifyListeners();

    final savedIds = _prefsService.weeklyPlanIds;
    if (savedIds.isNotEmpty) {
      final todas = await _repository.getRefeicoes();
      _planoSemanal = todas.where((r) => savedIds.contains(r.id)).toList();
      _sortMeals(); // Ordena ao carregar
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> gerarPlano(Set<String> preferencias) async {
    _isLoading = true;
    notifyListeners();

    try {
      _planoSemanal = await _generateUseCase(preferencias);
      _sortMeals(); // Ordena ao gerar
      await _prefsService.setWeeklyPlanIds(_planoSemanal.map((e) => e.id).toList());
    } catch (e) {
      debugPrint('Erro: $e');
      _planoSemanal = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removerRefeicao(String id) async {
    _planoSemanal.removeWhere((r) => r.id == id);
    // Não precisa reordenar ao remover, a ordem relativa mantém
    await _prefsService.setWeeklyPlanIds(_planoSemanal.map((e) => e.id).toList());
    notifyListeners();
  }

  // Modificado para retornar o nome da nova refeição (para feedback)
  Future<String?> trocarRefeicao(Refeicao atual) async {
    _isLoading = true;
    notifyListeners();
    
    String? novoNome;
    
    final todas = await _repository.getRefeicoes();
    
    // Tenta achar substituto do MESMO TIPO (ex: troca Almoço por Almoço)
    final opcoes = todas.where((r) => 
      !_planoSemanal.contains(r) && 
      r.id != atual.id &&
      r.tipo == atual.tipo // Tenta manter a consistência do horário
    ).toList();

    // Se não tiver do mesmo tipo, pega qualquer um disponível (fallback)
    final opcoesFinais = opcoes.isNotEmpty 
        ? opcoes 
        : todas.where((r) => !_planoSemanal.contains(r) && r.id != atual.id).toList();

    if (opcoesFinais.isNotEmpty) {
      final nova = (opcoesFinais..shuffle()).first;
      final index = _planoSemanal.indexOf(atual);
      if (index != -1) {
        _planoSemanal[index] = nova;
        _sortMeals(); // Garante a ordem novamente
        await _prefsService.setWeeklyPlanIds(_planoSemanal.map((e) => e.id).toList());
        novoNome = nova.nome;
      }
    }
    
    _isLoading = false;
    notifyListeners();
    return novoNome;
  }
}