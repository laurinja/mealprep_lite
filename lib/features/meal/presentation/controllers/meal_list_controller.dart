import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/refeicao.dart';
import '../../domain/repositories/meal_repository.dart';

class MealListController extends ChangeNotifier {
  final MealRepository _repository;

  MealListController(this._repository);

  List<Refeicao> _meals = [];
  List<Refeicao> get meals => _meals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true; 
  bool get hasMore => _hasMore;

  int _currentPage = 1;
  static const int _pageSize = 10;

  String _currentQuery = '';
  String? _currentTypeFilter;

  Future<void> loadMeals({bool refresh = false, String? userEmail}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _meals = [];
      notifyListeners();
    }

    if (!_hasMore || (_isLoading && !refresh)) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('MealListController: Carregando página $_currentPage (Filtro: $_currentTypeFilter)...');
      }

      var newMeals = await _repository.getMealsPaged(
        page: _currentPage,
        pageSize: _pageSize,
        query: _currentQuery,
        typeFilter: _currentTypeFilter,
      );

      if (refresh && userEmail != null && _currentQuery.isEmpty && _currentTypeFilter == null) {
        if (kDebugMode) {
          print('MealListController: Atualizando catálogo com o servidor...');
        }
        
        await _repository.syncFromServer(userEmail);
        
        newMeals = await _repository.getMealsPaged(
          page: _currentPage,
          pageSize: _pageSize,
          query: _currentQuery,
          typeFilter: _currentTypeFilter,
        );
        
        if (kDebugMode) {
          print('MealListController: Após sync, encontrados ${newMeals.length} itens.');
        }
      }

      if (refresh) {
        _meals = newMeals;
      } else {
        _meals.addAll(newMeals);
      }

      if (newMeals.length < _pageSize) {
        _hasMore = false;
      } else {
        _currentPage++;
      }

    } catch (e) {
      debugPrint('Erro ao listar refeições: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    if (_currentQuery == query) return;
    _currentQuery = query;
    loadMeals(refresh: true);
  }

  void updateTypeFilter(String? type) {
    if (_currentTypeFilter == type) return;
    _currentTypeFilter = type;
    loadMeals(refresh: true);
  }
}