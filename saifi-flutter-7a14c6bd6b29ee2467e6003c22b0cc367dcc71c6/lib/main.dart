import 'package:flutter/material.dart';
import 'package:saifi_app/screens/booking_screen.dart';
import 'screens/theme.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  testApi(); // ✅ اختبار الاتصال عند التشغيل
  runApp(const MyApp());
}

void testApi() async {
  try {
    final result = await ApiService.loginParent(
      email: "test@test.com",
      password: "123456",
    );

    print("LOGIN RESULT:");
    print(result);
  } catch (e) {
    print("ERROR:");
    print(e);
  }
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
      routes: {'/bookings': (context) => const BookingScreen()},
    );
  }
}
