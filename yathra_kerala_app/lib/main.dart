import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const YathraKeralaApp());
}

class YathraKeralaApp extends StatelessWidget {
  const YathraKeralaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YathraKerala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B), // Kerala emerald teal
          primary: const Color(0xFF00695C),
          secondary: const Color(0xFFFFA000),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
