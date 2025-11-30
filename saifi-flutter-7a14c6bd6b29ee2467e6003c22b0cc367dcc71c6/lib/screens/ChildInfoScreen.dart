import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

import 'theme.dart';

class ChildInfoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> children;

  const ChildInfoScreen({super.key, this.children = const []});

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _childId = TextEditingController();

  DateTime? _birthday;
  Set<String> _selectedInterests = {};
  String? _gender;
  bool _isSaving = false;

  static const Map<String, List<String>> _interestsMap = {
    'Sports': ['Football','Basketball','Tennis','Swimming','Volleyball','Gymnastics'],
    'Languages': ['English','French','Chinese','Spanish','Arabic'],
    'Self-defense': ['Karate','Taekwondo','Judo','Boxing','Kung Fu'],
    'Arts': ['Painting','Drawing','Music','Dance','Photography'],
    'Technology': ['Coding','Robotics','Game Design','3D Printing','Electronics'],
  };

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Add Child'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [

                _buildTextField(_firstName, "Child First Name"),
                const SizedBox(height: 12),

                _buildTextField(_lastName, "Child Last Name"),
                const SizedBox(height: 12),

                // _buildTextField(_childId, "Child ID",
                //   keyboard: TextInputType.number,
                //   input: [FilteringTextInputFormatter.digitsOnly],
                // ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                  ],
                  onChanged: (v) => _gender = v,
                ),

                const SizedBox(height: 15),

                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2010),
                      firstDate: DateTime(2007),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _birthday = picked);
                  },
                  controller: TextEditingController(
                    text: _birthday == null
                        ? ""
                        : "${_birthday!.day}/${_birthday!.month}/${_birthday!.year}",
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Interests",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _interestsMap.entries.expand((group) {
                    return group.value.map((interest) {
                      final selected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            v
                                ? _selectedInterests.add(interest)
                                : _selectedInterests.remove(interest);
                          });
                        },
                      );
                    });
                  }).toList(),
                ),

                const SizedBox(height: 30),

                ShinyButton(
                  text: _isSaving ? "Saving..." : "Save Child",
                  onPressed: _isSaving ? null : _saveChild,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController c,
    String label, {
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? input,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      inputFormatters: input,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _saveChild() async {
  if (_firstName.text.isEmpty ||
      _lastName.text.isEmpty ||
      _gender == null ||
      _birthday == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  setState(() => _isSaving = true);

  try {
    // ✅ جلب parent_id من SharedPreferences بدل Firebase
    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString("parent_id");

    if (parentId == null || parentId.isEmpty) {
      throw Exception("Parent not logged in");
    }

    // ✅ تجهيز البيانات حسب جدول children في PostgreSQL
    final childData = {
      "parent_id": parentId,
      "first_name": _firstName.text.trim(),
      "last_name": _lastName.text.trim(),
      "gender": _gender,
      "birthdate":
          "${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}",
      "interests": _selectedInterests.toList(),
    };

    // ✅ إرسال للباك اند
    await ApiService.createChild(childData);

    setState(() => _isSaving = false);
    Navigator.pop(context);
  } catch (e) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save child: $e")),
    );
  }
}

}
