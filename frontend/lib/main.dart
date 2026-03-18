import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/location_provider.dart';
import 'screens/login_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/parent/parent_dashboard.dart';
import 'screens/warden/warden_dashboard.dart';
import 'screens/security/security_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Smart Leave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.user != null) {
            switch (auth.user!.role) {
              case 'STUDENT': return const StudentDashboard();
              case 'PARENT': return const ParentDashboard();
              case 'WARDEN': return const WardenDashboard();
              case 'SECURITY': return const SecurityDashboard();
              default: return const LoginScreen();
            }
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
