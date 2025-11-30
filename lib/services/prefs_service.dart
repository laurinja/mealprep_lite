import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  final SharedPreferences _prefs;

  PrefsService(this._prefs);

  static Future<PrefsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService(prefs);
  }

  // Chaves
  static const _keyOnboarding = 'onboarding_completed';
  static const _keyConsent = 'marketing_consent';
  static const _keyPhoto = 'user_photo_path';
  // Novas chaves para o Perfil
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';
  static const _keyPlanIds = 'weekly_plan_ids';

  // Getters & Setters
  bool get onboardingCompleted => _prefs.getBool(_keyOnboarding) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(_keyOnboarding, value);

  bool get marketingConsent => _prefs.getBool(_keyConsent) ?? false;
  Future<void> setMarketingConsent(bool value) => _prefs.setBool(_keyConsent, value);

  String? get userPhotoPath => _prefs.getString(_keyPhoto);
  Future<void> setUserPhotoPath(String path) => _prefs.setString(_keyPhoto, path);
  Future<void> removeUserPhotoPath() => _prefs.remove(_keyPhoto);

  // Perfil do Usuário (Local)
  String get userName => _prefs.getString(_keyUserName) ?? 'Estudante MealPrep';
  Future<void> setUserName(String name) => _prefs.setString(_keyUserName, name);

  String get userEmail => _prefs.getString(_keyUserEmail) ?? 'estudante@email.com';
  Future<void> setUserEmail(String email) => _prefs.setString(_keyUserEmail, email);

  // Plano Semanal
  List<String> get weeklyPlanIds => _prefs.getStringList(_keyPlanIds) ?? [];
  Future<void> setWeeklyPlanIds(List<String> ids) => _prefs.setStringList(_keyPlanIds, ids);

  Future<void> clearAll() => _prefs.clear();
}