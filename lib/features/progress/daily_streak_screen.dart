import 'package:flutter/material.dart';
import '../../services/streak_service.dart';

class DailyStreakScreen extends StatelessWidget {
  const DailyStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Streak"),
      ),
      body: FutureBuilder<int>(
        future: StreakService.calculateCurrentStreak(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Ralat mendapatkan data."),
            );
          }

          final streak = snapshot.data ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🔥",
                  style: TextStyle(fontSize: 70),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Current Streak",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$streak Hari",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Keep it up! 💪",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}