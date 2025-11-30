import 'package:flutter/material.dart';
import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';

class MealController extends ChangeNotifier {
  final GenerateWeeklyPlanUseCase _generateUseCase;

  MealController(this._generateUseCase);

  List<Refeicao> _planoSemanal = [];
  List<Refeicao> get planoSemanal => _planoSemanal;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> gerarPlano(Set<String> preferencias) async {
    _isLoading = true;
    notifyListeners();

    try {
      _planoSemanal = await _generateUseCase(preferencias);
    } catch (e) {
      debugPrint('Erro: $e');
      _planoSemanal = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}