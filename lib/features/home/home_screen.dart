import 'package:flutter/material.dart';

import 'widgets/feature_card.dart';
import 'widgets/health_tip_card.dart';
import '../workout/workout_screen.dart';
import 'widgets/water_tracker_card.dart';
import '../nutrition/nutrition_screen.dart';
import '../bmi/bmi_screen.dart';
import 'widgets/dashboard_summary_card.dart';
import '../article/article_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late BannerAd _bannerAd;
  bool _isBannerReady = false;

  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Google Test Banner
      : 'ca-app-pub-4110950503958596/2401217451'; // Banner ID sebenar


  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId, // Google Banner Unit
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mari kekal sihat hari ini!',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

            SizedBox(height: 24),

            DashboardSummaryCard(),

            SizedBox(height: 24),

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
                        builder: (_) => const ArticleScreen(),
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

            HealthTipCard(
              tip:
              'Berjalan sekurang-kurangnya 30 minit setiap hari dapat membantu meningkatkan kesihatan jantung.',
            ),
            const SizedBox(height: 24),

            if (_isBannerReady)
              Center(
                child: SizedBox(
                  width: _bannerAd.size.width.toDouble(),
                  height: _bannerAd.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
