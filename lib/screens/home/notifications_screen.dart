import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              activeColor: Colors.teal,
              title: const Text("Booking Updates"),
              value: bookingUpdates,
              onChanged: (value) {
                setState(() => bookingUpdates = value);
              },
            ),

            SwitchListTile(
              activeColor: Colors.teal,
              title: const Text("Child Activity Alerts"),
              value: childActivity,
              onChanged: (value) {
                setState(() => childActivity = value);
              },
            ),

            SwitchListTile(
              activeColor: Colors.teal,
              title: const Text("System Alerts"),
              value: systemAlerts,
              onChanged: (value) {
                setState(() => systemAlerts = value);
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _saveSettings,
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
