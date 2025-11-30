import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  final SharedPreferences _prefs;

  PrefsService(this._prefs);

  static Future<PrefsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService(prefs);
  }

  // --- Chaves ---
  static const _keyOnboarding = 'onboarding_completed';
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyConsent = 'marketing_consent';
  static const _keyPhoto = 'user_photo_path';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyUserPassword = 'user_password'; // Chave da Senha
  static const _keyWeeklyPlanMap = 'weekly_plan_map_v2'; // Chave do Plano Semanal

  // --- Onboarding ---
  bool get onboardingCompleted => _prefs.getBool(_keyOnboarding) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(_keyOnboarding, value);

  // --- Login ---
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  Future<void> setLoggedIn(bool value) => _prefs.setBool(_keyIsLoggedIn, value);

  // --- Consentimento ---
  bool get marketingConsent => _prefs.getBool(_keyConsent) ?? false;
  Future<void> setMarketingConsent(bool value) => _prefs.setBool(_keyConsent, value);

  // --- Foto de Perfil ---
  String? get userPhotoPath => _prefs.getString(_keyPhoto);
  Future<void> setUserPhotoPath(String path) => _prefs.setString(_keyPhoto, path);

  // --- Dados do Usuário ---
  String get userName => _prefs.getString(_keyUserName) ?? '';
  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  String get userEmail => _prefs.getString(_keyUserEmail) ?? '';
  Future<void> setUserEmail(String email) => _prefs.setString(_keyUserEmail, email);

  // --- Senha (O que faltava para corrigir o erro) ---
  String get userPassword => _prefs.getString(_keyUserPassword) ?? '';
  Future<void> setUserPassword(String password) => _prefs.setString(_keyUserPassword, password);

  // --- Plano Semanal (Estrutura Complexa) ---
  // Formato: { "Segunda": { "Almoço": "ID_123", "Jantar": "ID_456" }, ... }
  Map<String, Map<String, String>> getWeeklyPlanMap() {
    final String? jsonString = _prefs.getString(_keyWeeklyPlanMap);
    if (jsonString == null) return {};

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final Map<String, Map<String, String>> result = {};
      
      decoded.forEach((day, meals) {
        if (meals is Map) {
          result[day] = Map<String, String>.from(meals);
        }
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  Future<void> setWeeklyPlanMap(Map<String, Map<String, String>> plan) async {
    final jsonString = jsonEncode(plan);
    await _prefs.setString(_keyWeeklyPlanMap, jsonString);
  }

  // --- Limpar Tudo ---
  Future<void> clearAll() => _prefs.clear();
}