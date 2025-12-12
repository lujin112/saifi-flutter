import 'package:flutter/material.dart';
import '../service/theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // ✅ خلفية حسب الثيم
      appBar: AppBar(
        title: const Text("About & Terms"),
        backgroundColor: AppColors.primary, // ✅ لون الثيم
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ========= ABOUT SAIFI CARD =========
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "About Saifi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary, // ✅ عنوان بلون الثيم
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Saifi is a smart platform that helps parents discover, compare, and book high-quality summer activities for their children. "
                      "Our mission is to create safe, educational, and enjoyable experiences that support children’s growth and development.",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                    SizedBox(height: 14),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // ========= TERMS CARD =========
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: const Text(
                  "Terms & Conditions\n\n"
                  "1. Purpose of Saifi\n"
                  "Saifi helps parents discover, compare, and book summer activities for their children. Saifi is a mediator and does not directly operate the activities.\n\n"

                  "2. Parent Responsibility\n"
                  "• You must provide accurate personal and child information.\n"
                  "• You must review all activity details before booking.\n"
                  "• You are responsible for your child’s behavior and safety.\n\n"

                  "3. Activity Provider Responsibility\n"
                  "• Providers are fully responsible for activity quality and safety.\n"
                  "• All complaints and refunds must be directed to the provider.\n\n"

                  "4. Payments & Cancellations\n"
                  "• Each activity may have different payment and cancellation policies.\n"
                  "• You agree to review these before confirming any booking.\n\n"

                  "5. Limitation of Liability\n"
                  "• Saifi is not responsible for any damages, injuries, delays, or disputes.\n"
                  "• Your use of the platform is at your own risk.\n\n"

                  "6. Data & Privacy\n"
                  "• Saifi stores user data to improve service quality.\n"
                  "• Location data may be used for nearby activity suggestions.\n\n"

                  "7. Communication\n"
                  "• We may contact you via email, SMS, or in-app notifications.\n\n"

                  "8. Changes to Terms\n"
                  "• Continued use of the platform means acceptance of updated terms.",
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
