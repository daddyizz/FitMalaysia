import 'package:flutter/material.dart';
import '../../services/statistics_service.dart';
import '../../widgets/stat_card.dart';

class WeeklyStatisticsScreen extends StatelessWidget {
  const WeeklyStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Statistics"),
      ),
      body: FutureBuilder<List<int>>(
        future: Future.wait([
          StatisticsService.getWeeklyWorkoutCount(),
          StatisticsService.getWeeklyWorkoutMinutes(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Ralat mendapatkan statistik."),
            );
          }

          final data = snapshot.data ?? [0, 0];

          final totalWorkout = data[0];
          final totalMinutes = data[1];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bar_chart,
                  size: 70,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),

                StatCard(
                  icon: Icons.fitness_center,
                  title: "Workout Minggu Ini",
                  value: "$totalWorkout Sesi",
                ),

                const SizedBox(height: 16),

                StatCard(
                  icon: Icons.timer,
                  title: "Jumlah Minit",
                  value: "$totalMinutes min",
                ),
              ],
            )
          );
        },
      ),
    );
  }
}