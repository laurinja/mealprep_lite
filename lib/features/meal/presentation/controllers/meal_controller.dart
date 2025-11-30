import 'package:flutter/material.dart';
import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../../../services/prefs_service.dart'; 

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

  Future<void> _loadSavedPlan() async {
    _isLoading = true;
    notifyListeners();

    final savedIds = _prefsService.weeklyPlanIds;
    if (savedIds.isNotEmpty) {
      final todas = await _repository.getRefeicoes();
      _planoSemanal = todas.where((r) => savedIds.contains(r.id)).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> gerarPlano(Set<String> preferencias) async {
    _isLoading = true;
    notifyListeners();

    try {
      _planoSemanal = await _generateUseCase(preferencias);
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
    await _prefsService.setWeeklyPlanIds(_planoSemanal.map((e) => e.id).toList());
    notifyListeners();
  }

  Future<void> trocarRefeicao(Refeicao atual) async {
    _isLoading = true;
    notifyListeners();
    
    final todas = await _repository.getRefeicoes();
    
    final opcoes = todas.where((r) => 
      !_planoSemanal.contains(r) && r.id != atual.id
    ).toList();

    if (opcoes.isNotEmpty) {
      final nova = (opcoes..shuffle()).first;
      final index = _planoSemanal.indexOf(atual);
      if (index != -1) {
        _planoSemanal[index] = nova;
        await _prefsService.setWeeklyPlanIds(_planoSemanal.map((e) => e.id).toList());
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
}