import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool bookingUpdates = true;
  bool childActivity = true;
  bool systemAlerts = false;
  bool loading = true;

  // =========================
  // ✅ LOAD SETTINGS
  // =========================
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      bookingUpdates = prefs.getBool("notif_booking_updates") ?? true;
      childActivity = prefs.getBool("notif_child_activity") ?? true;
      systemAlerts = prefs.getBool("notif_system_alerts") ?? false;
      loading = false;
    });
  }

  // =========================
  // ✅ SAVE SETTINGS
  // =========================
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("notif_booking_updates", bookingUpdates);
    await prefs.setBool("notif_child_activity", childActivity);
    await prefs.setBool("notif_system_alerts", systemAlerts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification settings saved")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background, // ✅ خلفية الثيم
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: AppColors.primary, // ✅ لون الثيم
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ========= SWITCH CARD =========
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
                activeColor: AppColors.primary, // ✅ لون الثيم
                title: const Text("Booking Updates"),
                value: bookingUpdates,
                onChanged: (value) {
                  setState(() => bookingUpdates = value);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
                activeColor: AppColors.primary,
                title: const Text("Child Activity Alerts"),
                value: childActivity,
                onChanged: (value) {
                  setState(() => childActivity = value);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile(
                activeColor: AppColors.primary,
                title: const Text("System Alerts"),
                value: systemAlerts,
                onChanged: (value) {
                  setState(() => systemAlerts = value);
                },
              ),
            ),

            const SizedBox(height: 20),

            // ========= SAVE BUTTON =========
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // ✅ ثيم
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveSettings,
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
