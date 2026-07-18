import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const _languageKey = "language_code";

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<Locale> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString(_languageKey) ?? "ms";

    return Locale(languageCode);
  }
}