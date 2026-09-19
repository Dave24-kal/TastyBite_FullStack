import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/Splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const RestourantApp(),
    ),
  );
}

class RestourantApp extends StatelessWidget {
  const RestourantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TestyBite",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
