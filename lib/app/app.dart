import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import 'app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class FitMalaysiaApp extends StatelessWidget {
  const FitMalaysiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMalaysia',
      debugShowCheckedModeBanner: false,

      // 🌍 Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('ms'),
        Locale('en'),
      ],

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