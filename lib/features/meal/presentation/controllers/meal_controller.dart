import 'package:flutter/material.dart';
import 'dart:math'; // Necessário para Random e Shuffle
import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';
import '../../domain/repositories/meal_repository.dart';
import 'package:mealprep_lite/services/prefs_service.dart';

class MealController extends ChangeNotifier {
  final GenerateWeeklyPlanUseCase _generateUseCase;
  final MealRepository _repository;
  final PrefsService _prefsService;

  static const daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  static const mealTypes = ['Café da Manhã', 'Almoço', 'Jantar'];

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
            } catch (e) {
              // Refeição não encontrada
            }
          });
        }
      }
      _syncWithCloud();
    } catch (e) {
      debugPrint('Erro ao carregar plano: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NOVA LÓGICA DE GERAÇÃO SEMANAL (SEM REPETIÇÃO DESNECESSÁRIA) ---
  Future<void> generateFullWeek(Set<String> preferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allMeals = await _repository.getRefeicoes();
      
      // Filtra candidatos globais
      var candidates = allMeals;
      if (preferences.isNotEmpty) {
        candidates = allMeals.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      // Fallback: se o filtro for muito restritivo e não retornar nada, usa tudo
      if (candidates.isEmpty) candidates = allMeals;

      // Inicializa o mapa
      _weeklyPlan = {};
      for (var day in daysOfWeek) {
        _weeklyPlan[day] = {};
      }

      // Para cada tipo (Café, Almoço...), distribui as refeições
      for (var type in mealTypes) {
        // Pega todas as opções deste tipo (ex: todos os almoços disponíveis)
        final options = candidates.where((m) => m.tipo == type).toList();
        
        if (options.isNotEmpty) {
          // Cria uma lista de distribuição. 
          // Se tivermos 3 opções e 6 dias, a lista será [A, B, C, A, B, C] (embaralhada)
          // Isso garante que A, B e C apareçam igualmente, em vez de sortear A, A, A, B, B, A.
          List<Refeicao> distributionList = [];
          
          while (distributionList.length < daysOfWeek.length) {
            // Embaralha as opções e adiciona na fila
            final shuffled = List<Refeicao>.from(options)..shuffle();
            distributionList.addAll(shuffled);
          }
          
          // Atribui aos dias
          for (int i = 0; i < daysOfWeek.length; i++) {
            _weeklyPlan[daysOfWeek[i]]![type] = distributionList[i];
          }
        }
      }

      await _saveLocalAndSync();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODO NOVO: REFRESH DE SLOT ÚNICO ---
  Future<void> regenerateSlot(String day, String type, Set<String> preferences) async {
    // Não ativa isLoading geral para não piscar a tela toda, apenas notifica
    notifyListeners();

    try {
      final allMeals = await _repository.getRefeicoes();
      
      // Filtra opções válidas para este slot
      var candidates = allMeals.where((m) => m.tipo == type).toList();
      
      if (preferences.isNotEmpty) {
        candidates = candidates.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      
      // Tenta remover o prato atual das opções para garantir que mude
      final currentMeal = _weeklyPlan[day]?[type];
      if (currentMeal != null) {
        candidates.removeWhere((m) => m.id == currentMeal.id);
      }

      // Se removeu o único que tinha, restaura a lista (melhor repetir do que ficar vazio)
      if (candidates.isEmpty) {
         candidates = allMeals.where((m) => m.tipo == type).toList();
         // Se mesmo restaurando só tem 1 opção (a atual), não tem o que trocar
         if (candidates.length == 1 && candidates.first.id == currentMeal?.id) {
           return; // Não faz nada
         }
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
}