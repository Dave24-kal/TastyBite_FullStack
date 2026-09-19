import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorageService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> onboardingCompleted() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingCompletedKey, true);
  }

  Future<bool> isOnboardingCompleted() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_onboardingCompletedKey) ?? false;
  }
}
