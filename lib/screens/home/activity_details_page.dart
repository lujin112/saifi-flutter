import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../booking/booking_form_page.dart';
import '../service/api_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityDetailsPage({
    super.key,
    required this.activity,
  });

  // -----------------------------
  String _formatDate(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return "-";
  }

  // -----------------------------
  Future<String> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("parent_id") ?? "";
  }

  // -----------------------------
  Future<List<Map<String, dynamic>>> _getChildren() async {
    final parentId = await _getParentId();
    if (parentId.isEmpty) return [];
    return await ApiService.getChildrenByParent(parentId);
  }

  // -----------------------------
  Future<String> _getProviderName(String providerId) async {
    if (providerId.isEmpty) return "Provider";
    final provider = await ApiService.getProviderById(providerId);
    return provider["name"] ?? "Provider";
  }

  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final String title = activity['title'] ?? 'Activity';
    final String type = activity['type'] ?? 'Activity';
    final String description =
        activity['description'] ?? 'No description provided.';

    final String startDate = _formatDate(activity['start_date']);
    final String endDate = _formatDate(activity['end_date']);

    final bool rawStatus = activity['status'] ?? true;
    final String status = rawStatus ? "active" : "inactive";

    final String providerId =
        activity['provider_id']?.toString() ?? "";

    final int? capacity = activity['capacity'];
    final int? duration = activity['duration'];
    final num? price = activity['price'];

    final int minAge = activity["age_from"] ?? 0;
    final int maxAge = activity["age_to"] ?? 99;

    final String activityGender =
        activity["gender"] ?? "both";

    final String activityId =
        activity["activity_id"]?.toString() ?? "";

    final String ageRange = "$minAge - $maxAge";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getProviderName(providerId),
              builder: (context, snap) {
                final providerName = snap.data ?? "Provider";
                return _buildHeroCard(title, type, status, providerName);
              },
            ),

            const SizedBox(height: 20),

            Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _smallTag("Age: $ageRange", Icons.group),

              _smallTag(
                "Gender: ${activityGender.toUpperCase()}",
                Icons.wc,
              ),

              if (capacity != null)
                _smallTag("Capacity: $capacity", Icons.people_alt_rounded),

              if (duration != null)
                _smallTag("Duration: $duration Hours", Icons.schedule),
            ],
          ),


            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _infoCard("Start date", startDate,
                      Icons.calendar_today_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard("End date", endDate, Icons.event_rounded),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                      "Price", price != null ? "$price SAR" : "-", Icons.payments),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard("Status", status, Icons.toggle_on_rounded),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "About this activity",
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),
            _buildDescription(description),

            const SizedBox(height: 24),

            const Text(
              "Location",
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            FutureBuilder<Map<String, double>?>(
              future: _getProviderLocation(providerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text("Location not available"),
                  );
                }

                final loc = snapshot.data!;
                final LatLng position =
                    LatLng(loc["lat"]!, loc["lng"]!);

                return Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: AppColors.primary.withOpacity(0.15),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: position, zoom: 14),
                      markers: {
                        Marker(
                          markerId: const MarkerId("provider"),
                          position: position,
                        )
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            _buildBookButton(
                context, activityId, minAge, maxAge, activityGender),
          ],
        ),
      ),
    );
  }

  Future<Map<String, double>?> _getProviderLocation(String providerId) async {
    if (providerId.isEmpty) return null;

    final provider = await ApiService.getProviderById(providerId);

    final lat = provider["location_lat"];
    final lng = provider["location_lng"];

    if (lat == null || lng == null) return null;

    return {
      "lat": double.parse(lat.toString()),
      "lng": double.parse(lng.toString()),
    };
  }

  // ✅ التعديل الوحيد هنا
  Widget _buildBookButton(
    BuildContext context,
    String activityId,
    int minAge,
    int maxAge,
    String gender,
  ) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingFormPage(activity: activity),
            ),
          );
        },

        child: const Text(
          "Book Now",
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  Widget _buildHeroCard(
      String title,
      String type,
      String status,
      String providerName) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.18),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.local_activity_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  providerName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text, IconData icon) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(desc),
    );
  }
}
