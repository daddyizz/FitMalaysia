import 'package:flutter/material.dart';
import 'models/workout.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                workout.icon,
                size: 90,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            workout.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          _buildInfo("⏱ Tempoh", workout.duration),
          _buildInfo("🔥 Kalori", "${workout.calories} kcal"),
          _buildInfo("📈 Tahap", workout.difficulty),

          const SizedBox(height: 30),

          const Text(
            "📋 Cara Melakukan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...workout.steps.asMap().entries.map(
                (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "${entry.key + 1}. ${entry.value}",
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "💪 Kelebihan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...workout.benefits.map(
                (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("✅ "),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

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
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
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