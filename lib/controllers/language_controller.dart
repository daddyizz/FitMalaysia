import 'package:flutter/material.dart';
import '../controllers/language_controller.dart';
import '../services/language_service.dart';

class LanguageController extends ChangeNotifier {
  Locale _locale = const Locale('ms');

  Locale get locale => _locale;

  Future<void> loadLanguage() async {
    _locale = await LanguageService.getLanguage();
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);

    await LanguageService.saveLanguage(languageCode);

    notifyListeners();
  }
}