import 'package:flutter/material.dart';
import 'screens/theme.dart'; // استدعاء ملف الثيم اللي سويناه
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // ربط الثيم المخصص
      home: const SplashScreen(),
    );
  }
}