import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../services/achievement_service.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: FutureBuilder<List<Achievement>>(
        future: AchievementService.getAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Ralat mendapatkan achievements."),
            );
          }

          final achievements = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];

              return Card(
                child: ListTile(
                  leading: Icon(
                    achievement.icon,
                    color: achievement.unlocked
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  title: Text(achievement.title),
                  subtitle: Text(achievement.description),
                  trailing: Icon(
                    achievement.unlocked
                        ? Icons.check_circle
                        : Icons.lock,
                    color: achievement.unlocked
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}