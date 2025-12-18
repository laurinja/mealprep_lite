import 'package:flutter/material.dart';
import 'dart:math';

import '../../domain/entities/refeicao.dart';
import '../../domain/usecases/generate_weekly_plan_usecase.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../../users/domain/repositories/user_repository.dart';

import 'package:mealprep_lite/services/prefs_service.dart';
import '../../../../core/constants/meal_types.dart';

class MealController extends ChangeNotifier {
  final GenerateWeeklyPlanUseCase _generateUseCase;
  final MealRepository _repository;
  final UserRepository _userRepository;
  final PrefsService _prefsService;

  static const daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
  
  Map<String, Map<String, Refeicao>> _weeklyPlan = {};
  Map<String, Map<String, Refeicao>> get weeklyPlan => _weeklyPlan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MealController(
    this._generateUseCase, 
    this._repository, 
    this._userRepository, 
    this._prefsService
  ) {
    _loadSavedPlan();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final email = _prefsService.userEmail;

      if (email.isNotEmpty) {
        await _repository.syncFromServer(email);

        debugPrint('☁️ Sync: Buscando plano semanal atualizado da nuvem...');
        final remotePlan = await _repository.fetchWeeklyPlan(email);
        
        if (remotePlan.isNotEmpty) {
          await _prefsService.setWeeklyPlanMap(remotePlan);
          debugPrint('✅ Sync: Plano local atualizado com sucesso.');
        }
      }

      await _loadSavedPlan(skipSync: true);

    } catch (e) {
      debugPrint('Erro no refreshData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSavedPlan({bool skipSync = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userEmail = _prefsService.userEmail;

      if (!skipSync && userEmail.isNotEmpty) {
        await _repository.syncFromServer(userEmail);
      }
      
      final allMeals = await _repository.loadFromCache();
      
      var savedMap = _prefsService.getWeeklyPlanMap();
      
      if (savedMap.isEmpty && userEmail.isNotEmpty) {
         debugPrint('Cache vazio. Buscando plano na nuvem...');
         
         savedMap = await _repository.fetchWeeklyPlan(userEmail);
         
         if (savedMap.isNotEmpty) {
           await _prefsService.setWeeklyPlanMap(savedMap);
           debugPrint('Plano recuperado: ${savedMap.length} dias encontrados.');
         }
      }
      _weeklyPlan = {};
      bool planChanged = false;

      for (var day in daysOfWeek) {
        if (savedMap.containsKey(day)) {
          _weeklyPlan[day] = {};
          savedMap[day]!.forEach((type, id) {
            try {
              final meal = allMeals.firstWhere((m) => m.id == id);
              _weeklyPlan[day]![type] = meal;
            } catch (_) {
              debugPrint('Limpeza: Prato $id removido do plano (provavelmente deletado).');
              planChanged = true;
            }
          });
        }
      }

      if (planChanged) {
        _saveLocalAndSync();
      }

    } catch (e) {
      debugPrint('Erro ao carregar plano: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateDay(String day, Set<String> preferences) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allMeals = await _repository.loadFromCache();
      
      var candidates = allMeals;
      if (preferences.isNotEmpty) {
        candidates = allMeals.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      if (candidates.isEmpty) candidates = allMeals;

      if (!_weeklyPlan.containsKey(day)) {
        _weeklyPlan[day] = {};
      }

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
      final allMeals = await _repository.loadFromCache();
      
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

  Future<void> regenerateSlot(String day, String type, Set<String> preferences) async {
    notifyListeners();
    try {
      final allMeals = await _repository.loadFromCache();
      
      var candidates = allMeals.where((m) => m.tipo == type).toList();
      if (preferences.isNotEmpty) {
        candidates = candidates.where((m) => m.tagIds.any((t) => preferences.contains(t))).toList();
      }
      
      final currentMeal = _weeklyPlan[day]?[type];
      if (currentMeal != null) {
        candidates.removeWhere((m) => m.id == currentMeal.id);
      }

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
    final allMeals = await _repository.loadFromCache();
    
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

  Future<void> editMealAndReplace(Refeicao original, Refeicao editedData, String day, String type) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newId = '${original.id}_edited_${DateTime.now().millisecondsSinceEpoch}';
      final currentUser = _prefsService.userEmail;
      
      final newMeal = Refeicao(
        id: newId,
        nome: editedData.nome,
        tipo: editedData.tipo,
        tagIds: editedData.tagIds,
        ingredienteIds: editedData.ingredienteIds,
        imageUrl: editedData.imageUrl,
        createdBy: currentUser,
      );

      await _repository.save(newMeal);
      
      if (!_weeklyPlan.containsKey(day)) _weeklyPlan[day] = {};
      _weeklyPlan[day]![type] = newMeal;

      await _saveLocalAndSync();
      
    } catch (e) {
      debugPrint('Erro ao editar: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMealFromSchedule(String day, String type) async {
    if (_weeklyPlan.containsKey(day) && _weeklyPlan[day]!.containsKey(type)) {
      _weeklyPlan[day]!.remove(type);
      notifyListeners();
      await _saveLocalAndSync();
    }
  }

  Future<void> editMeal(Refeicao meal) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.save(meal);
      await _loadSavedPlan(skipSync: true); 

    } catch (e) {
      debugPrint('Erro ao editar refeição: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> softDeleteMeal(Refeicao meal) async {
    _isLoading = true;
    notifyListeners();

    try {
      final deletedMeal = Refeicao(
        id: meal.id,
        nome: meal.nome,
        tipo: meal.tipo,
        tagIds: meal.tagIds,
        ingredienteIds: meal.ingredienteIds,
        imageUrl: meal.imageUrl,
        createdBy: meal.createdBy,
        deletedAt: DateTime.now().toUtc(),
      );

      await _repository.save(deletedMeal);
      
      _removeMealFromWeeklyPlan(meal.id);
      
      await _loadSavedPlan(skipSync: true);

    } catch (e) {
      debugPrint('Erro ao excluir: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _removeMealFromWeeklyPlan(String mealId) {
    bool changed = false;
    _weeklyPlan.forEach((day, slots) {
      final keysToRemove = <String>[];
      slots.forEach((type, meal) {
        if (meal.id == mealId) {
          keysToRemove.add(type);
          changed = true;
        }
      });
      keysToRemove.forEach(slots.remove);
    });
    
    if (changed) {
      _saveLocalAndSync();
    }
  }

  /*Future<void> updateUserProfile(String newName) async {
    await _prefsService.setUserName(newName);
    notifyListeners();
    await _syncWithCloud();
  }*/

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
    
    await _userRepository.syncProfile(name, email, _prefsService.userPhotoPath);
    
    final plan = mapToSave ?? _prefsService.getWeeklyPlanMap();
    await _repository.syncWeeklyPlan(email, plan);
  }

  Future<Map<String, dynamic>?> authenticate(String email, String password) async {
    return await _userRepository.authenticate(email, password);
  }

  Future<bool> register(String name, String email, String password) async {
    return await _userRepository.register(name, email, password);
  }

  Future<void> deleteAccount(String email) async {
    await _userRepository.deleteAccount(email);
    await _prefsService.clearAll();
    _weeklyPlan = {};
    notifyListeners();
  }
}