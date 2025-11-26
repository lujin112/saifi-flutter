import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:saifi_app/screens/home/booking/booking_screen.dart';
import 'screens/service/firebase_options.dart'; 
import 'screens/service/theme.dart';
import 'screens/register/splash_screen.dart';


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
