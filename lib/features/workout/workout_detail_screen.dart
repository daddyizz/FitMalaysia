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
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '🖼️ Ilustrasi Senaman\n(Akan diganti kemudian)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Tahap: ${workout.difficulty}',
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 8),

          Text(
            'Tempoh: ${workout.duration}',
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 8),

          Text(
            'Anggaran Kalori: ${workout.calories} kcal',
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 24),

          const Text(
            'Cara Melakukan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            '1. Letakkan kedua-dua tangan sedikit lebih lebar daripada bahu.\n\n'
                '2. Turunkan badan sehingga dada hampir menyentuh lantai.\n\n'
                '3. Tolak badan kembali ke posisi asal.\n\n'
                '4. Ulang mengikut kemampuan.',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Workout Timer akan datang 💪',
                    ),
                  ),
                );
              },
              child: const Text(
                'MULAKAN SENAMAN',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}