import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/meal/data/datasources/meal_local_datasource.dart';
import 'features/meal/data/repositories/meal_repository_impl.dart';
import 'features/meal/domain/usecases/generate_weekly_plan_usecase.dart';
import 'features/meal/presentation/controllers/meal_controller.dart';

import 'services/prefs_service.dart';

import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefsService = await PrefsService.init();

  final mealDataSource = MealLocalDataSourceImpl();
  final mealRepository = MealRepositoryImpl(mealDataSource);
  final generateWeeklyPlanUseCase = GenerateWeeklyPlanUseCase(mealRepository);

  final mealController = MealController(
    generateWeeklyPlanUseCase,
    mealRepository,
    prefsService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefsService),
        ChangeNotifierProvider.value(value: mealController),
      ],
      child: const MealPrepLiteApp(),
    ),
  );
}

class MealPrepLiteApp extends StatelessWidget {
  const MealPrepLiteApp({super.key});

  static const green = Color(0xFF22C55E);
  static const brown = Color(0xFF78350F);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealPrep Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          primary: green,
          secondary: brown,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: brown,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashPage(),
        '/onboarding': (ctx) => const OnboardingPage(),
        '/home': (ctx) => const HomePage(),
        '/settings': (ctx) => const SettingsPage(),
      },
    );
  }
}