import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createUserIfNotExists() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = _db.collection("users").doc(user.uid);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        "createdAt": FieldValue.serverTimestamp(),
        "workoutCount": 0,
        "workoutMinutes": 0,
        "water": 0,
        "achievement": "",
      });
    }
  }

  static Future<void> updateWorkoutStats({
    required int workoutCount,
    required int workoutMinutes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await _db.collection("users").doc(user.uid).update({
      "workoutCount": workoutCount,
      "workoutMinutes": workoutMinutes,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}