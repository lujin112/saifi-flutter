import 'package:flutter/material.dart';
import 'parent_registration_screen.dart';
import 'ClubProviderRegistrationScreen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2), // تغيير لون الخلفية
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // إضافة الشعار (Logo) - تم تكبير الصورة
              Image.asset(
                'assets/home.png',
                height: 150, // تكبير الصورة من 100 إلى 150
                width: 150,  // تكبير الصورة من 100 إلى 150
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              // النص في الأعلى - تم تكبيره
              const Column(
                children: [
                  Text(
                    'WELCOME,',
                    style: TextStyle(
                      fontSize: 32, // تكبير من 24 إلى 32
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3558),
                    ),
                  ),
                  Text(
                    'JOIN US!',
                    style: TextStyle(
                      fontSize: 32, // تكبير من 24 إلى 32
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3558),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // أزرار الاختيار
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ParentRegistrationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C4C0),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'AS PARENTS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClubProviderRegistrationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C4C0),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'AS CLUB PROVIDERS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}