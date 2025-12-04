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
  
  // Mapa principal: Dia -> { Tipo de Refeição -> Objeto Refeição }
  Map<String, Map<String, Refeicao>> _weeklyPlan = {};
  Map<String, Map<String, Refeicao>> get weeklyPlan => _weeklyPlan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MealController(this._generateUseCase, this._repository, this._prefsService) {
    // Carrega o plano salvo ao iniciar o controller
    _loadSavedPlan();
  }

  // --- CARREGAMENTO E SINCRONIZAÇÃO ---

  Future<void> _loadSavedPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Busca catálogo completo para hidratar os IDs
      final allMeals = await _repository.getRefeicoes();
      
      // 2. Busca o mapa de IDs salvo no dispositivo
      final savedMap = _prefsService.getWeeklyPlanMap();
      
      _weeklyPlan = {};
      
      // 3. Reconstrói o objeto _weeklyPlan
      for (var day in daysOfWeek) {
        if (savedMap.containsKey(day)) {
          _weeklyPlan[day] = {};
          savedMap[day]!.forEach((type, id) {
            try {
              final meal = allMeals.firstWhere((m) => m.id == id);
              _weeklyPlan[day]![type] = meal;
            } catch (_) {
              // Se o ID salvo não existir mais no catálogo, ignoramos
            }
          });
        }
      }
      
      // 4. Tenta sincronizar com a nuvem (download de dados novos)
      _syncWithCloud();

    } catch (e) {
      debugPrint('Erro ao carregar plano: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GERAÇÃO DE CARDÁPIOS ---

  // Gera cardápio para APENAS UM DIA específico
  Future<void> generateDay(String day, Set<String> preferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allMeals = await _repository.getRefeicoes();
      
      // Filtra candidatos
      var candidates = allMeals;
      if (preferences.isNotEmpty) {
        candidates = allMeals.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      if (candidates.isEmpty) candidates = allMeals;

      if (!_weeklyPlan.containsKey(day)) {
        _weeklyPlan[day] = {};
      }

      final random = Random();

      // Sorteia uma refeição para cada tipo (Café, Almoço, Jantar)
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

  // Gera cardápio para a SEMANA TODA (distribuição inteligente)
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

  // --- EDIÇÃO MANUAL E REFRESH ---

  // Refresh de Slot Único (Troca aleatória para um horário específico)
  Future<void> regenerateSlot(String day, String type, Set<String> preferences) async {
    notifyListeners(); // Atualiza UI sem tela de loading total

    try {
      final allMeals = await _repository.getRefeicoes();
      
      // Filtra opções válidas
      var candidates = allMeals.where((m) => m.tipo == type).toList();
      if (preferences.isNotEmpty) {
        candidates = candidates.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      
      // Remove o prato atual para forçar a troca
      final currentMeal = _weeklyPlan[day]?[type];
      if (currentMeal != null) {
        candidates.removeWhere((m) => m.id == currentMeal.id);
      }

      // Se ficou vazio, restaura (para não perder a única opção existente)
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

  // Busca lista de opções para o Modal de Seleção Manual
  Future<List<Refeicao>> getAvailableMealsForSlot(String type, Set<String> preferences) async {
    final allMeals = await _repository.getRefeicoes();
    
    var options = allMeals.where((m) => m.tipo == type).toList();
    
    // Ordena: Preferidos primeiro
    if (preferences.isNotEmpty) {
      options.sort((a, b) {
        final aHas = a.tagIds.any((t) => preferences.contains(t)) ? 1 : 0;
        final bHas = b.tagIds.any((t) => preferences.contains(t)) ? 1 : 0;
        return bHas.compareTo(aHas);
      });
    }
    return options;
  }

  // Salva a escolha manual feita no Modal
  Future<void> updateSlot(String day, String type, Refeicao selectedMeal) async {
    if (!_weeklyPlan.containsKey(day)) _weeklyPlan[day] = {};
    _weeklyPlan[day]![type] = selectedMeal;
    notifyListeners();
    await _saveLocalAndSync();
  }

  // --- PERSISTÊNCIA ---

  // Salva no SharedPreferences e dispara Sync
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

  // Sincroniza Perfil e Plano com Supabase
  Future<void> _syncWithCloud([Map<String, Map<String, String>>? mapToSave]) async {
    final email = _prefsService.userEmail;
    final name = _prefsService.userName;
    
    // Sync Perfil (Nome/Foto)
    await _repository.syncUserProfile(name, email, _prefsService.userPhotoPath);
    
    // Sync Plano Semanal
    final plan = mapToSave ?? _prefsService.getWeeklyPlanMap();
    await _repository.syncWeeklyPlan(email, plan);
  }

  // --- AUTENTICAÇÃO (Proxy para o Repositório) ---

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