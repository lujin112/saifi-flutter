import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  // ------------------------
  // كارد الحجز
  // ------------------------
Widget bookingCard(Map<String, dynamic> data) {
  final activityName = data["activity_title"] ?? "Activity";
  final childName =
      "${data["child_first_name"] ?? ""} ${data["child_last_name"] ?? ""}".trim();

  final date = data["booking_date"]?.toString().substring(0, 16) ?? "-";
  final status = (data["status"] ?? "on_progress").toString().toLowerCase();

  Color statusColor() {
    switch (status) {
      case "confirmed":
        return Colors.green;
      case "on_progress":
      default:
        return Colors.red;
    }
  }

  String statusText() {
    switch (status) {
      case "confirmed":
        return "CONFIRMED";
      case "on_progress":
      default:
        return "ON PROGRESS";
    }
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(18),
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
    child: Stack(
      children: [
        // ✅ محتوى الكارد الأساسي
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 اسم النشاط (في الأعلى)
            Text(
              activityName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // 🔹 التاريخ والوقت تحت الاسم
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 🔹 اسم الطفل
            Text(
              childName.isEmpty ? "Child" : childName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // ✅ حالة الحجز أعلى يمين الكارد
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusText(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  // ------------------------

  Future<List<Map<String, dynamic>>> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString("parent_id");

    if (parentId == null || parentId.isEmpty) return [];

    return await ApiService.getParentBookings(parentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("حجوزاتي"),
        elevation: 0.4,
        backgroundColor: Colors.white,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBookings(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text("حدث خطأ أثناء تحميل الحجوزات"));
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Text(
                "لا يوجد أي حجوزات.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final bookings = snap.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return bookingCard(bookings[index]);
            },
          );
        },
      ),
    );
  }
}
