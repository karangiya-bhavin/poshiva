import 'package:flutter/material.dart';
import '../onboarding/onboarding_1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for the splash screen, then open Onboarding 1.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding1Screen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF093D32), Color(0xFF052C24), Color(0xFF021D18)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 70),

              // POSHIVA Logo
              Image.asset(
                'assets/images/poshiva_logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),

              // App Name
              const Text(
                'Poshiva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Share More. Waste Less.\nHelp Everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 30),

              // Splash Illustration
              Image.asset(
                'assets/images/splash_illustration.png',
                width: 360,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              // Loading indicator
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF63D84B)),
                ),
              ),

              const SizedBox(height: 12),

              // Loading text
              const Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
