import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealprep_lite/services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    final prefs = context.read<PrefsService>();
    
    // Fluxo de decisão:
    if (!prefs.onboardingCompleted) {
      // 1. Nunca usou o app -> Onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (!prefs.isLoggedIn) {
      // 2. Viu onboarding mas não logou -> Login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // 3. Já logou -> Home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.restaurant, size: 80, color: Colors.white),
             SizedBox(height: 16),
             Text(
              'MealPrep Lite',
              style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}