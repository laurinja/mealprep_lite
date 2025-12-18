import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/meal/data/datasources/meal_local_datasource.dart';
import 'features/meal/data/datasources/meal_remote_datasource.dart';
import 'features/meal/data/repositories/meal_repository_impl.dart';
import 'features/meal/domain/usecases/generate_weekly_plan_usecase.dart';
import 'features/meal/presentation/controllers/meal_controller.dart';
import 'features/meal/presentation/controllers/meal_list_controller.dart';
import 'features/users/data/repositories/user_repository_impl.dart';  
import 'services/prefs_service.dart';

import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/meals_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Erro ao carregar .env: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', 
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  final prefsService = await PrefsService.init();
  final sharedPrefs = await SharedPreferences.getInstance();

  final mealRemoteDS = MealRemoteDataSource(Supabase.instance.client);
  final mealLocalDS = MealLocalDataSourceImpl(sharedPrefs);

  final mealRepository = MealRepositoryImpl(mealLocalDS, mealRemoteDS);
  final userRepository = UserRepositoryImpl();

  final generateUseCase = GenerateWeeklyPlanUseCase(mealRepository);
  final mealController = MealController(generateUseCase, mealRepository, userRepository, prefsService);

  final mealListController = MealListController(mealRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefsService),
        Provider<UserRepositoryImpl>.value(value: userRepository),
        ChangeNotifierProvider.value(value: mealController),
        ChangeNotifierProvider.value(value: mealListController),
      ],
      child: const MealPrepLiteApp(),
    ),
  );
}

class MealPrepLiteApp extends StatelessWidget {
  const MealPrepLiteApp({super.key});

  static const primaryGreen = Color(0xFF4CAF50);
  static const secondaryGreen = Color(0xFF8BC34A);
  static const darkGreen = Color(0xFF2E7D32);
  static const backgroundWhite = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealPrep Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Esquema de Cores
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: secondaryGreen,
          surface: Colors.white,
          background: backgroundWhite,
        ),
        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen, 
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        // Botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.green.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[100],
          selectedColor: secondaryGreen.withOpacity(0.3),
          labelStyle: const TextStyle(color: Colors.black87),
          secondaryLabelStyle: TextStyle(color: darkGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashPage(),
        '/onboarding': (ctx) => const OnboardingPage(),
        '/login': (ctx) => const LoginPage(),
        '/home': (ctx) => const HomePage(),
        '/settings': (ctx) => const SettingsPage(),
        '/catalog': (ctx) => const MealsListPage(),
      },
    );
  }
}