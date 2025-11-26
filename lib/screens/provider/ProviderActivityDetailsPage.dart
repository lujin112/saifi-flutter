import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/theme.dart';
import 'ProviderBookingsPage.dart';

class ProviderActivityDetailsPage extends StatelessWidget {
  final String activityId;

  const ProviderActivityDetailsPage({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Activity Details",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("activities")
              .doc(activityId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!snapshot.data!.exists) {
              return const Center(
                child: Text(
                  "Activity not found!",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              );
            }

            final activityData = snapshot.data!.data() as Map<String, dynamic>;
            final providerId = activityData["provider_id"];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("providers")
                  .doc(providerId)
                  .get(),
              builder: (context, providerSnapshot) {
                if (!providerSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final providerData =
                    providerSnapshot.data!.data() as Map<String, dynamic>?;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ACTIVITY TITLE
                        Text(
                          activityData["title"] ?? "",
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        _infoSection("Description", activityData["description"]),
                        _infoSection("Activity Type", activityData["activity_type"]),
                        _infoSection("Price", "${activityData["price_sar"]} SAR"),
                        _infoSection("Capacity",
                            activityData["capacity"].toString()),
                        _infoSection("Duration",
                            "${activityData["duration_hours"]} hours"),
                        _infoSection("Status", activityData["activity_status"]),
                        _infoSection(
                          "Age Ranges",
                          (activityData["age_ranges"] as List?)
                                  ?.join(", ") ??
                              "",
                        ),
                        _infoSection("Start Date", activityData["start_date"]),
                        _infoSection("End Date", activityData["end_date"]),

                        const SizedBox(height: 30),

                        // ============= PROVIDER INFO =============
                        const Text(
                          "Provider Information",
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (providerData != null) ...[
                          _infoSection("Provider Name",
                              "${providerData["first_name"]} ${providerData["last_name"]}"),
                          _infoSection("Phone", providerData["phone"]),
                          _infoSection("Email", providerData["email"]),
                          _infoSection("Commercial Registration",
                              providerData["cr_number"] ?? "N/A"),
                          _infoSection("Location",
                              "Lat: ${providerData["location"]["lat"]}, Lng: ${providerData["location"]["lng"]}"),
                        ] else
                          const Text(
                            "Provider not found.",
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'RobotoMono',
                            ),
                          ),

                        const SizedBox(height: 30),

                        // VIEW BOOKINGS BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProviderBookingsPage(activityId: activityId),
                              ),
                            );
                          },
                          child: const Text(
                            "View Bookings",
                            style: TextStyle(fontFamily: 'RobotoMono'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _infoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
