import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Layers
import 'features/meal/data/datasources/meal_local_datasource.dart';
import 'features/meal/data/repositories/meal_repository_impl.dart';
import 'features/meal/domain/usecases/generate_weekly_plan_usecase.dart';
import 'features/meal/presentation/controllers/meal_controller.dart';

// Core & Services
import 'services/prefs_service.dart';

// Pages
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefsService = await PrefsService.init();

  // Dependências da Feature Meal
  final mealDataSource = MealLocalDataSourceImpl();
  final mealRepository = MealRepositoryImpl(mealDataSource);
  final generateWeeklyPlanUseCase = GenerateWeeklyPlanUseCase(mealRepository);
  final mealController = MealController(generateWeeklyPlanUseCase);

  runApp(
    MultiProvider(
      providers: [
        // Injetando Serviços Globais
        Provider<PrefsService>.value(value: prefsService),
        // Injetando Controller da Feature Meal
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