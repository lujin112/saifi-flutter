import 'package:flutter/material.dart';
import 'screens/service/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/home/browse_activities_screen.dart';
import 'screens/profile/about_us_screen.dart';
import 'screens/profile/kidsinfoscreen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saifi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
  '/browseActivities': (context) => const BrowseActivitiesScreen(),
   '/kidsInfo': (context) => const KidsInfoScreen(),
  '/bookings': (context) => const BookingScreen(),
  "/about": (context) => const AboutUsScreen(),
},

    );
  }
}
