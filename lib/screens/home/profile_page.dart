import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../profile/KidsInfoScreen.dart';
import '../service/theme.dart';
import '../booking/booking_screen.dart';
import '../profile/edit_parent_profile_screen.dart';
import '../profile/password_security_screen.dart';
import '../profile/language_screen.dart';
import 'notifications_screen.dart';
import '../profile/about_us_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  Map<String, dynamic>? _parentData;
  String? parentId;

  @override
  void initState() {
    super.initState();
    _loadParent();
  }

  Future<void> _loadParent() async {
    final prefs = await SharedPreferences.getInstance();
    parentId = prefs.getString("parent_id");

    if (parentId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final data = await ApiService.getParentById(parentId!);
      setState(() {
        _parentData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_parentData == null) {
      return const Center(child: Text("Parent not found"));
    }

    final name =
        "${_parentData!["first_name"] ?? ""} ${_parentData!["last_name"] ?? ""}"
            .trim();

    final email = _parentData!["email"] ?? "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Profile",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // ================= PARENT HEADER =================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black12.withOpacity(0.08), blurRadius: 8)
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 42, color: Colors.white),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(email,
                          style: const TextStyle(color: Colors.grey)),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditParentProfileScreen(parentId: parentId!),
                            ),
                          ).then((_) => _loadParent());
                        },
                        child: const Text("Edit Profile"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ================= KIDS =================
          _navCard(
            icon: Icons.child_care,
            title: "Kids Information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KidsInfoScreen()),
              );
            },
          ),

          // ================= BOOKINGS =================
          _navCard(
            icon: Icons.calendar_month,
            title: "Booking Information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingScreen()),
              );
            },
          ),

          const SizedBox(height: 30),

          const Text("Settings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          _navCard(
            icon: Icons.person,
            title: "Manage Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditParentProfileScreen(parentId: parentId!),
                ),
              );
            },
          ),

          _navCard(
            icon: Icons.lock,
            title: "Password & Security",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PasswordSecurityScreen(),
                ),
              );
            },
          ),

          _navCard(
            icon: Icons.language,
            title: "Language",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()),
              );
            },
          ),

          _navCard(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),

          _navCard(
            icon: Icons.info,
            title: "About Us",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= REUSABLE CARD =================
  Widget _navCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: 14),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 17, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
