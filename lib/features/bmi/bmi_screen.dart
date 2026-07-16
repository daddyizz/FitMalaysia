import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  double? bmi;
  String result = "";
  String advice = "";
  Color resultColor = Colors.green;

  @override
  void initState() {
    super.initState();
    loadBMI();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> saveBMI() async {
    final prefs = await SharedPreferences.getInstance();

    if (bmi != null) {
      await prefs.setDouble('last_bmi', bmi!);
      await prefs.setString('last_bmi_result', result);
    }
  }

  Future<void> loadBMI() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBMI = prefs.getDouble('last_bmi');
    final savedResult = prefs.getString('last_bmi_result') ?? "";

    if (!mounted) return;

    setState(() {
      bmi = savedBMI;
      result = savedResult;

      switch (result) {
        case "Kurus":
          resultColor = Colors.orange;
          advice =
          "Cuba tambah pengambilan kalori sihat dan lakukan latihan kekuatan.";
          break;

        case "Normal":
          resultColor = Colors.green;
          advice =
          "Tahniah! Teruskan gaya hidup sihat dan kekal aktif.";
          break;

        case "Berlebihan":
          resultColor = Colors.orange;
          advice =
          "Kurangkan minuman bergula dan tambah aktiviti fizikal.";
          break;

        case "Obes":
          resultColor = Colors.red;
          advice =
          "Dapatkan nasihat profesional kesihatan dan mulakan perubahan secara berperingkat.";
          break;

        default:
          resultColor = Colors.green;
          advice = "";
      }
    });
  }

  void calculateBMI() {
    final height = double.tryParse(heightController.text);
    final weight = double.tryParse(weightController.text);

    if (height == null ||
        weight == null ||
        height <= 0 ||
        weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sila masukkan tinggi dan berat yang sah."),
        ),
      );
      return;
    }

    final heightMeter = height / 100;

    setState(() {
      bmi = weight / (heightMeter * heightMeter);

      if (bmi! < 18.5) {
        result = "Kurus";
        resultColor = Colors.orange;
        advice =
        "Cuba tambah pengambilan kalori sihat dan lakukan latihan kekuatan.";
      } else if (bmi! < 25) {
        result = "Normal";
        resultColor = Colors.green;
        advice =
        "Tahniah! Teruskan gaya hidup sihat dan kekal aktif.";
      } else if (bmi! < 30) {
        result = "Berlebihan";
        resultColor = Colors.orange;
        advice =
        "Kurangkan minuman bergula dan tambah aktiviti fizikal.";
      } else {
        result = "Obes";
        resultColor = Colors.red;
        advice =
        "Dapatkan nasihat profesional kesihatan dan mulakan perubahan secara berperingkat.";
      }
    });

    saveBMI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalkulator BMI"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Tinggi (cm)",
                prefixIcon: Icon(Icons.height),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Berat (kg)",
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculateBMI,
                child: const Text("Kira BMI"),
              ),
            ),

            const SizedBox(height: 30),

            if (bmi != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "BMI: ${bmi!.toStringAsFixed(1)}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        result,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        advice,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}