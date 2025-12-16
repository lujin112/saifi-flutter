import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../service/theme.dart'; // ✅ ثيمكم

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  // ------------------------
  // ✅ Booking Card (WITH THEME + DELETE + BOOKING DATE)
  // ------------------------
  Widget bookingCard(BuildContext context, Map<String, dynamic> data) {
    final activityName = data["activity_title"] ?? "Activity";
    final childName = data["child_name"] ?? "Child";

    final rawStartDate = data["start_date"]?.toString() ?? "-";
    final startDate = rawStartDate.length >= 10
        ? rawStartDate.substring(0, 10)
        : rawStartDate;

    final rawBookingDate = data["booking_date"]?.toString() ?? "-";
    final bookingDate = rawBookingDate.length >= 10
        ? rawBookingDate.substring(0, 10)
        : rawBookingDate;

    final status = (data["status"] ?? "pending").toString().toLowerCase();
    final bookingId = data["booking_id"].toString();

    Color statusColor() {
      switch (status) {
        case "confirmed":
          return Colors.green;
        case "rejected":
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    String statusText() {
      switch (status) {
        case "approved":
          return "ACCEPTED";
        case "rejected":
          return "REJECTED";
        default:
          return "PENDING";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Activity
              Row(
                children: [
                  Icon(Icons.local_activity, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activityName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ✅ Registration Date
              Row(
                children: [
                  const Icon(Icons.event_note, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    "Booked on: $bookingDate",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ✅ Start Date
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    "Start: $startDate",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ✅ Child
              Row(
                children: [
                  Icon(Icons.child_care, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    childName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Actions
              Row(
                children: [
                  if (status == "approved")
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.rate_review),
                        label: const Text("Add Feedback"),
                        onPressed: () {
                          _showFeedbackSheet(context, data["activity_id"]);
                        },
                      ),
                    ),

                  const SizedBox(width: 10),

                  // ✅ Delete Booking (Parent)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Booking"),
                          content: const Text(
                              "Are you sure you want to delete this booking?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ApiService.deleteBooking(bookingId); // ✅
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking deleted")),
                        );
                        (context as Element).reassemble(); // refresh
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // ✅ Status Badge
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
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
  // ✅ Feedback Bottom Sheet (UNCHANGED)
  // ------------------------
  void _showFeedbackSheet(BuildContext context, String activityId) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Rate This Activity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // rating unchanged...

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Submit Feedback"),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Feedback submitted")),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------
  // ✅ Load Bookings
  // ------------------------
  Future<List<Map<String, dynamic>>> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString("parent_id");

    if (parentId == null || parentId.isEmpty) return [];

    return await ApiService.getParentBookings(parentId);
  }

  // ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Bookings"),
        elevation: 0.4,
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadBookings(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No bookings found.",
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              return bookingCard(context, snap.data![i]);
            },
          );
        },
      ),
    );
  }
}
