import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutTip extends StatelessWidget {
  final Workout workout;

  const WorkoutTip({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workout.tip,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${workout.title} Timer akan datang 💪",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              "MULAKAN SENAMAN",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}