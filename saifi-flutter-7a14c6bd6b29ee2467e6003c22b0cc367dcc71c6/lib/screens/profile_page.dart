import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saifi_app/screens/KidsInfoScreen.dart';
import 'theme.dart';
import 'booking_screen.dart';
import 'edit_parent_profile_screen.dart';
import 'password_security_screen.dart';
import 'language_screen.dart';
import 'notifications_screen.dart';
import 'about_us_screen.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final String parentId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // ----------------- Page Title ------------------
          const Center(
            child: Text(
              "Profile",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ------------------ Parent Header ------------------
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("parents")
                .doc(parentId)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ));
              }

              final data = snap.data!.data() as Map<String, dynamic>? ?? {};

              final name = "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}".trim();

              final email = data["email"] ?? "example@email.com";
return Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
          color: Colors.black12.withOpacity(0.08),
          blurRadius: 8)
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const CircleAvatar(
        radius: 38,
        backgroundColor: Colors.teal,
        child: Icon(Icons.person,
            size: 42, color: Colors.white),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 10),

            // ======== EDIT PROFILE BUTTON =========
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditParentProfileScreen(parentId: parentId),
                  ),
                );
              },
              child: const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

            },
          ),

          const SizedBox(height: 30),

// ---------------- KIDS SECTION ----------------
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KidsInfoScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.child_care, color: AppColors.primary, size: 28),
                  SizedBox(width: 14),
                  Text(
                    "Kids Information",
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 17, color: Colors.grey),
                ],
              ),
            ),
          ),

          // =====================================================
// =============== Booking Information =================
// =====================================================

          GestureDetector(
            onTap: () async {
  final bookings = await FirebaseFirestore.instance
      .collection("bookings")
      .where("parentId", isEqualTo: parentId)
      .get();

  if (bookings.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No bookings found")),
    );
    return;
  }

  // نأخذ أول بوكنق – أو تغيّرينه لاحقاً لقائمة كاملة
  final data = bookings.docs.first.data() as Map<String, dynamic>;

  Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const BookingScreen()),
);

},

            child: Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_month,
                      color: AppColors.primary, size: 28),
                  SizedBox(width: 14),
                  Text(
                    "Booking Information",
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 17, color: Colors.grey),
                ],
              ),
            ),
          ),

          // =====================================================
          // ====================== Settings =====================
          // =====================================================

          const Text("Settings",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12.withOpacity(0.08), blurRadius: 8)
              ],
            ),
            child: Column(
              children: [
                _settingItem(
  Icons.person,
  "Manage Profile",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditParentProfileScreen(parentId: parentId),
      ),
    );
  },
),
_settingItem(
  Icons.lock,
  "Password & Security",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PasswordSecurityScreen(),
      ),
    );
  },
),

                _settingItem(
  Icons.language,
  "Language",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  },
),

_settingItem(
  Icons.notifications,
  "Notifications",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  },
),

_settingItem(
  Icons.info,
  "About Us",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
    );
  },
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- REUSABLE SETTING ITEM ----------------
  Widget _settingItem(IconData icon, String title, {VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.teal),
    title: Text(title,
        style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  );
}

}
