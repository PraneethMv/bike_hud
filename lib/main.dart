import 'package:flutter/material.dart';
import 'screens/hud_home_screen.dart';

void main() {
  runApp(const BikeHudApp());
}

class BikeHudApp extends StatelessWidget {
  const BikeHudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike HUD Alpha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HudHomeScreen(),
    );
  }
}