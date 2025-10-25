import 'package:flutter/material.dart';
import 'theme.dart'; // استدعاء ملف الثيم
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background, // استدعاء من الثيم
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: size.width * 0.4, // نسبي للشاشة
        ),
      ),
    );
  }
}
