import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../controllers/language_controller.dart';
import '../features/splash/splash_screen.dart';
import '../l10n/app_localizations.dart';
import 'app_theme.dart';

class FitMalaysiaApp extends StatelessWidget {
  const FitMalaysiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = context.watch<LanguageController>();

    return MaterialApp(
      title: 'FitMalaysia',
      debugShowCheckedModeBanner: false,

      locale: languageController.locale,

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

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}