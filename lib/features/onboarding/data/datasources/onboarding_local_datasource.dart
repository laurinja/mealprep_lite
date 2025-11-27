import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool?> getMarketingConsent();


  Future<void> setMarketingConsent(bool value);
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences prefs;

  OnboardingLocalDataSourceImpl(this.prefs);

  static const String _consentKey = 'marketing_consent';

  @override
  Future<bool?> getMarketingConsent() async {
    if (!prefs.containsKey(_consentKey)) {
      return null; // Nunca escolhido
    }
    return prefs.getBool(_consentKey);
  }

  @override
  Future<void> setMarketingConsent(bool value) async {
    await prefs.setBool(_consentKey, value);
  }
}
