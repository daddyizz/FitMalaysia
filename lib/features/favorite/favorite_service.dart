import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const workoutKey = "favorite_workouts";
  static const nutritionKey = "favorite_nutrition";
  static const articleKey = "favorite_articles";

  static Future<List<String>> getFavorites(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(key) ?? [];
  }

  static Future<bool> isFavorite(
      String key,
      String title,
      ) async {
    final favorites = await getFavorites(key);

    return favorites.contains(title);
  }

  static Future<void> toggleFavorite(
      String key,
      String title,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites(key);

    if (favorites.contains(title)) {
      favorites.remove(title);
    } else {
      favorites.add(title);
    }

    await prefs.setStringList(key, favorites);
  }
}