import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../register/ChildInfoScreen.dart';
import '../service/theme.dart';

class KidsInfoScreen extends StatelessWidget {
  const KidsInfoScreen({super.key});

  Future<String?> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("parent_id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text("My Kids"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChildInfoScreen(children: []),
            ),
          );
        },
      ),

      body: FutureBuilder<String?>(
        future: _getParentId(),
        builder: (context, parentSnap) {
          if (parentSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parentId = parentSnap.data;

          if (parentId == null || parentId.isEmpty) {
            return const Center(child: Text("Parent not logged in"));
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: ApiService.getChildrenByParent(parentId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snap.hasData || snap.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No kids added yet.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                );
              }

              final kids = snap.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: kids.length,
                itemBuilder: (context, index) {
                  final kid = kids[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // -------- NAME + GENDER --------
                          Text(
                            "${kid['first_name']} ${kid['last_name']} (${kid['gender']})",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // -------- BIRTHDATE --------
                          Text(
                            "Birthday: ${kid['birthdate']?.toString().substring(0, 10) ?? "-"}",
                            style: const TextStyle(fontSize: 15),
                          ),

                          const SizedBox(height: 6),

                          // -------- INTERESTS --------
                          Text(
                            "Interests: ${(kid['interests'] as List).join(', ')}",
                            style: const TextStyle(fontSize: 15),
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
