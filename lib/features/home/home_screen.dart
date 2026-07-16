import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/feature_card.dart';
import 'widgets/health_tip_card.dart';
import '../workout/workout_screen.dart';
import 'widgets/water_tracker_card.dart';
import '../nutrition/nutrition_screen.dart';
import '../bmi/bmi_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> quotes = [
    "Kesihatan adalah pelaburan terbaik untuk masa depan.",
    "Sedikit senaman setiap hari lebih baik daripada tiada langsung.",
    "Jangan putus asa. Kemajuan kecil tetap kemajuan.",
    "Hari ini lebih baik daripada semalam.",
    "Konsisten mengalahkan motivasi.",
  ];

  @override
  Widget build(BuildContext context) {
    final quote = quotes[
    DateTime.now().day % quotes.length
    ];
    final hour = DateTime.now().hour;

    String greeting;

    if (hour < 12) {
      greeting = "🌅 Selamat Pagi";
    } else if (hour < 15) {
      greeting = "☀️ Selamat Tengah Hari";
    } else if (hour < 19) {
      greeting = "🌇 Selamat Petang";
    } else {
      greeting = "🌙 Selamat Malam";
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('FitMalaysia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mari kekal sihat hari ini!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade700,
                    Colors.green.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                    Text(
                      quote,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: Colors.white,
                      ),

                      SizedBox(width: 8),

                      Text(
                        "Sasaran Hari Ini",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Text(
                    "✔ Sasaran: 30 minit senaman hari ini",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                FeatureCard(
                  icon: Icons.fitness_center,
                  title: 'Senaman',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkoutScreen(),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.restaurant_menu,
                  title: 'Pemakanan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NutritionScreen(),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.article,
                  title: 'Artikel',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BmiScreen(),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.monitor_weight,
                  title: 'BMI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BmiScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            const WaterTrackerCard(),

            const SizedBox(height: 24),

            const HealthTipCard(
              tip:
              'Berjalan sekurang-kurangnya 30 minit setiap hari dapat membantu meningkatkan kesihatan jantung.',
            ),
          ],
        ),
      ),
    );
  }
}