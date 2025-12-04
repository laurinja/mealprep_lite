import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. IMPORTAR

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
  
  // 2. CARREGAR O ARQUIVO .ENV
  await dotenv.load(fileName: ".env");

  // 3. USAR AS VARIÁVEIS DE AMBIENTE
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', 
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // 2. Serviços Externos
  final prefsService = await PrefsService.init();
  final sharedPrefs = await SharedPreferences.getInstance();

  // 3. Camada de Dados (DataSources)
  final mealRemoteDS = MealRemoteDataSource(Supabase.instance.client);
  final mealLocalDS = MealLocalDataSourceImpl(sharedPrefs);

  // 4. Repositório (Recebe Local + Remote)
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

  // NOVA PALETA "FRESH & HEALTHY"
  static const primaryGreen = Color(0xFF4CAF50); // Verde Material padrão (Equilibrado)
  static const secondaryGreen = Color(0xFF8BC34A); // Verde claro/Limão (Energia)
  static const darkGreen = Color(0xFF2E7D32); // Verde floresta (Para contrastes)
  static const backgroundWhite = Color(0xFFFAFAFA); // Branco quase puro

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealPrep Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Define o esquema de cores base
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: secondaryGreen,
          surface: Colors.white, // Cards brancos
          background: backgroundWhite,
        ),
        // Estilo da Barra Superior
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen, 
          foregroundColor: Colors.white, // Texto branco
          elevation: 0,
          centerTitle: true,
        ),
        // Estilo dos Botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        // Estilo dos Cards
        cardTheme: CardTheme( 
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.green.withOpacity(0.1), // Sombra levemente verde
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        
        // Estilo dos Chips (Filtros)
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
      },
    );
  }
}