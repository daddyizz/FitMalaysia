import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class FitLifeStore extends ChangeNotifier {
  static const _key = 'fitlife_offline_state_v1';
  SharedPreferences? _preferences;

  bool onboarded = false;
  String name = '';
  String fitnessLevel = 'Beginner';
  String goal = 'Improve Fitness';
  double? heightCm;
  double? weightKg;
  int waterTarget = 8;
  int waterToday = 0;
  int xp = 0;
  bool darkMode = true;
  final List<String> favorites = [];
  final List<WorkoutLog> history = [];
  final List<double> weights = [];

  int get level => (xp ~/ 100) + 1;
  int get totalCalories => history.fold(0, (sum, item) => sum + item.calories);
  int get totalMinutes => history.fold(0, (sum, item) => sum + item.minutes);
  double? get bmi => heightCm == null || weightKg == null || heightCm! <= 0 ? null : weightKg! / ((heightCm! / 100) * (heightCm! / 100));

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    final raw = _preferences!.getString(_key);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      onboarded = data['onboarded'] as bool? ?? false;
      name = data['name'] as String? ?? '';
      fitnessLevel = data['fitnessLevel'] as String? ?? fitnessLevel;
      goal = data['goal'] as String? ?? goal;
      heightCm = (data['heightCm'] as num?)?.toDouble();
      weightKg = (data['weightKg'] as num?)?.toDouble();
      waterTarget = data['waterTarget'] as int? ?? waterTarget;
      waterToday = data['waterToday'] as int? ?? 0;
      xp = data['xp'] as int? ?? 0;
      darkMode = data['darkMode'] as bool? ?? true;
      if (data['designVersion'] != 2) darkMode = true;
      favorites.addAll((data['favorites'] as List<dynamic>? ?? []).cast<String>());
      weights.addAll((data['weights'] as List<dynamic>? ?? []).map((e) => (e as num).toDouble()));
      history.addAll((data['history'] as List<dynamic>? ?? []).map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      await _preferences!.remove(_key);
    }
  }

  Future<void> _save() async {
    await _preferences?.setString(_key, jsonEncode({
      'onboarded': onboarded, 'name': name, 'fitnessLevel': fitnessLevel, 'goal': goal,
      'heightCm': heightCm, 'weightKg': weightKg, 'waterTarget': waterTarget, 'waterToday': waterToday,
      'xp': xp, 'darkMode': darkMode, 'designVersion': 2, 'favorites': favorites, 'weights': weights,
      'history': history.map((item) => item.toJson()).toList(),
    }));
  }

  void completeOnboarding({required String profileName, required String level, required String profileGoal}) {
    name = profileName.trim(); fitnessLevel = level; goal = profileGoal; onboarded = true; _changed();
  }
  void updateProfile({String? profileName, String? level, String? profileGoal, double? height, double? weight}) {
    if (profileName != null) name = profileName.trim(); if (level != null) fitnessLevel = level; if (profileGoal != null) goal = profileGoal;
    if (height != null) heightCm = height; if (weight != null) { weightKg = weight; weights.insert(0, weight); } _changed();
  }
  void addWater(int amount) { waterToday = (waterToday + amount).clamp(0, 50).toInt(); if (waterToday >= waterTarget && amount > 0) xp += 10; _changed(); }
  void toggleFavorite(String id) { favorites.contains(id) ? favorites.remove(id) : favorites.add(id); _changed(); }
  void completeWorkout(Workout workout) { history.insert(0, WorkoutLog(name: workout.name, completedAt: DateTime.now(), minutes: workout.minutes, calories: workout.calories, xp: 50)); xp += 50; _changed(); }
  void setDarkMode(bool value) { darkMode = value; _changed(); }
  void setWaterTarget(int value) { waterTarget = value; _changed(); }
  void resetProgress() { waterToday = 0; xp = 0; history.clear(); weights.clear(); _changed(); }
  Future<void> resetEverything() async { await _preferences?.remove(_key); onboarded = false; name = ''; fitnessLevel = 'Beginner'; goal = 'Improve Fitness'; heightCm = null; weightKg = null; waterTarget = 8; waterToday = 0; xp = 0; darkMode = true; favorites.clear(); history.clear(); weights.clear(); notifyListeners(); }
  void _changed() { _save(); notifyListeners(); }
}
