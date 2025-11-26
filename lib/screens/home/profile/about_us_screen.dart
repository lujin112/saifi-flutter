import 'package:flutter/material.dart';
import '../../service/theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text(
            "About Us",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),

        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "About Saifi",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  "Saifi is a platform designed to help parents discover and "
                  "book high-quality summer activities for their children. "
                  "Our mission is to provide safe, educational, and enjoyable "
                  "experiences that help kids grow and learn.",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
