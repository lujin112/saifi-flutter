import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatelessWidget {
  final String parentId = FirebaseAuth.instance.currentUser!.uid;


  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- USER INFO ----------------
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("parents")
                  .doc(parentId)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snap.data!.data() as Map<String, dynamic>? ?? {};
                final name = data["name"] ?? "Parent Name";
                final email = data["email"] ?? "email@example.com";

                return Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFF80C4C0),
                        child: Icon(Icons.person, size: 55, color: Colors.white),
                      ),
                      const SizedBox(height: 10),

                      Text(name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),

                      Text(email,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {},
                        child: const Text("Edit Profile"),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // ---------------- KIDS SECTION ----------------
            const Text(
              "My Kids",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("parents")
                  .doc(parentId)
                  .collection("children")
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final kids = snap.data!.docs;

                if (kids.isEmpty) {
                  return const Text("No kids added yet.");
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: kids.map((doc) {
                    final kid = doc.data() as Map<String, dynamic>;
                    final name = kid["name"] ?? "Kid";
                    final age = kid["age"] ?? "-";
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.child_care, size: 40),
                        title: Text(name),
                        subtitle: Text("Age: $age"),
                        trailing: const Icon(Icons.edit),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                // صفحة إضافة طفل لاحقاً
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Kid"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C4C0),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 35),

            // ---------------- BOOKINGS SECTION ----------------
            const Text(
              "My Bookings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("bookings")
                  .where("parentId", isEqualTo: parentId)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final bookings = snap.data!.docs;

                if (bookings.isEmpty) {
                  return const Text("No bookings yet.");
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: bookings.map((doc) {
                    final b = doc.data() as Map<String, dynamic>;
                    final activity = b["activityName"] ?? "Activity";
                    final date = b["activityDate"] is Timestamp
                        ? (b["activityDate"] as Timestamp)
                            .toDate()
                            .toString()
                            .substring(0, 10)
                        : "-";
                    final status = b["status"] ?? "unknown";

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text(activity),
                        subtitle: Text("Date: $date"),
                        trailing: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 35),

            // ---------------- ACCOUNT SETTINGS ----------------
            const Text(
              "Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Change Language"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log out"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}