import 'package:flutter/material.dart';
import 'dart:math';
import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';
import '../../domain/repositories/meal_repository.dart';
import 'package:mealprep_lite/services/prefs_service.dart';

class MealController extends ChangeNotifier {
  final GenerateWeeklyPlanUseCase _generateUseCase;
  final MealRepository _repository;
  final PrefsService _prefsService;

  // Dias da semana suportados
  static const daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  
  // Tipos de refeição
  static const mealTypes = ['Café da Manhã', 'Almoço', 'Jantar'];

  // ESTRUTURA DO PLANO: Dia -> { Tipo -> Refeicao }
  Map<String, Map<String, Refeicao>> _weeklyPlan = {};
  Map<String, Map<String, Refeicao>> get weeklyPlan => _weeklyPlan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MealController(this._generateUseCase, this._repository, this._prefsService) {
    _loadSavedPlan();
  }

  // Carrega do Cache e hidrata os objetos Refeicao
  Future<void> _loadSavedPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Carrega catálogo completo
      final allMeals = await _repository.getRefeicoes();
      
      // 2. Carrega mapa de IDs do disco
      final savedMap = _prefsService.getWeeklyPlanMap();
      
      // 3. Reconstrói o mapa de objetos
      _weeklyPlan = {};
      
      for (var day in daysOfWeek) {
        if (savedMap.containsKey(day)) {
          _weeklyPlan[day] = {};
          savedMap[day]!.forEach((type, id) {
            try {
              final meal = allMeals.firstWhere((m) => m.id == id);
              _weeklyPlan[day]![type] = meal;
            } catch (e) {
              // Refeição não encontrada no catálogo (pode ter sido deletada)
            }
          });
        }
      }
      
      // 4. Tenta sincronizar com a nuvem em background
      _syncWithCloud();

    } catch (e) {
      debugPrint('Erro ao carregar plano: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GERAR PLANO COMPLETO ---
  Future<void> generateFullWeek(Set<String> preferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allMeals = await _repository.getRefeicoes();
      
      // Filtra pelas preferências
      var candidates = allMeals;
      if (preferences.isNotEmpty) {
        candidates = allMeals.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      
      if (candidates.isEmpty) candidates = allMeals; // Fallback

      final random = Random();
      
      // Preenche cada dia
      for (var day in daysOfWeek) {
        _weeklyPlan[day] = {};
        for (var type in mealTypes) {
          // Filtra por tipo (Café, Almoço...)
          final options = candidates.where((m) => m.tipo == type).toList();
          if (options.isNotEmpty) {
            _weeklyPlan[day]![type] = options[random.nextInt(options.length)];
          }
        }
      }

      await _saveLocalAndSync();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ALOCAR REFEIÇÃO EM UM DIA ESPECÍFICO ---
  Future<void> assignMealToSlot(String day, String type, Refeicao meal) async {
    if (!_weeklyPlan.containsKey(day)) {
      _weeklyPlan[day] = {};
    }
    _weeklyPlan[day]![type] = meal;
    notifyListeners();
    await _saveLocalAndSync();
  }

  // Salva localmente e dispara sync na nuvem
  Future<void> _saveLocalAndSync() async {
    // 1. Converte objetos para IDs
    final Map<String, Map<String, String>> mapToSave = {};
    
    _weeklyPlan.forEach((day, slots) {
      mapToSave[day] = {};
      slots.forEach((type, meal) {
        mapToSave[day]![type] = meal.id;
      });
    });

    // 2. Salva Local
    await _prefsService.setWeeklyPlanMap(mapToSave);

    // 3. Sincroniza Nuvem
    _syncWithCloud(mapToSave);
  }

  Future<void> _syncWithCloud([Map<String, Map<String, String>>? mapToSave]) async {
    final email = _prefsService.userEmail;
    final name = _prefsService.userName;
    
    // Sync Perfil
    await _repository.syncUserProfile(name, email, _prefsService.userPhotoPath);
    
    // Sync Plano
    final plan = mapToSave ?? _prefsService.getWeeklyPlanMap();
    await _repository.syncWeeklyPlan(email, plan);
  }
}