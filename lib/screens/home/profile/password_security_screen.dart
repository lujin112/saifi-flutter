import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  Future<void> _changePassword() async {
    setState(() => _loading = true);

    await FirebaseAuth.instance.currentUser!
        .updatePassword(_password.text.trim());

    setState(() => _loading = false);

    Navigator.pop(context);
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
              child: const Text("Update Password"),
            )
          ],
        ),
      ),
    );
  }
}
