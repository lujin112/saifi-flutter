import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../service/theme.dart';

class EditParentProfileScreen extends StatefulWidget {
  final String parentId;

  const EditParentProfileScreen({super.key, required this.parentId});

  @override
  State<EditParentProfileScreen> createState() =>
      _EditParentProfileScreenState();
}

class _EditParentProfileScreenState extends State<EditParentProfileScreen> {
  final TextEditingController _first = TextEditingController();
  final TextEditingController _last = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // =========================
  // ✅ Load Parent From API
  // =========================
  Future<void> _loadData() async {
    try {
      final parent = await ApiService.getParentById(widget.parentId);

      _first.text = parent["first_name"] ?? "";
      _last.text = parent["last_name"] ?? "";
      _phone.text = parent["phone"] ?? "";
    } catch (e) {
      print("LOAD PROFILE ERROR: $e");
    }

    setState(() => _loading = false);
  }

  // =========================
  // ✅ Update Parent In API
  // =========================
  Future<void> _save() async {
    setState(() => _loading = true);

    try {
      await ApiService.updateParent(
        parentId: widget.parentId,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        phone: _phone.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {
      print("UPDATE PROFILE ERROR: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _first,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _last,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
