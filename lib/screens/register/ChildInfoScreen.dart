import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../service/api_service.dart';
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

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
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
                onPressed: _isSaving ? null : _saveChildren,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child, int index) {
    final birthdayText = _birthdays[index] == null
        ? ""
        : "${_birthdays[index]!.year}-${_birthdays[index]!.month.toString().padLeft(2, '0')}-${_birthdays[index]!.day.toString().padLeft(2, '0')}";

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
              "${child['firstName']} ${child['lastName']} (${child['gender']})",
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
                  firstDate: DateTime(2005),
                  lastDate: DateTime.now(),
                );

                if (picked != null && mounted) {
                  setState(() => _birthdays[index] = picked);
                }
              },
              controller: TextEditingController(
                text: birthdayText,
              ),
            ),

            const SizedBox(height: 15),

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
                final selected =
                    _selectedInterests[index]!.contains(interest);

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
                    if (!mounted) return;
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

  // ================== SAVE TO DATABASE ==================
  Future<void> _saveChildren() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
     final parentId = prefs.getString("parent_id")?.toString();

      if (parentId == null || parentId.isEmpty || !parentId.contains('-')) {
      throw Exception("Invalid parent_id format: $parentId");
    }


      for (int i = 0; i < widget.children.length; i++) {
        final c = widget.children[i];

        if (_birthdays[i] == null) {
          throw Exception("All children must have a birthday");
        }

        final birthdayStr =
            "${_birthdays[i]!.year}-${_birthdays[i]!.month.toString().padLeft(2, '0')}-${_birthdays[i]!.day.toString().padLeft(2, '0')}";
        print("SENDING parent_id => $parentId | TYPE => ${parentId.runtimeType}");

        await ApiService.createChild(
  parentId: parentId.toString().replaceAll('"', '').trim(),
  firstName: c['firstName'],
  lastName: c['lastName'],
  gender: c['gender'].toString().toLowerCase(),
  birthday: birthdayStr,
  age: _calculateAge(_birthdays[i]!),
  notes: _notes[i] ?? "",
);

      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LocationSelectionScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save children: $e")),
      );
    }
  }
}
