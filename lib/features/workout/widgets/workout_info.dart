import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutInfo extends StatelessWidget {
  final Workout workout;

  const WorkoutInfo({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfo(
          "⏱ Tempoh",
          workout.duration,
        ),

        _buildInfo(
          "🔥 Kalori",
          "${workout.calories} kcal",
        ),

        _buildInfo(
          "📈 Tahap",
          workout.difficulty,
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInfo(
      String title,
      String value,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}