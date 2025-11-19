import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool bookingUpdates = true;
  bool childActivity = true;
  bool systemAlerts = false;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
