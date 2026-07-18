import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakService {
  static Future<int> calculateCurrentStreak() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .orderBy('completedAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final Set<DateTime> workoutDays = {};

    for (final doc in snapshot.docs) {
      final timestamp = doc['completedAt'] as Timestamp?;
      if (timestamp == null) continue;

      final date = timestamp.toDate();

      workoutDays.add(
        DateTime(
          date.year,
          date.month,
          date.day,
        ),
      );
    }

    int streak = 0;

    DateTime current = DateTime.now();

    current = DateTime(
      current.year,
      current.month,
      current.day,
    );

    while (workoutDays.contains(current)) {
      streak++;

      current = current.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }
}