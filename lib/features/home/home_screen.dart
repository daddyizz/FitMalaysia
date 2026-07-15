import 'package:flutter/material.dart';

import 'widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitMalaysia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Mari kekal sihat hari ini!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  FeatureCard(
                    icon: Icons.fitness_center,
                    title: 'Senaman',
                  ),
                  FeatureCard(
                    icon: Icons.restaurant_menu,
                    title: 'Pemakanan',
                  ),
                  FeatureCard(
                    icon: Icons.article,
                    title: 'Artikel',
                  ),
                  FeatureCard(
                    icon: Icons.monitor_weight,
                    title: 'BMI',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}