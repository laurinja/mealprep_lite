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

  bool get onboardingCompleted => _prefs.getBool(_keyOnboarding) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(_keyOnboarding, value);

  bool get marketingConsent => _prefs.getBool(_keyConsent) ?? false;
  Future<void> setMarketingConsent(bool value) => _prefs.setBool(_keyConsent, value);

  String? get userPhotoPath => _prefs.getString(_keyPhoto);
  Future<void> setUserPhotoPath(String path) => _prefs.setString(_keyPhoto, path);
  Future<void> removeUserPhotoPath() => _prefs.remove(_keyPhoto);

  Future<void> clearAll() => _prefs.clear();
}