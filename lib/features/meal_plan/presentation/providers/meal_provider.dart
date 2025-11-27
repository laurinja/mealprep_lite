import 'package:flutter/material.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/generate_meal_plan.dart';

class MealProvider extends ChangeNotifier {
  final GenerateMealPlan generateMealPlanUseCase;

  MealProvider({required this.generateMealPlanUseCase});

  List<Meal> _meals = [];
  Set<String> _selectedPreferences = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Meal> get meals => _meals;
  Set<String> get selectedPreferences => _selectedPreferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void togglePreference(String preference) {
    if (_selectedPreferences.contains(preference)) {
      _selectedPreferences.remove(preference);
    } else {
      _selectedPreferences.add(preference);
    }
    notifyListeners();
  }

  Future<void> generatePlan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await generateMealPlanUseCase(_selectedPreferences);

    result.fold(
      (failure) => _errorMessage = 'Erro ao gerar plano de refeições',
      (meals) => _meals = meals,
    );

    _isLoading = false;
    notifyListeners();
  }
}