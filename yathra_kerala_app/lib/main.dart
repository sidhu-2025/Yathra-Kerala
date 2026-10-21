import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

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
          seedColor: const Color(0xFF1565C0), // Primary Blue
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF0D47A1),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthScreen(
        isRoot: true,
        initialRole: 'user',
      ),
    );
  }
}
