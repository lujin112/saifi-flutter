import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'location_selection_screen.dart';

class ChildInfoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> children;

  const ChildInfoScreen({super.key, required this.children});

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final Map<int, DateTime?> _birthdays = {};
  final Map<int, String> _notes = {};
  final Map<int, Set<String>> _selectedInterests = {};
  bool _isSaving = false;

  static const Map<String, IconData> _interestTypes = {
    'Sports': Icons.sports_soccer,
    'Technology': Icons.memory,
    'Swimming': Icons.pool,
    'Art': Icons.brush,
    'Language': Icons.language,
    'Self-Defense': Icons.sports_mma,
  };

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Child Information'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) {
                    _selectedInterests.putIfAbsent(index, () => {});
                    return _buildChildCard(widget.children[index], index);
                  },
                ),
              ),

              ShinyButton(
                text: _isSaving ? "Saving..." : "Save & Continue",
                onPressed: () {
                  if (_isSaving) return;
                  _saveChildren();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child, int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${child['firstName']} ${child['lastName']} (${child['gender']})"
              "${_birthdays[index] != null ? " - Age: ${calculateAge(_birthdays[index]!)}" : ""}",
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
                if (picked != null) setState(() => _birthdays[index] = picked);
              },
              controller: TextEditingController(
                text: _birthdays[index] == null
                    ? ""
                    : "${_birthdays[index]!.day}/${_birthdays[index]!.month}/${_birthdays[index]!.year}",
              ),
            ),

            const SizedBox(height: 15),

            // Interests
            const Text(
              "Interests:",
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            Wrap(
              spacing: 10,
              children: _interestTypes.entries.map((entry) {
                final interest = entry.key;
                final icon = entry.value;

                final selected = _selectedInterests[index]!.contains(interest);

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 6),
                      Text(interest),
                    ],
                  ),
                  selected: selected,
                  onSelected: (s) {
                    setState(() {
                      s
                          ? _selectedInterests[index]!.add(interest)
                          : _selectedInterests[index]!.remove(interest);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 15),

            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Notes"),
              onChanged: (v) => _notes[index] = v,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChildren() async {
    setState(() => _isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final parent = FirebaseFirestore.instance.collection("parents").doc(uid);
    final batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < widget.children.length; i++) {
      final c = widget.children[i];
      final ref = parent.collection("children").doc();

      // حساب العمر
      final age = _birthdays[i] != null ? calculateAge(_birthdays[i]!) : null;

      batch.set(ref, {
        "first_name": c['firstName'],
        "last_name": c['lastName'],
        "gender": c['gender'],
        "birthday":
            _birthdays[i] != null ? Timestamp.fromDate(_birthdays[i]!) : null,
        "age": age,
        "interests": _selectedInterests[i]!.toList(),
        "notes": _notes[i] ?? "",
        "created_at": FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    setState(() => _isSaving = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSelectionScreen()),
    );
  }
}
