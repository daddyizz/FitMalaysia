import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String workoutKey = "favorite_workouts";

  static Future<List<String>> getFavoriteWorkouts() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(workoutKey) ?? [];
  }

  static Future<bool> isWorkoutFavorite(String title) async {
    final favorites = await getFavoriteWorkouts();

    return favorites.contains(title);
  }

  static Future<void> toggleWorkoutFavorite(String title) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavoriteWorkouts();

    if (favorites.contains(title)) {
      favorites.remove(title);
    } else {
      favorites.add(title);
    }

    await prefs.setStringList(workoutKey, favorites);
  }
}