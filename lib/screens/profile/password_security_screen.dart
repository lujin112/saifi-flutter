import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  Future<void> _changePassword() async {
    if (_password.text.trim().length < 8) {
      _showMessage("Error", "Password must be at least 8 characters");
      return;
    }

    setState(() => _loading = true);

    try {
      // ✅ جلب parent_id من التخزين المحلي
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("parent_id");

      if (parentId == null || parentId.isEmpty) {
        _showMessage("Error", "User not logged in");
        setState(() => _loading = false);
        return;
      }

      // ✅ استدعاء API لتحديث كلمة المرور
      await ApiService.updateParentPassword(
        parentId: parentId,
        newPassword: _password.text.trim(),
      );

      setState(() => _loading = false);

      Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      _showMessage("Password Update Failed", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Password & Security")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loading ? null : _changePassword,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update Password"),
            )
          ],
        ),
      ),
    );
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }
}
