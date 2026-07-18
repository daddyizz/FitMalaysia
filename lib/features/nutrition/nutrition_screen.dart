import 'package:flutter/material.dart';
import 'nutrition_detail_screen.dart';
import 'data/food_data.dart';
import 'package:fitmalaysia/widgets/empty_state.dart';
import 'models/food.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String search = "";

  late List<Food> filteredFood;

  @override
  void initState() {
    super.initState();
    filteredFood = foodData;
  }

  void searchFood(String value) {
    setState(() {
      search = value;

      filteredFood = foodData.where((food) {
        return food.name
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pemakanan"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: searchFood,
              decoration: const InputDecoration(
                hintText: "Cari makanan...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredFood.isEmpty
                ? const EmptyState(
              icon: Icons.restaurant_menu,
              title: 'Tiada Makanan Dijumpai',
              message: 'Cuba gunakan kata kunci lain.',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFood.length,
              itemBuilder: (context, index) {
                final food = filteredFood[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                    subtitle: Text("${food.calories} kcal"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}