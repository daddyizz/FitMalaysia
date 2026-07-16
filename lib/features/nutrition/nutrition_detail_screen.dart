import 'package:flutter/material.dart';

import 'models/food.dart';

class NutritionDetailScreen extends StatelessWidget {
  final Food food;

  const NutritionDetailScreen({
    super.key,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(food.name),
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
            child: const Center(
              child: Text(
                "🍽️\nIlustrasi Makanan\n(Akan ditambah kemudian)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _buildInfo("🔥 Kalori", "${food.calories} kcal"),
          _buildInfo("🥩 Protein", "${food.protein} g"),
          _buildInfo("🍚 Karbohidrat", "${food.carbs} g"),
          _buildInfo("🥑 Lemak", "${food.fat} g"),

          const SizedBox(height: 30),

          const Text(
            "💡 Cadangan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Nikmati makanan ini secara sederhana dan seimbangkan dengan sayur-sayuran serta air kosong.",
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
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