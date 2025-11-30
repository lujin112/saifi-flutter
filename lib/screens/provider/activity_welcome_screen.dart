import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/theme.dart';
import '../register/role_selection_screen.dart';
import 'activity_registration_screen.dart';
import 'ProviderActivityDetailsPage.dart';
import 'ProviderBookingsPage.dart';

class ActivityWelcomeScreen extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityWelcomeScreen({super.key, required this.activity});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String activityId = activity['activity_id'];

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),

        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ================= WELCOME BOX ==================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Welcome, Provider!",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage your activities easily.",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ============== THREE BIG CARDS ==============
              Expanded(
                child: ListView(
                  children: [
                    _buildCard(
                      icon: Icons.list_alt,
                      label: "View My Activities",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProviderActivityDetailsPage(
                              activityId: activityId,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildCard(
                      icon: Icons.add_circle_outline,
                      label: "Add New Activity",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ActivityRegistrationScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildCard(
                      icon: Icons.event_available,
                      label: "Bookings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProviderBookingsPage(activityId: activityId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= LOGOUT ==================
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red, size: 32),
                    onPressed: () => _logout(context),
                  ),
                  const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ============= CARD WIDGET (بدون مشاكل hover) ==============
  Widget _buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
