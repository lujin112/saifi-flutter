import 'package:flutter/material.dart';
import '../service/theme.dart';
import '../service/api_service.dart';

class ProviderBookingsPage extends StatefulWidget {
final String providerId;

  const ProviderBookingsPage({
  super.key,
  required this.providerId,
});


  @override
  State<ProviderBookingsPage> createState() => _ProviderBookingsPageState();
}

class _ProviderBookingsPageState extends State<ProviderBookingsPage> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
  _bookingsFuture =
      ApiService.getBookingsByProvider(widget.providerId);
}


  Future<void> _updateStatus(String bookingId, String status) async {
    try {
      await ApiService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );

      setState(() {
        _loadBookings();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final bookings = snapshot.data!;

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
                final data = bookings[index];
                final bookingId = data["booking_id"];
                final status = (data['status'] ?? "pending").toString();

                final bool isFinal =
                    status == "approved" || status == "rejected";

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
                        data['child_name'] ?? "Unknown Child",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Gender: ${data["child_gender"] ?? "-"}",
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                        ),
                      ),const SizedBox(height: 5),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: status == "approved"
                              ? Colors.green
                              : status == "rejected"
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: isFinal
                                  ? null
                                  : () => _updateStatus(
                                        bookingId,
                                        "approved",
                                      ),
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
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: isFinal
                                  ? null
                                  : () => _updateStatus(
                                        bookingId,
                                        "rejected",
                                      ),
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