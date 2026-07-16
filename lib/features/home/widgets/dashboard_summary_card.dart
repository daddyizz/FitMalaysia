import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardSummaryCard extends StatefulWidget {
  const DashboardSummaryCard({super.key});

  @override
  State<DashboardSummaryCard> createState() =>
      _DashboardSummaryCardState();
}

class _DashboardSummaryCardState extends State<DashboardSummaryCard> {
  int water = 0;
  double? bmi;
  String bmiResult = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      water = prefs.getInt('water') ?? 0;
      bmi = prefs.getDouble('last_bmi');
      bmiResult = prefs.getString('last_bmi_result') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final waterProgress = water / 8;

    return Card(
      elevation: 3,
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
                Icon(
                  Icons.dashboard,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  "Ringkasan Hari Ini",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Air: $water / 8 gelas",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: waterProgress,
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(
                  Icons.monitor_weight,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    bmi == null
                        ? "BMI: Belum dikira"
                        : "BMI: ${bmi!.toStringAsFixed(1)} ($bmiResult)",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            const Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Text(
                  "Workout tersedia: 6",
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.deepOrange,
                ),
                SizedBox(width: 10),
                Text(
                  "Nutrition tersedia: 5",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}