import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Imports de camadas
import 'features/meal/data/datasources/meal_local_datasource.dart';
import 'features/meal/data/datasources/meal_remote_datasource.dart';
import 'features/meal/data/repositories/meal_repository_impl.dart';
import 'features/meal/domain/usecases/generate_weekly_plan_usecase.dart';
import 'features/meal/presentation/controllers/meal_controller.dart';
import 'services/prefs_service.dart';

// Páginas
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar Supabase (Coloque suas chaves aqui)
  await Supabase.initialize(
    url: 'https://pzfdcqcepywatwhylgla.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB6ZmRjcWNlcHl3YXR3aHlsZ2xhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NDUyNzYsImV4cCI6MjA4MDEyMTI3Nn0.0N_xTxBccwdpwtzHykUPi-I0dM2Xn3qtsKbRq2--mhk',
  );

  // 2. Serviços Externos
  final prefsService = await PrefsService.init();
  final sharedPrefs = await SharedPreferences.getInstance();

  // 3. Camada de Dados (DataSources)
  final mealRemoteDS = MealRemoteDataSource(Supabase.instance.client);
  final mealLocalDS = MealLocalDataSourceImpl(sharedPrefs);

  // 4. Repositório
  final mealRepository = MealRepositoryImpl(mealLocalDS, mealRemoteDS);

  // 5. Casos de Uso e Controllers
  final generateUseCase = GenerateWeeklyPlanUseCase(mealRepository);
  final mealController = MealController(generateUseCase, mealRepository, prefsService);

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
        colorScheme: ColorScheme.fromSeed(seedColor: green, primary: green, secondary: brown),
        appBarTheme: const AppBarTheme(backgroundColor: brown, foregroundColor: Colors.white),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashPage(),
        '/onboarding': (ctx) => const OnboardingPage(),
        '/login': (ctx) => const LoginPage(),
        '/home': (ctx) => const HomePage(),
        '/settings': (ctx) => const SettingsPage(),
      },
    );
  }
}