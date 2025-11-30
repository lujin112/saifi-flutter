import 'package:flutter/material.dart';
import 'theme.dart';
import 'role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityWelcomeScreen extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityWelcomeScreen({super.key, required this.activity});

  Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // حذف بيانات الجلسة
  await prefs.remove("provider_id");
  await prefs.remove("parent_id");

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    (route) => false,
  );
}


  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
        ),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 85,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Activity Created Successfully!",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // ====== Box showing activity info ======
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        activity['title'] ?? "",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        activity['type'] ?? "",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ====== Edit button (no screen yet) ======
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(250, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Edit screen not implemented yet."),
                      ),
                    );
                  },
                  child: const Text("Edit Activity"),
                ),

                const SizedBox(height: 15),

                // ====== Bookings button (no screen yet) ======
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    minimumSize: const Size(250, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Bookings screen not implemented yet."),
                      ),
                    );
                  },
                  child: const Text("View Bookings"),
                ),

                const SizedBox(height: 40),

                // ====== Logout button ======
                TextButton(
                  onPressed: () => _logout(context),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 14,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
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
