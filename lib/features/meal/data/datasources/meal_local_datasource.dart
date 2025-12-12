import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/refeicao_dto.dart';
import '../../../../core/constants/meal_types.dart'; 

abstract class MealLocalDataSource {
  Future<List<RefeicaoDTO>> getCachedMeals();
  Future<void> cacheMeals(List<RefeicaoDTO> meals);
  Future<void> updateMealLocally(RefeicaoDTO meal);
  
  Future<void> upsertMeals(List<RefeicaoDTO> newMeals);
  Future<DateTime?> getLastSync();
  Future<void> saveLastSync(DateTime date);
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  final SharedPreferences prefs;
  static const _keyMeals = 'cached_meals_list';
  static const _keyLastSync = 'meal_last_sync_v1';

  MealLocalDataSourceImpl(this.prefs);

  @override
  Future<List<RefeicaoDTO>> getCachedMeals() async {
    final jsonString = prefs.getString(_keyMeals);
    if (jsonString != null) {
      try {
        final List decoded = jsonDecode(jsonString);
        return decoded.map((e) => RefeicaoDTO.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> cacheMeals(List<RefeicaoDTO> meals) async {
    final jsonString = jsonEncode(meals.map((e) => e.toJson()).toList());
    await prefs.setString(_keyMeals, jsonString);
  }

  @override
  Future<void> updateMealLocally(RefeicaoDTO meal) async {
    await upsertMeals([meal]);
  }

  @override
  Future<void> upsertMeals(List<RefeicaoDTO> newMeals) async {
    final currentList = await getCachedMeals();
    final Map<String, RefeicaoDTO> map = {for (var e in currentList) e.id: e};

    for (var newItem in newMeals) {
      map[newItem.id] = newItem;
    }

    await cacheMeals(map.values.toList());
  }

  @override
  Future<DateTime?> getLastSync() async {
    final str = prefs.getString(_keyLastSync);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  @override
  Future<void> saveLastSync(DateTime date) async {
    await prefs.setString(_keyLastSync, date.toIso8601String());
  }
}