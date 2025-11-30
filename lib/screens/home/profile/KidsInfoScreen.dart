import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../register/ChildInfoScreen.dart';
import '../../service/theme.dart';

class KidsInfoScreen extends StatelessWidget {
  KidsInfoScreen({super.key});

  final String parentId = FirebaseAuth.instance.currentUser!.uid;

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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("parents")
            .doc(parentId)
            .collection("children")
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final kids = snap.data!.docs;

          if (kids.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: kids.length,
            itemBuilder: (context, index) {
              
              final kid = kids[index].data() as Map<String, dynamic>;

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
                      // ---------------- NAME + GENDER ----------------
                      Text(
                        "${kid['first_name']} ${kid['last_name']} (${kid['gender']})",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ---------------- BIRTHDAY ----------------
                      Text(
                        "Birthday: ${kid['birthday'] != null ? (kid['birthday'] as Timestamp).toDate().toString().substring(0, 10) : '-'}",
                        style: const TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 6),

                      // ---------------- INTERESTS ----------------
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
      ),
    );
  }
}
