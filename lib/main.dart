import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/injection/injection_container.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'core/constants/app_theme.dart'; 
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/meal_plan/presentation/pages/home_page.dart';
import 'features/settings/presentation/pages/settings_page.dart'; 
import 'core/constants/app_theme.dart'

void main() async {
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const AppWidget(),
    ),
  );
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MealPrep Lite",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme, 
      home: const SplashPage(),
      routes: {
        '/splash': (_) => const SplashPage(),
        '/onboarding': (_) => const OnboardingPage(), 
        '/home': (_) => const HomePage(), 
        '/settings': (_) => const SettingsPage(), 
      },
    );
  }
}