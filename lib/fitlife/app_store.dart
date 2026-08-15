import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AchievementNotice {
  const AchievementNotice({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });
  final String id;
  final String icon;
  final String title;
  final String description;
}

class FitLifeStore extends ChangeNotifier {
  static const _key = 'fitlife_offline_state_v1';
  SharedPreferences? _preferences;
  bool _restoring = false;

  bool onboarded = false;
  String name = '';
  String avatarStyle = 'cat';
  String fitnessLevel = 'Beginner';
  String goal = 'Improve Fitness';
  double? heightCm;
  double? weightKg;
  int weeklyWorkoutTarget = 3;
  int preferredSessionMinutes = 10;
  int waterTarget = 8;
  DateTime? planStartDate;
  int xp = 0;
  bool darkMode = true;
  String themePreference = 'dark';
  bool timerSounds = true;
  bool restBetweenExercises = true;
  bool waterReminders = false;
  bool workoutReminders = false;
  int workoutReminderHour = 19;
  int workoutReminderMinute = 0;
  bool healthConnectEnabled = false;
  int healthStepsToday = 0;
  String? healthStepsDateKey;
  DateTime? healthLastSyncAt;
  DateTime lastModifiedAt = DateTime.fromMillisecondsSinceEpoch(0);
  final List<String> favorites = [];
  final List<WorkoutLog> history = [];
  final List<WeightLog> weightHistory = [];
  final Map<String, int> waterByDate = {};
  final Set<String> waterGoalRewardedDates = {};
  final Set<String> dailyCheckInDates = {};
  final Set<String> unlockedAchievementIds = {};

  int get level => (xp ~/ 100) + 1;
  int get totalCalories => history.fold(0, (sum, item) => sum + item.calories);
  int get totalMinutes => history.fold(0, (sum, item) => sum + item.minutes);
  List<double> get weights =>
      weightHistory.map((entry) => entry.valueKg).toList(growable: false);
  int get waterToday => waterByDate[_dateKey(DateTime.now())] ?? 0;
  List<WorkoutLog> get todayHistory {
    final today = DateUtils.dateOnly(DateTime.now());
    return history
        .where((item) => DateUtils.isSameDay(item.completedAt, today))
        .toList(growable: false);
  }

