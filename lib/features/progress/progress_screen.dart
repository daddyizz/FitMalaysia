import 'package:flutter/material.dart';
import '../history/history_screen.dart';
import 'daily_streak_screen.dart';
import 'weekly_statistics_screen.dart';
import 'achievement_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text("Daily Streak"),
              subtitle: const Text("Lihat streak harian anda"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyStreakScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Weekly Statistics"),
              subtitle: const Text("Lihat statistik latihan minggu ini"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeeklyStatisticsScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Workout History"),
              subtitle: const Text("Lihat sejarah workout"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text("Achievements"),
              subtitle: const Text("Lihat pencapaian anda"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AchievementScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}