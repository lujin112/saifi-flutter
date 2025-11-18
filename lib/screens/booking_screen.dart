import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -------- CREATE BOOKING --------
  Future<void> createBooking({
    required String parentId,
    required String parentName,
    required String childId,
    required String childName,
    required String providerId,
    required String providerName,
    required String activityId,
    required String activityName,
    required num price,
    required DateTime activityDate,
    bool transportation = false,
    String? routeId,
  }) async {
    await _db.collection('bookings').add({
      'parentId': parentId,
      'parentName': parentName,
      'childId': childId,
      'childName': childName,
      'providerId': providerId,
      'providerName': providerName,
      'activityId': activityId,
      'activityName': activityName,
      'price': price,
      'activityDate': Timestamp.fromDate(activityDate),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'upcoming',
      'transportation': transportation,
      'routeId': routeId,
    });
  }

  // -------- CANCEL BOOKING --------
  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // -------- WATCH BOOKINGS --------
  Stream<List<Map<String, dynamic>>> watchBookings(
      String parentId, String status) {
    return _db
        .collection('bookings')
        .where("parentId", isEqualTo: parentId)
        .where("status", isEqualTo: status)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {"id": d.id, ...d.data()}).toList());
  }

  @override
  Widget build(BuildContext context) {
    const parentId = "demoParent"; // مؤقت

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bookings"),
          bottom: const TabBar(
            labelColor: Colors.teal,
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Ongoing"),
              Tab(text: "Past"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => openBookingForm(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            buildStreamList(parentId, "upcoming"),
            buildStreamList(parentId, "ongoing"),
            buildStreamList(parentId, "past"),
          ],
        ),
      ),
    );
  }

  // -------- BOOKING FORM --------
  void openBookingForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Booking",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  createBooking(
                    parentId: "demoParent",
                    parentName: "Demo Parent",
                    childId: "child01",
                    childName: "Omar",
                    providerId: "provider01",
                    providerName: "Provider",
                    activityId: "activity01",
                    activityName: "Swimming",
                    price: 100,
                    activityDate: DateTime.now(),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Confirm Booking"),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------- LIST BUILDER --------
  Widget buildStreamList(String parentId, String status) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: watchBookings(parentId, status),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snapshot.data!;
        if (list.isEmpty) {
          return const Center(child: Text("No bookings found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => BookingCard(data: list[i]),
        );
      },
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const BookingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data["childName"] ?? "Unknown Child",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            data["activityName"] ?? "Activity",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "${data["price"]} SAR",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}