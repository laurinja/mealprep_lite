import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

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
    if (prefs.onboardingCompleted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Text(
          'MealPrep Lite',
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}