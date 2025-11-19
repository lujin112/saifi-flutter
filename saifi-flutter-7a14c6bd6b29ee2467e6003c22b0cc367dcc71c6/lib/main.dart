import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saifi_app/screens/booking_screen.dart';
import 'firebase_options.dart'; // هذا الملف بيتولد تلقائياً بعد أمر flutterfire configure
import 'screens/theme.dart';
import 'screens/splash_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parent Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/bookings': (context) => const BookingScreen(),
      },
    );
  }
}
