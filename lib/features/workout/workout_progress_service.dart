import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firestore_service.dart';

class WorkoutProgressService {
  static const String workoutCountKey = 'workout_count';
  static const String workoutMinutesKey = 'workout_minutes';

  static Future<void> completeWorkout(int minutes) async {
    final prefs = await SharedPreferences.getInstance();

    final count = prefs.getInt(workoutCountKey) ?? 0;
    final totalMinutes = prefs.getInt(workoutMinutesKey) ?? 0;

    final newCount = count + 1;
    final newMinutes = totalMinutes + minutes;

    // Simpan dalam telefon
    await prefs.setInt(workoutCountKey, newCount);
    await prefs.setInt(workoutMinutesKey, newMinutes);

    // Backup ke Firebase
    try {
      await FirestoreService.updateWorkoutStats(
        workoutCount: newCount,
        workoutMinutes: newMinutes,
      );
    } catch (e) {
      print("Firestore Sync Error: $e");
    }
  }

  static Future<int> getWorkoutCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(workoutCountKey) ?? 0;
  }

  static Future<int> getWorkoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(workoutMinutesKey) ?? 0;
  }

  static Future<String> getAchievement() async {
    final count = await getWorkoutCount();

    if (count >= 100) return "👑 Legend FitMalaysia";
    if (count >= 50) return "💪 Atlet";
    if (count >= 25) return "🥇 Aktif";
    if (count >= 10) return "🥈 Konsisten";
    if (count >= 1) return "🥉 Permulaan Hebat";

    return "Belum Bermula";
  }
}