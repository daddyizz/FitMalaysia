import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AchievementNotice {
  const AchievementNotice({required this.id, required this.icon, required this.title, required this.description});
  final String id;
  final String icon;
  final String title;
  final String description;
}

class FitLifeStore extends ChangeNotifier {
  static const _key = 'fitlife_offline_state_v1';
  SharedPreferences? _preferences;

  bool onboarded = false;
  String name = '';
  String fitnessLevel = 'Beginner';
  String goal = 'Improve Fitness';
  double? heightCm;
  double? weightKg;
  int weeklyWorkoutTarget = 3;
  int waterTarget = 8;
  int waterToday = 0;
  int xp = 0;
  bool darkMode = true;
  String themePreference = 'dark';
  bool timerSounds = true;
  bool restBetweenExercises = true;
  bool waterReminders = false;
  bool workoutReminders = false;
  final List<String> favorites = [];
  final List<WorkoutLog> history = [];
  final List<double> weights = [];
  final Set<String> unlockedAchievementIds = {};

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
      weeklyWorkoutTarget = data['weeklyWorkoutTarget'] as int? ?? weeklyWorkoutTarget;
      waterTarget = data['waterTarget'] as int? ?? waterTarget;
      waterToday = data['waterToday'] as int? ?? 0;
      xp = data['xp'] as int? ?? 0;
      darkMode = data['darkMode'] as bool? ?? true;
      if (data['designVersion'] != 2) darkMode = true;
      themePreference = data['themePreference'] as String? ?? (darkMode ? 'dark' : 'light');
      timerSounds = data['timerSounds'] as bool? ?? true;
      restBetweenExercises = data['restBetweenExercises'] as bool? ?? true;
      waterReminders = data['waterReminders'] as bool? ?? false;
      workoutReminders = data['workoutReminders'] as bool? ?? false;
      favorites.addAll((data['favorites'] as List<dynamic>? ?? []).cast<String>());
      weights.addAll((data['weights'] as List<dynamic>? ?? []).map((e) => (e as num).toDouble()));
      history.addAll((data['history'] as List<dynamic>? ?? []).map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>)));
      unlockedAchievementIds.addAll((data['unlockedAchievementIds'] as List<dynamic>? ?? []).cast<String>());
    } catch (_) {
      await _preferences!.remove(_key);
    }
  }

  Future<void> _save() async {
    await _preferences?.setString(_key, jsonEncode({
      'onboarded': onboarded, 'name': name, 'fitnessLevel': fitnessLevel, 'goal': goal,
      'heightCm': heightCm, 'weightKg': weightKg, 'weeklyWorkoutTarget': weeklyWorkoutTarget, 'waterTarget': waterTarget, 'waterToday': waterToday,
      'xp': xp, 'darkMode': darkMode, 'themePreference': themePreference, 'timerSounds': timerSounds, 'restBetweenExercises': restBetweenExercises, 'waterReminders': waterReminders, 'workoutReminders': workoutReminders, 'designVersion': 2, 'favorites': favorites, 'weights': weights,
      'history': history.map((item) => item.toJson()).toList(), 'unlockedAchievementIds': unlockedAchievementIds.toList(),
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
  AchievementNotice? completeWorkout(Workout workout) {
    history.insert(0, WorkoutLog(name: workout.name, completedAt: DateTime.now(), minutes: workout.minutes, calories: workout.calories, xp: 50));
    xp += 50;
    final achievement = _newWorkoutAchievement();
    _changed();
    return achievement;
  }
  void setDarkMode(bool value) { darkMode = value; themePreference = value ? 'dark' : 'light'; _changed(); }
  void setThemePreference(String value) { themePreference = value; darkMode = value != 'light'; _changed(); }
  void updatePreferences({bool? sounds, bool? rest, bool? water, bool? workout}) { if (sounds != null) timerSounds = sounds; if (rest != null) restBetweenExercises = rest; if (water != null) waterReminders = water; if (workout != null) workoutReminders = workout; _changed(); }
  void setWeeklyWorkoutTarget(int value) { weeklyWorkoutTarget = value; _changed(); }
  void setWaterTarget(int value) { waterTarget = value; _changed(); }
  void resetProgress() { waterToday = 0; xp = 0; history.clear(); weights.clear(); unlockedAchievementIds.clear(); _changed(); }
  Future<void> resetEverything() async { await _preferences?.remove(_key); onboarded = false; name = ''; fitnessLevel = 'Beginner'; goal = 'Improve Fitness'; heightCm = null; weightKg = null; weeklyWorkoutTarget = 3; waterTarget = 8; waterToday = 0; xp = 0; darkMode = true; themePreference = 'dark'; timerSounds = true; restBetweenExercises = true; waterReminders = false; workoutReminders = false; favorites.clear(); history.clear(); weights.clear(); unlockedAchievementIds.clear(); notifyListeners(); }

  AchievementNotice? _newWorkoutAchievement() {
    final choices = <AchievementNotice>[
      const AchievementNotice(id: 'first-workout', icon: '🏆', title: 'First Workout', description: 'Complete your first workout.'),
      if (history.length >= 10) const AchievementNotice(id: 'workouts-10', icon: '💪', title: '10 Workouts', description: 'Complete 10 workouts.'),
      if (history.length >= 50) const AchievementNotice(id: 'workouts-50', icon: '💪', title: '50 Workouts', description: 'Complete 50 workouts.'),
      if (xp >= 100) const AchievementNotice(id: 'xp-100', icon: '⭐', title: '100 XP', description: 'Earn 100 XP.'),
      if (totalCalories >= 1000) const AchievementNotice(id: 'calories-1000', icon: '🔥', title: '1000 Calories', description: 'Burn 1000 calories in total.'),
      if (DateTime.now().hour < 8) const AchievementNotice(id: 'early-bird', icon: '🌅', title: 'Early Bird', description: 'Finish a workout before 8 AM.'),
    ];
    for (final achievement in choices) {
      if (unlockedAchievementIds.add(achievement.id)) return achievement;
    }
    return null;
  }
  void _changed() { _save(); notifyListeners(); }
}
