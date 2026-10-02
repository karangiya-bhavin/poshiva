import 'package:flutter/material.dart';
import 'package:poshiva/screens/auth/account_created.dart';
// import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const PoshivaApp());
}

class PoshivaApp extends StatelessWidget {
  const PoshivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poshiva',
      home: const AccountCreatedScreen(), // Start with the AccountCreatedScreen
    );
  }
}
