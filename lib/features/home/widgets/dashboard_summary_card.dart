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
    final progress = (water / 8).clamp(0.0, 1.0);

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
                Icon(
                  Icons.dashboard,
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  "Statistik Hari Ini",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "💧 Pengambilan Air",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 8),

            Text("$water / 8 gelas"),

            const Divider(height: 30),

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
                        ? "BMI belum dikira"
                        : "BMI ${bmi!.toStringAsFixed(1)} ($bmiResult)",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    icon: Icons.fitness_center,
                    title: "Workout",
                    value: "6",
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.restaurant,
                    title: "Nutrition",
                    value: "5",
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    icon: Icons.article,
                    title: "Artikel",
                    value: "5",
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.water_drop,
                    title: "Target Air",
                    value: "8",
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}