import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const RevHudApp());
}

class RevHudApp extends StatelessWidget {
  const RevHudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rev HUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

// Backward compatibility alias
typedef BikeHudApp = RevHudApp;