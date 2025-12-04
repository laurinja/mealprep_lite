import 'package:flutter/material.dart';
import 'dart:math';
import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';
import '../../domain/repositories/meal_repository.dart';
import 'package:mealprep_lite/services/prefs_service.dart';
import '../../../../core/constants/meal_types.dart';

class MealController extends ChangeNotifier {
  final GenerateWeeklyPlanUseCase _generateUseCase;
  final MealRepository _repository;
  final PrefsService _prefsService;

  static const daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  
  Map<String, Map<String, Refeicao>> _weeklyPlan = {};
  Map<String, Map<String, Refeicao>> get weeklyPlan => _weeklyPlan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MealController(this._generateUseCase, this._repository, this._prefsService) {
    _loadSavedPlan();
  }

  Future<void> _loadSavedPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. SINCRONIZA O CATÁLOGO (Esta é a correção!)
      // Baixa as novas fotos/pratos do Supabase e atualiza o cache local
      await _repository.syncRefeicoes(); 

      // 2. Agora busca do cache (que já estará atualizado)
      final allMeals = await _repository.getRefeicoes();
      final savedMap = _prefsService.getWeeklyPlanMap();
      
      _weeklyPlan = {};
      
      for (var day in daysOfWeek) {
        if (savedMap.containsKey(day)) {
          _weeklyPlan[day] = {};
          savedMap[day]!.forEach((type, id) {
            try {
              final meal = allMeals.firstWhere((m) => m.id == id);
              _weeklyPlan[day]![type] = meal;
            } catch (_) {}
          });
        }
      }
      
      // 3. Sincroniza dados do usuário
      _syncWithCloud();

    } catch (e) {
      debugPrint('Erro ao carregar plano: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODOS DE GERAÇÃO (MANTIDOS IGUAIS) ---

  Future<void> generateDay(String day, Set<String> preferences) async {
    _isLoading = true;
    notifyListeners();
    try {
      final allMeals = await _repository.getRefeicoes();
      var candidates = allMeals;
      if (preferences.isNotEmpty) {
        candidates = allMeals.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      if (candidates.isEmpty) candidates = allMeals;

      if (!_weeklyPlan.containsKey(day)) _weeklyPlan[day] = {};
      final random = Random();

      for (var type in MealTypes.values) {
        final options = candidates.where((m) => m.tipo == type).toList();
        if (options.isNotEmpty) {
          _weeklyPlan[day]![type] = options[random.nextInt(options.length)];
        }
      }
      await _saveLocalAndSync();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateFullWeek(Set<String> preferences) async {
    _isLoading = true;
    notifyListeners();
    try {
      final allMeals = await _repository.getRefeicoes();
      var candidates = allMeals;
      if (preferences.isNotEmpty) {
        candidates = allMeals.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      if (candidates.isEmpty) candidates = allMeals;

      _weeklyPlan = {};
      for (var day in daysOfWeek) {
        _weeklyPlan[day] = {};
      }

      for (var type in MealTypes.values) {
        final options = candidates.where((m) => m.tipo == type).toList();
        if (options.isNotEmpty) {
          List<Refeicao> distribution = [];
          while (distribution.length < daysOfWeek.length) {
            final shuffled = List<Refeicao>.from(options)..shuffle();
            distribution.addAll(shuffled);
          }
          for (int i = 0; i < daysOfWeek.length; i++) {
            _weeklyPlan[daysOfWeek[i]]![type] = distribution[i];
          }
        }
      }
      await _saveLocalAndSync();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- OUTROS MÉTODOS (REFRESH, AUTH...) ---

  Future<void> regenerateSlot(String day, String type, Set<String> preferences) async {
    notifyListeners();
    try {
      final allMeals = await _repository.getRefeicoes();
      var candidates = allMeals.where((m) => m.tipo == type).toList();
      if (preferences.isNotEmpty) {
        candidates = candidates.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      final currentMeal = _weeklyPlan[day]?[type];
      if (currentMeal != null) candidates.removeWhere((m) => m.id == currentMeal.id);
      
      if (candidates.isEmpty) {
         candidates = allMeals.where((m) => m.tipo == type).toList();
         if (candidates.length == 1 && candidates.first.id == currentMeal?.id) return;
      }

      if (candidates.isNotEmpty) {
        final random = Random();
        final newMeal = candidates[random.nextInt(candidates.length)];
        if (!_weeklyPlan.containsKey(day)) _weeklyPlan[day] = {};
        _weeklyPlan[day]![type] = newMeal;
        await _saveLocalAndSync();
      }
    } finally {
      notifyListeners();
    }
  }

  Future<List<Refeicao>> getAvailableMealsForSlot(String type, Set<String> preferences) async {
    final allMeals = await _repository.getRefeicoes();
    var options = allMeals.where((m) => m.tipo == type).toList();
    if (preferences.isNotEmpty) {
      options.sort((a, b) {
        final aHas = a.tagIds.any((t) => preferences.contains(t)) ? 1 : 0;
        final bHas = b.tagIds.any((t) => preferences.contains(t)) ? 1 : 0;
        return bHas.compareTo(aHas);
      });
    }
    return options;
  }

  Future<void> updateSlot(String day, String type, Refeicao selectedMeal) async {
    if (!_weeklyPlan.containsKey(day)) _weeklyPlan[day] = {};
    _weeklyPlan[day]![type] = selectedMeal;
    notifyListeners();
    await _saveLocalAndSync();
  }

  Future<void> _saveLocalAndSync() async {
    final Map<String, Map<String, String>> mapToSave = {};
    _weeklyPlan.forEach((day, slots) {
      mapToSave[day] = {};
      slots.forEach((type, meal) {
        mapToSave[day]![type] = meal.id;
      });
    });
    await _prefsService.setWeeklyPlanMap(mapToSave);
    _syncWithCloud(mapToSave);
  }

  Future<void> _syncWithCloud([Map<String, Map<String, String>>? mapToSave]) async {
    final email = _prefsService.userEmail;
    final name = _prefsService.userName;
    await _repository.syncUserProfile(name, email, _prefsService.userPhotoPath);
    final plan = mapToSave ?? _prefsService.getWeeklyPlanMap();
    await _repository.syncWeeklyPlan(email, plan);
  }

  Future<Map<String, dynamic>?> authenticate(String email, String password) async {
    return await _repository.authenticateUser(email, password);
  }

  Future<bool> register(String name, String email, String password) async {
    return await _repository.registerUser(name, email, password);
  }

  Future<void> deleteAccount(String email) async {
    await _repository.deleteUserAccount(email);
    await _prefsService.clearAll();
    _weeklyPlan = {};
    notifyListeners();
  }
}