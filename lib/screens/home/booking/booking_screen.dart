import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  // ------------------------
  // كارد الحجز
  // ------------------------
  Widget bookingCard(Map<String, dynamic> data) {
    final date = data["startDate"] is Timestamp
        ? (data["startDate"] as Timestamp).toDate().toString().substring(0, 10)
        : "-";

    final status = data["status"] ?? "upcoming";

    Color statusColor() {
      switch (status) {
        case "ongoing":
          return Colors.green;
        case "past":
          return Colors.redAccent;
        default:
          return Colors.blueAccent;
      }
    }

    IconData getIcon() {
      switch ((data["activityType"] ?? "").toLowerCase()) {
        case "sports":
          return Icons.sports_soccer;
        case "swimming":
          return Icons.pool;
        case "technology":
          return Icons.computer;
        case "arts":
          return Icons.palette;
        case "languages":
          return Icons.translate;
        default:
          return Icons.event_available;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xffe2e8ff),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              getIcon(),
              color: const Color(0xff4c6fff),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["childName"] ?? "Child",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data["activityName"] ?? "Activity",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.attach_money,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${data["price"] ?? 0} SAR",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("حجوزاتي"),
        elevation: 0.4,
        backgroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("user_uid", isEqualTo: uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snap) {
          // 1) Loading فقط أول مرة
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) خطأ
          if (snap.hasError) {
            return const Center(child: Text("حدث خطأ أثناء تحميل الحجوزات"));
          }

          // 3) فاضي
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "لا يوجد أي حجوزات.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 4) جاهز
          final bookings = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              return bookingCard(data);
            },
          );
        },
      ),
    );
  }
}
