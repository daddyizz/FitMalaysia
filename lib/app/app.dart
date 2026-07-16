import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import 'app_theme.dart';

class FitMalaysiaApp extends StatelessWidget {
  const FitMalaysiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMalaysia',
      debugShowCheckedModeBanner: false,

      // 🌞 Light Theme
      theme: AppTheme.lightTheme,

      // 🌙 Dark Theme
      darkTheme: AppTheme.darkTheme,

      // 📱 Ikut tema telefon
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}