import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'location_selection_screen.dart';

class ChildInfoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> children;

  const ChildInfoScreen({super.key, required this.children});

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final Map<int, Set<String>> _selectedInterests = {};
  final Map<int, String> _birthdays = {};
  final Map<int, String> _ids = {};
  final Map<int, String> _notes = {};
  final Map<int, Set<String>> _selectedCategories = {};

  final Map<String, List<String>> _interestsMap = {
    'Sports': ['Football', 'Basketball', 'Tennis', 'Swimming', 'Volleyball', 'Gymnastics'],
    'Languages': ['English', 'French', 'Chinese', 'Spanish', 'Arabic'],
    'Self-defense': ['Karate', 'Taekwondo', 'Judo', 'Boxing', 'Kung Fu'],
    'Arts': ['Painting', 'Drawing', 'Music', 'Dance', 'Photography'],
    'Literature & Communication': ['Public Speaking', 'Writing', 'Storytelling', 'Debate Club', 'Theater'],
    'Technology': ['Coding', 'Robotics', 'Game Design', '3D Printing', 'Electronics'],
    'Clubs & Activities': ['Science Club', 'Drama Club', 'Debate Club', 'Leadership'],
  };

  int _calculateAge(DateTime birthDate) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Child Information', style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Children Information & Interests',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: widget.children.length,
                itemBuilder: (context, index) {
                  final child = widget.children[index];
                  _selectedInterests.putIfAbsent(index, () => {});
                  _birthdays.putIfAbsent(index, () => "");
                  _ids.putIfAbsent(index, () => "");
                  _notes.putIfAbsent(index, () => "");
                  _selectedCategories.putIfAbsent(index, () => {});

                  int? age;
                  if (_birthdays[index] != "") {
                    final parts = _birthdays[index]!.split("/");
                    if (parts.length == 3) {
                      final birthDate = DateTime(
                        int.parse(parts[2]),
                        int.parse(parts[1]),
                        int.parse(parts[0]),
                      );
                      age = _calculateAge(birthDate);
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // الاسم + الجنس
                          Row(
                            children: [
                              const Icon(Icons.child_care, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${child['firstName']} ${child['lastName']}  (${child['gender']})',
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // العمر المحسوب
                          if (age != null)
                            Text(
                              'Age: $age years',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          const SizedBox(height: 15),

                          // Birthday Picker
                          TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Birthday',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2010),
                                firstDate: DateTime(2007),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _birthdays[index] =
                                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                });
                              }
                            },
                            controller: TextEditingController(text: _birthdays[index]),
                          ),
                          const SizedBox(height: 15),

                          // Child ID
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Child ID',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) => _ids[index] = value,
                          ),
                          const SizedBox(height: 20),

                          // اختيار الكاتيجوري
                          const Text("Select Interest Categories:", style: AppTextStyles.body),
                          const SizedBox(height: 10),

                          Column(
                            children: _interestsMap.keys.map((category) {
                              final isCategorySelected =
                                  _selectedCategories[index]!.contains(category);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CheckboxListTile(
                                    title: Text(category),
                                    value: isCategorySelected,
                                    onChanged: (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedCategories[index]!.add(category);
                                        } else {
                                          _selectedCategories[index]!.remove(category);
                                          _selectedInterests[index]!.removeWhere(
                                            (interest) =>
                                                _interestsMap[category]!.contains(interest),
                                          );
                                        }
                                      });
                                    },
                                  ),

                                  // إذا اختار الكاتيجوري، نعرض اهتماماته
                                  if (isCategorySelected) ...[
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _interestsMap[category]!.map((interest) {
                                        final isSelected =
                                            _selectedInterests[index]!.contains(interest);
                                        return FilterChip(
                                          label: Text(interest),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if (selected) {
                                                _selectedInterests[index]!.add(interest);
                                              } else {
                                                _selectedInterests[index]!.remove(interest);
                                              }
                                            });
                                          },
                                          selectedColor: AppColors.primary,
                                          checkmarkColor: Colors.white,
                                          backgroundColor: Colors.grey[200],
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                ],
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // ملاحظات من الأب
                          TextFormField(
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Parent Notes (about child personality/interests)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _notes[index] = value,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _saveAndNavigateToLocation(context),
                child: const Text('Save & Continue to Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndNavigateToLocation(BuildContext context) {
    // هنا تقدر تحفظ كل البيانات (ID, Gender, Birthday, Interests, Notes)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text(
              'Children information and interests have been saved successfully!'),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationSelectionScreen()),
                );
              },
              child: const Text('Continue to Location'),
            ),
          ],
        );
      },
    );
  }
}
