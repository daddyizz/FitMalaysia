import 'dart:async';
import '../../services/firestore_service.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> initializeApp() async {
    debugPrint("STEP 1");

    final user = await AuthService.signInAnonymously();

    debugPrint("STEP 2");

    if (user != null) {
      debugPrint("STEP 3 UID: ${user.uid}");

      await FirestoreService.createUserIfNotExists();

      debugPrint("STEP 4 Firestore OK");
    } else {
      debugPrint("Anonymous login failed.");
    }

    debugPrint("STEP 5 Navigate");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
          () async {
        await initializeApp();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 90,
            ),

            SizedBox(height: 24),

            Text(
              "FitMalaysia",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Healthy Life Starts Today",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 50),

            CircularProgressIndicator(
              color: Colors.white,
            ),

          ],
        ),
      ),
    );
  }
}