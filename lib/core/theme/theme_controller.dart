import 'package:flutter/material.dart';
import '../../services/prefs_service.dart';

class ThemeController extends ChangeNotifier {
  final PrefsService _prefs;
  late ThemeMode _mode;

  ThemeController(this._prefs) {
    _mode = _stringToThemeMode(_prefs.themeMode);
  }

  ThemeMode get mode => _mode;

  bool isDark(BuildContext context) {
    if (_mode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _mode == ThemeMode.dark;
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isCurrentlyDark = isDark(context);
    
    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    
    _mode = newMode;
    notifyListeners();
    
    await _prefs.setThemeMode(_themeModeToString(newMode));
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      default: return 'system';
    }
  }
}