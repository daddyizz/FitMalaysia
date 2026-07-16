import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterTrackerCard extends StatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard> {

  int water = 0;

  @override
  void initState() {
    super.initState();
    loadWater();
  }

  Future<void> loadWater() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      water = prefs.getInt('water') ?? 0;
    });
  }

  Future<void> saveWater() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('water', water);
  }

  @override
  Widget build(BuildContext context) {

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

            const Text(
              "💧 Air Hari Ini",
              style: TextStyle(
                fontSize:22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:20),

            Text(
              "Hari ini: $water / 8 gelas",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: water / 8,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            const SizedBox(height:20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                FloatingActionButton.small(
                  heroTag: "minusWater",
                  onPressed: () {
                    if (water > 0) {
                      setState(() {
                        water--;
                      });

                      saveWater();
                    }
                  },
                  child: const Icon(Icons.remove),
                ),

                const Text(
                  "💧",
                  style: TextStyle(fontSize: 40),
                ),

                FloatingActionButton.small(
                  heroTag: "plusWater",
                  onPressed: () {
                    if (water < 8) {
                      setState(() {
                        water++;
                      });

                      saveWater();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🎉 Tahniah! Sasaran air hari ini telah dicapai."),
                        ),
                      );
                    }
                  },
                  child: const Icon(Icons.add),
                ),

              ],
            )

          ],

        ),

      ),

    );

  }

}