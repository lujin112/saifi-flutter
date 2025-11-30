import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/theme.dart';

class ProviderBookingsPage extends StatelessWidget {
  final String activityId;

  const ProviderBookingsPage({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            "Activity Bookings",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("bookings")
              .where("activity_id", isEqualTo: activityId)
              .orderBy("created_at", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final bookings = snapshot.data!.docs;

            if (bookings.isEmpty) {
              return const Center(
                child: Text(
                  "No bookings yet.",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'RobotoMono',
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final doc = bookings[index];
                final data = doc.data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['first_name'] ?? "Unknown Child",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Parent ID: ${data['parentId']}",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Gender: ${data["childGender"]}",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Status: ${data['booking_status'] ?? "pending"}",
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          color: (data['booking_status'] == "confirmed")
                              ? Colors.green
                              : (data['booking_status'] == "rejected")
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          // ACCEPT
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                doc.reference.update({
                                  "booking_status": "confirmed",
                                });
                              },
                              child: const Text(
                                "Approve",
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // REJECT
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                doc.reference.update({
                                  "booking_status": "rejected",
                                });
                              },
                              child: const Text(
                                "Reject",
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
