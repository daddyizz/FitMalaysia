import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'widgets/feature_card.dart';
import 'widgets/health_tip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Selamat Datang 👋',
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modul Senaman akan datang 🚀'),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.restaurant_menu,
                  title: 'Pemakanan',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modul Pemakanan akan datang 🚀'),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.article,
                  title: 'Artikel',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modul Artikel akan datang 🚀'),
                      ),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.monitor_weight,
                  title: 'BMI',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Modul BMI akan datang 🚀'),
                      ),
                    );
                  },
                ),
              ],
            ),

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