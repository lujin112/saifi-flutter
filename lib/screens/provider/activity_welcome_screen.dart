import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../register/role_selection_screen.dart';
import 'activity_registration_screen.dart';
import 'ProviderActivityDetailsPage.dart';
import 'ProviderBookingsPage.dart';
import 'provider_profile_page.dart';

class ActivityWelcomeScreen extends StatefulWidget {
  final Map<String, dynamic> activity;

  const ActivityWelcomeScreen({super.key, required this.activity});

  @override
  State<ActivityWelcomeScreen> createState() => _ActivityWelcomeScreenState();
}

class _ActivityWelcomeScreenState extends State<ActivityWelcomeScreen> {
  String providerName = "Provider";

  @override
  void initState() {
    super.initState();
    _loadProviderName();
  }

  Future<void> _loadProviderName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      providerName = prefs.getString("provider_name") ?? "Provider";
    });
  }

  // ✅ تسجيل خروج
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String activityId =
        widget.activity['activity_id']?.toString() ?? "";

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // ✅ APP BAR WITH PROFILE + LOGOUT
appBar: AppBar(
  backgroundColor: AppColors.primary, // ✅ أخضر مثل الثيم
  elevation: 0,
  automaticallyImplyLeading: false,

  // ⬅️ LOGOUT - LEFT
  leading: Padding(
    padding: const EdgeInsets.only(left: 12),
    child: GestureDetector(
      onTap: () => _logout(context),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white.withOpacity(0.2),
        child: const Icon(
          Icons.logout,
          color: Colors.white,
          size: 20,
        ),
      ),
    ),
  ),

  // ➡️ PROFILE - RIGHT
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProviderProfilePage(),
            ),
          );
        },
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    ),
  ],
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
                  children: [
                    const Text(
                      "Welcome,",
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
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
                            builder: (_) => ProviderBookingsPage(
                              activityId: activityId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============= CARD WIDGET ==============
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
