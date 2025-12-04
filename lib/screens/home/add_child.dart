import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../service/api_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _birthDate;
  int _age = 0;
  String _gender = "Male";

  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2008),
      lastDate: DateTime.now(),
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
    );

    if (picked != null && mounted) {
      setState(() {
        _birthDate = picked;
        _age = _calculateAge(picked);
      });
    }
  }

  // ✅ SAVE TO POSTGRESQL VIA API (FIXED ✅)
  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate() || _birthDate == null) return;
    if (_isSaving) return;

    if (mounted) {
      setState(() => _isSaving = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("parent_id");

      if (parentId == null || parentId.isEmpty) {
        throw Exception("Parent not logged in");
      }

      final birthdayStr =
          _birthDate!.toIso8601String().substring(0, 10);

      await ApiService.createChild(
        parentId: parentId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _gender,          // ✅ بدون lowercase
        birthday: birthdayStr,    // ✅ الاسم الصحيح
        age: _age,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Child added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Add Child"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: "First Name",
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 14),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: "Last Name",
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 16),

                  // Gender
                  Row(
                    children: [
                      const Text("Gender: "),
                      Radio(
                        value: "Male",
                        groupValue: _gender,
                        onChanged: (v) =>
                            setState(() => _gender = v!),
                      ),
                      const Text("Male"),
                      Radio(
                        value: "Female",
                        groupValue: _gender,
                        onChanged: (v) =>
                            setState(() => _gender = v!),
                      ),
                      const Text("Female"),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Birthday
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _birthDate == null
                                ? "Select Birth Date"
                                : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (_birthDate != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Age: $_age"),
                    ),

                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Notes (optional)",
                    ),
                  ),

                  const SizedBox(height: 30),

                  ShinyButton(
                    text: _isSaving ? "Saving..." : "Save Child",
                    onPressed: _isSaving ? null : _saveChild,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
