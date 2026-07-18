import 'package:flutter/material.dart';

class DailyGoalCard extends StatelessWidget {
  final int water;
  final bool workoutDone;

  const DailyGoalCard({
    super.key,
    required this.water,
    required this.workoutDone,
  });

  @override
  Widget build(BuildContext context) {
    final completed = (workoutDone ? 1 : 0) + (water >= 8 ? 1 : 0);
    final progress = completed / 2;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flag, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Sasaran Hari Ini',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            CheckboxListTile(
              value: workoutDone,
              onChanged: null,
              title: const Text('Workout selesai'),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            CheckboxListTile(
              value: water >= 8,
              onChanged: null,
              title: Text('Minum air ($water/8 gelas)'),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 8),

            Text(
              '${(progress * 100).toInt()}% selesai',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}