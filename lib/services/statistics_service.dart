import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsService {
  static Future<int> getWeeklyWorkoutCount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return 0;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .where(
      'completedAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
    )
        .get();

    return snapshot.docs.length;
  }

  static Future<int> getWeeklyWorkoutMinutes() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return 0;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .where(
      'completedAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
    )
        .get();

    int totalMinutes = 0;

    for (final doc in snapshot.docs) {
      totalMinutes += (doc['duration'] as num?)?.toInt() ?? 0;
    }

    return totalMinutes;
  }
}