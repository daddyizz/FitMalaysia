
import 'package:flutter/material.dart';
import 'nutrition_detail_screen.dart';
import 'data/food_data.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Pemakanan"),
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: foodData.length,

        itemBuilder: (context,index){

          final food = foodData[index];

          return Card(

            margin: const EdgeInsets.only(bottom:12),

            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NutritionDetailScreen(
                      food: food,
                    ),
                  ),
                );
              },

              leading: const CircleAvatar(
                child: Text("🍽"),
              ),

              title: Text(food.name),

              subtitle: Text(
                "${food.calories} kcal",
              ),

            ),

          );

        },

      ),

    );

  }

}