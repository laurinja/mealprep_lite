import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static late SharedPreferences _prefs;

  static Future<PrefsService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return PrefsService();
  }

  // ---------- Onboarding ----------
  bool getOnboardingCompleted() => _prefs.getBool('onboarding_completed') ?? false;
  Future<void> setOnboardingCompleted(bool value) async =>
      _prefs.setBool('onboarding_completed', value);

  // ---------- Consentimento ----------
  bool getMarketingConsent() => _prefs.getBool('marketing_consent') ?? false;
  Future<void> setMarketingConsent(bool value) async =>
      _prefs.setBool('marketing_consent', value);

  // ---------- Avatar (NOVO - Conforme PRD) ----------
  String? getUserPhotoPath() => _prefs.getString('user_photo_path');
  Future<void> setUserPhotoPath(String path) async =>
      _prefs.setString('user_photo_path', path);

  Future<void> removeUserPhotoPath() async =>
      _prefs.remove('user_photo_path');
}