import 'dart:async';
import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  final PrefsService prefs;
  const SplashPage({super.key, required this.prefs});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 800), _decideNext);
  }

  void _decideNext() {
    final done = widget.prefs.getOnboardingCompleted();
    if (done) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Semantics(
          label: 'MealPrep Lite Splash',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/splash.png', width: 120, height: 120),
              const SizedBox(height: 16),
              const Text(
                'MealPrep Lite',
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('Planejamento de refeições', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
