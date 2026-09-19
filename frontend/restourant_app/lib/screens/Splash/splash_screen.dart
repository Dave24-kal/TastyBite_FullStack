import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/onboarding_storage_service.dart';
import '../onboarding/onboarding_screen.dart';
import 'package:restourant_app/screens/features/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardingStorageService _storageService = OnboardingStorageService();

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final bool isCompleted = await _storageService.isOnboardingCompleted();

    if (!mounted) return;

    if (isCompleted) {
      _openWelcomeScreen();
    } else {
      _openOnboardingScreen();
    }
  }

  void _openOnboardingScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  void _openWelcomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.room_service_rounded,
                size: 110,
                color: AppColors.primary,
              ),
              SizedBox(height: 24),
              const Text(
                'TastyBite',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Delicious food, delivered to you',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