  int get todayCalories =>
      todayHistory.fold(0, (sum, item) => sum + item.calories);
  int get todayMinutes =>
      todayHistory.fold(0, (sum, item) => sum + item.minutes);
  double? get bmi => heightCm == null || weightKg == null || heightCm! <= 0
      ? null
      : weightKg! / ((heightCm! / 100) * (heightCm! / 100));

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    final raw = _preferences!.getString(_key);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      favorites.clear();
      history.clear();
      weightHistory.clear();
      waterByDate.clear();
      waterGoalRewardedDates.clear();
      dailyCheckInDates.clear();
      unlockedAchievementIds.clear();
      onboarded = data['onboarded'] as bool? ?? false;
      name = data['name'] as String? ?? '';
      avatarStyle = data['avatarStyle'] as String? ?? avatarStyle;
      fitnessLevel = data['fitnessLevel'] as String? ?? fitnessLevel;
      goal = data['goal'] as String? ?? goal;
      heightCm = (data['heightCm'] as num?)?.toDouble();
      weightKg = (data['weightKg'] as num?)?.toDouble();
      weeklyWorkoutTarget =
          data['weeklyWorkoutTarget'] as int? ?? weeklyWorkoutTarget;
      preferredSessionMinutes =
          data['preferredSessionMinutes'] as int? ?? preferredSessionMinutes;
      waterTarget = data['waterTarget'] as int? ?? waterTarget;
      planStartDate = DateTime.tryParse(data['planStartDate'] as String? ?? '');
      xp = data['xp'] as int? ?? 0;
      darkMode = data['darkMode'] as bool? ?? true;
      if ((data['designVersion'] as int? ?? 0) < 2) darkMode = true;
      themePreference =
          data['themePreference'] as String? ?? (darkMode ? 'dark' : 'light');
      timerSounds = data['timerSounds'] as bool? ?? true;
      restBetweenExercises = data['restBetweenExercises'] as bool? ?? true;
      waterReminders = data['waterReminders'] as bool? ?? false;
      workoutReminders = data['workoutReminders'] as bool? ?? false;
      workoutReminderHour = data['workoutReminderHour'] as int? ?? 19;
      workoutReminderMinute = data['workoutReminderMinute'] as int? ?? 0;
      healthConnectEnabled = data['healthConnectEnabled'] as bool? ?? false;
      healthStepsToday = data['healthStepsToday'] as int? ?? 0;
      healthStepsDateKey = data['healthStepsDateKey'] as String?;
      healthLastSyncAt = DateTime.tryParse(
        data['healthLastSyncAt'] as String? ?? '',
      );
      lastModifiedAt =
          DateTime.tryParse(data['lastModifiedAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      favorites.addAll(
        (data['favorites'] as List<dynamic>? ?? []).cast<String>(),
      );
      history.addAll(
        (data['history'] as List<dynamic>? ?? []).map(
          (e) => WorkoutLog.fromJson(e as Map<String, dynamic>),
        ),
      );
      final savedWeightHistory = data['weightHistory'] as List<dynamic>?;
      if (savedWeightHistory != null) {
        weightHistory.addAll(
          savedWeightHistory.map(
            (item) => WeightLog.fromJson(item as Map<String, dynamic>),
          ),
        );
      } else {
        final legacyWeights = (data['weights'] as List<dynamic>? ?? [])
            .map((item) => (item as num).toDouble())
            .toList();
        final now = DateTime.now();
        for (var index = 0; index < legacyWeights.length; index++) {
          weightHistory.add(
            WeightLog(
              valueKg: legacyWeights[index],
              recordedAt: now.subtract(Duration(days: index)),
            ),
          );
        }
      }
      final savedWaterByDate = data['waterByDate'] as Map<String, dynamic>?;
      if (savedWaterByDate != null) {
        waterByDate.addAll(
          savedWaterByDate.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ),
        );
      } else {
        final legacyWater = data['waterToday'] as int? ?? 0;
        if (legacyWater > 0) {
          waterByDate[_dateKey(DateTime.now())] = legacyWater;
        }
      }
      waterGoalRewardedDates.addAll(
        (data['waterGoalRewardedDates'] as List<dynamic>? ?? []).cast<String>(),
      );
      dailyCheckInDates.addAll(
        (data['dailyCheckInDates'] as List<dynamic>? ?? []).cast<String>(),
      );
      if (onboarded && planStartDate == null) {
        planStartDate = DateUtils.dateOnly(DateTime.now());
      }
      unlockedAchievementIds.addAll(
        (data['unlockedAchievementIds'] as List<dynamic>? ?? []).cast<String>(),
      );
    } catch (_) {
      await _preferences!.remove(_key);
    }
  }

  Future<void> _save() async {
    await _preferences?.setString(_key, jsonEncode(exportCloudData()));
  }

  Map<String, dynamic> exportCloudData() => {
    'onboarded': onboarded,
    'name': name,
    'fitnessLevel': fitnessLevel,
    'goal': goal,
    'avatarStyle': avatarStyle,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'weeklyWorkoutTarget': weeklyWorkoutTarget,
    'preferredSessionMinutes': preferredSessionMinutes,
    'waterTarget': waterTarget,
    'planStartDate': planStartDate?.toIso8601String(),
    'xp': xp,
    'darkMode': darkMode,
    'themePreference': themePreference,
    'timerSounds': timerSounds,
    'restBetweenExercises': restBetweenExercises,
    'waterReminders': waterReminders,
    'workoutReminders': workoutReminders,
    'workoutReminderHour': workoutReminderHour,
    'workoutReminderMinute': workoutReminderMinute,
    'healthConnectEnabled': healthConnectEnabled,
    'healthStepsToday': healthStepsToday,
    'healthStepsDateKey': healthStepsDateKey,
    'healthLastSyncAt': healthLastSyncAt?.toIso8601String(),
    'lastModifiedAt': lastModifiedAt.toIso8601String(),
    'designVersion': 3,
    'favorites': favorites,
    'weightHistory': weightHistory.map((item) => item.toJson()).toList(),
    'waterByDate': waterByDate,
    'waterGoalRewardedDates': waterGoalRewardedDates.toList(),
    'dailyCheckInDates': dailyCheckInDates.toList(),
    'history': history.map((item) => item.toJson()).toList(),
    'unlockedAchievementIds': unlockedAchievementIds.toList(),
  };

  Future<void> restoreCloudData(Map<String, dynamic> data) async {
    _restoring = true;
    try {
      await _preferences?.setString(_key, jsonEncode(data));
      await load();
    } finally {
      _restoring = false;
    }
    notifyListeners();
  }

  void completeOnboarding({
    required String profileName,
    required String level,
    required String profileGoal,
    int workoutsPerWeek = 3,
    int sessionMinutes = 10,
  }) {
    name = profileName.trim();
    fitnessLevel = level;
    goal = profileGoal;
    weeklyWorkoutTarget = workoutsPerWeek;
    preferredSessionMinutes = sessionMinutes;
    planStartDate = DateUtils.dateOnly(DateTime.now());
    onboarded = true;
    _changed();
  }

  void updateProfile({
    String? profileName,
    String? level,
    String? profileGoal,
    double? height,
    double? weight,
  }) {
    if (profileName != null) name = profileName.trim();
    if (level != null) fitnessLevel = level;
    if (profileGoal != null) goal = profileGoal;
    if (height != null) heightCm = height;
    if (weight != null) {
      weightKg = weight;
      weightHistory.insert(
        0,
        WeightLog(valueKg: weight, recordedAt: DateTime.now()),
      );
    }
    _changed();
  }

  void setAvatarStyle(String style) {
    avatarStyle = style;
    _changed();
  }

  void addWater(int amount) {
    final todayKey = _dateKey(DateTime.now());
    final previous = waterByDate[todayKey] ?? 0;
    final next = (previous + amount).clamp(0, 50).toInt();
    if (next == 0) {
      waterByDate.remove(todayKey);
    } else {
      waterByDate[todayKey] = next;
    }
    if (previous < waterTarget &&
        next >= waterTarget &&
        waterGoalRewardedDates.add(todayKey)) {
      xp += 10;
    }
    _changed();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _changed();
  }

  AchievementNotice? completeWorkout(Workout workout) {
    history.insert(
      0,
      WorkoutLog(
        name: workout.name,
        completedAt: DateTime.now(),
        minutes: workout.minutes,
        calories: workout.calories,
        xp: 50,
      ),
    );
    xp += 50;
    final achievement = _newWorkoutAchievement();
    _changed();
    return achievement;
  }

  void setDarkMode(bool value) {
    darkMode = value;
    themePreference = value ? 'dark' : 'light';
    _changed();
  }

  void setThemePreference(String value) {
    themePreference = value;
    darkMode = value != 'light';
    _changed();
  }

  void updatePreferences({
    bool? sounds,
    bool? rest,
    bool? water,
    bool? workout,
  }) {
    if (sounds != null) timerSounds = sounds;
    if (rest != null) restBetweenExercises = rest;
    if (water != null) waterReminders = water;
    if (workout != null) workoutReminders = workout;
    _changed();
  }

  void setWorkoutReminderTime(int hour, int minute) {
    workoutReminderHour = hour;
    workoutReminderMinute = minute;
    _changed();
  }

  int get currentHealthSteps =>
      healthStepsDateKey == _dateKey(DateTime.now()) ? healthStepsToday : 0;

  void applyHealthConnectData({required int steps, double? weight}) {
    healthConnectEnabled = true;
    healthStepsToday = steps;
    healthStepsDateKey = _dateKey(DateTime.now());
    healthLastSyncAt = DateTime.now();
    if (weight != null && weight > 0) {
      final changed = weightKg == null || (weightKg! - weight).abs() >= .05;
      weightKg = weight;
      if (changed) {
        weightHistory.insert(
          0,
          WeightLog(valueKg: weight, recordedAt: DateTime.now()),
        );
      }
    }
    _changed();
  }

  void disconnectHealthConnect() {
    healthConnectEnabled = false;
    healthStepsToday = 0;
    healthStepsDateKey = null;
    healthLastSyncAt = null;
    _changed();
  }

  void setWeeklyWorkoutTarget(int value) {
    weeklyWorkoutTarget = value;
    _changed();
  }

  void setPreferredSessionMinutes(int value) {
    preferredSessionMinutes = value;
    _changed();
  }

  bool get checkedInToday =>
      dailyCheckInDates.contains(_dateKey(DateTime.now()));

  void checkInToday() {
    if (dailyCheckInDates.add(_dateKey(DateTime.now()))) {
      xp += 5;
      _changed();
    }
  }

  void restartPlan() {
    planStartDate = DateUtils.dateOnly(DateTime.now());
    _changed();
  }

  void setWaterTarget(int value) {
    waterTarget = value;
    _changed();
  }

  void resetProgress() {
    waterByDate.clear();
    waterGoalRewardedDates.clear();
    dailyCheckInDates.clear();
    xp = 0;
    history.clear();
    weightHistory.clear();
    unlockedAchievementIds.clear();
    _changed();
  }

  Future<void> resetEverything() async {
    await _preferences?.remove(_key);
    onboarded = false;
    name = '';
    avatarStyle = 'cat';
    fitnessLevel = 'Beginner';
    goal = 'Improve Fitness';
    heightCm = null;
    weightKg = null;
    weeklyWorkoutTarget = 3;
    preferredSessionMinutes = 10;
    waterTarget = 8;
    planStartDate = null;
    xp = 0;
    darkMode = true;
    themePreference = 'dark';
    timerSounds = true;
    restBetweenExercises = true;
    waterReminders = false;
    workoutReminders = false;
    workoutReminderHour = 19;
    workoutReminderMinute = 0;
    healthConnectEnabled = false;
    healthStepsToday = 0;
    healthStepsDateKey = null;
    healthLastSyncAt = null;
    favorites.clear();
    history.clear();
    weightHistory.clear();
    waterByDate.clear();
    waterGoalRewardedDates.clear();
    dailyCheckInDates.clear();
    unlockedAchievementIds.clear();
    lastModifiedAt = DateTime.now().toUtc();
    notifyListeners();
  }

  AchievementNotice? _newWorkoutAchievement() {
    final choices = <AchievementNotice>[
      const AchievementNotice(
        id: 'first-workout',
        icon: '🏆',
        title: 'First Workout',
        description: 'Complete your first workout.',
      ),
      if (history.length >= 10)
        const AchievementNotice(
          id: 'workouts-10',
          icon: '💪',
          title: '10 Workouts',
          description: 'Complete 10 workouts.',
        ),
      if (history.length >= 50)
        const AchievementNotice(
          id: 'workouts-50',
          icon: '💪',
          title: '50 Workouts',
          description: 'Complete 50 workouts.',
        ),
      if (xp >= 100)
        const AchievementNotice(
          id: 'xp-100',
          icon: '⭐',
          title: '100 XP',
          description: 'Earn 100 XP.',
        ),
      if (totalCalories >= 1000)
        const AchievementNotice(
          id: 'calories-1000',
          icon: '🔥',
          title: '1000 Calories',
          description: 'Burn 1000 calories in total.',
        ),
      if (DateTime.now().hour < 8)
        const AchievementNotice(
          id: 'early-bird',
          icon: '🌅',
          title: 'Early Bird',
          description: 'Finish a workout before 8 AM.',
        ),
    ];
    for (final achievement in choices) {
      if (unlockedAchievementIds.add(achievement.id)) return achievement;
    }
    return null;
  }

  static String _dateKey(DateTime value) {
    final date = DateUtils.dateOnly(value);
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void _changed() {
    if (!_restoring) lastModifiedAt = DateTime.now().toUtc();
    _save();
    notifyListeners();
  }
}
