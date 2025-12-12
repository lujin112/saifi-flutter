import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../service/theme.dart';
import '../home/add_child.dart';

class KidsInfoScreen extends StatefulWidget {
  const KidsInfoScreen({super.key});

  @override
  State<KidsInfoScreen> createState() => _KidsInfoScreenState();
}

class _KidsInfoScreenState extends State<KidsInfoScreen> {

  // =======================
  // ✅ Get Parent ID
  // =======================
  Future<String?> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("parent_id");
  }

  // =======================
  // ✅ Calculate Age From Birthdate
  // =======================
  int calculateAgeFromBirthdate(String birthdate) {
    final birth = DateTime.parse(birthdate);
    final today = DateTime.now();

    int age = today.year - birth.year;

    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }

    return age;
  }

  // =======================
  // ✅ EDIT Dialog
  // =======================
  void _openEditDialog(BuildContext context, Map<String, dynamic> child) {
    final firstName = TextEditingController(text: child['first_name']);
    final lastName = TextEditingController(text: child['last_name']);
    final notes = TextEditingController(text: child['notes'] ?? '');

    DateTime birthDate = DateTime.parse(child['birthdate']);
    String gender = child['gender'];

    final List<String> selectedInterests =
        List<String>.from(child['interests'] ?? []);

    const Map<String, IconData> interestTypes = {
      'Sports': Icons.sports_soccer,
      'Technology': Icons.memory,
      'Swimming': Icons.pool,
      'Art': Icons.brush,
      'Language': Icons.language,
      'Self-Defense': Icons.sports_mma,
    };

    bool showName = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          Widget box({
            required String title,
            required Widget child,
            VoidCallback? onTap,
          }) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.grey),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: onTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        if (onTap != null)
                          const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  if (onTap == null) child,
                  if (onTap != null && showName)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: child,
                    ),
                ],
              ),
            );
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 550),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Edit Child Info",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      box(
                        title: "Name",
                        onTap: () =>
                            setLocalState(() => showName = !showName),
                        child: Column(
                          children: [
                            TextField(
                              controller: firstName,
                              decoration: const InputDecoration(
                                  labelText: "First Name"),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: lastName,
                              decoration:
                                  const InputDecoration(labelText: "Last Name"),
                            ),
                          ],
                        ),
                      ),

                      box(
                        title: "Gender",
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: gender == "male",
                              title: const Text("Male"),
                              onChanged: (_) =>
                                  setLocalState(() => gender = "male"),
                            ),
                            CheckboxListTile(
                              value: gender == "female",
                              title: const Text("Female"),
                              onChanged: (_) =>
                                  setLocalState(() => gender = "female"),
                            ),
                          ],
                        ),
                      ),

                      box(
                        title: "Birthdate",
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: birthDate,
                            firstDate: DateTime(2008),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setLocalState(() => birthDate = picked);
                          }
                        },
                        child: Text(
                          "${birthDate.day}/${birthDate.month}/${birthDate.year}",
                        ),
                      ),

                      box(
                        title: "Interests",
                        child: Wrap(
                          spacing: 8,
                          children: interestTypes.entries.map((e) {
                            final selected =
                                selectedInterests.contains(e.key);

                            return FilterChip(
                              label: Text(e.key),
                              selected: selected,
                              onSelected: (v) {
                                setLocalState(() {
                                  if (v) {
                                    selectedInterests.add(e.key);
                                  } else {
                                    selectedInterests.remove(e.key);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      box(
                        title: "Notes",
                        child: TextField(
                          controller: notes,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(hintText: "Enter notes"),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                          onPressed: () async {
                            await ApiService.updateChild(
                              childId: child['child_id'],
                              data: {
                                "first_name": firstName.text.trim(),
                                "last_name": lastName.text.trim(),
                                "birthdate": birthDate
                                    .toIso8601String()
                                    .substring(0, 10),
                                "gender": gender,
                                "interests": selectedInterests,
                                "notes": notes.text.trim(),
                              },
                            );

                            Navigator.pop(context);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =======================
  // ✅ DELETE CHILD
  // =======================
  void _confirmDeleteChild(String childId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Child"),
        content: const Text("Are you sure you want to delete this child?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteChild(childId);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Child deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to delete child"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text("My Kids"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final parentId = await _getParentId();

          if (parentId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddChildScreen(),
              ),
            ).then((_) => setState(() {}));
          }
        },
      ),

      body: FutureBuilder<String?>(
        future: _getParentId(),
        builder: (context, parentSnap) {
          if (parentSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!parentSnap.hasData || parentSnap.data == null) {
            return const Center(child: Text("Parent not logged in"));
          }

          final parentId = parentSnap.data!;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: ApiService.getChildrenByParent(parentId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snap.hasData || snap.data!.isEmpty) {
                return const Center(child: Text("No kids added yet."));
              }

              final kids = snap.data!;

              return ListView.builder(
                itemCount: kids.length,
                itemBuilder: (context, index) {
                  final kid = kids[index];
                  final age = calculateAgeFromBirthdate(kid['birthdate']);

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.child_care,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${kid['first_name']} ${kid['last_name']} (${kid['gender']})",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          Text("Age: $age"),
                          Text("Birthday: ${kid['birthdate']}"),
                          Text("Interests: ${(kid['interests'] ?? []).join(', ')}"),
                          Text("Notes: ${kid['notes'] ?? '-'}"),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit"),
                                onPressed: () {
                                  _openEditDialog(context, kid);
                                },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                label: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () {
                                  _confirmDeleteChild(kid["child_id"]);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
