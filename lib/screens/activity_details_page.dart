import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'theme.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActivityDetailsPage({super.key, required this.data});

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate();
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    }
    if (value is String) return value;
    return "-";
  }

  String _formatAgeRange(dynamic value) {
    if (value is List) return value.join(", ");
    if (value is String) return value;
    return "All ages";
  }

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Activity';
    final String type = data['type'] ?? 'Activity';
    final String description = data['description'] ?? 'No description provided.';
    final String ageRange = _formatAgeRange(data['age_range']);
    final String startDate = _formatDate(data['start_date']);
    final String endDate = _formatDate(data['end_date']);
    final String status = (data['status'] ?? 'active').toString();
    final String providerId = data['provider_id'] ?? "";

    final int? capacity = data['capacity'];
    final int? duration = data['duration'];
    final num? price = data['price'];

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
            _buildHeroCard(title, type, status),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallTag("Age: $ageRange", Icons.group),
                if (capacity != null) _smallTag("Capacity: $capacity", Icons.people_alt_rounded),
                if (duration != null) _smallTag("Duration: $duration Hours", Icons.schedule),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _infoCard("Start date", startDate, Icons.calendar_today_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _infoCard("End date", endDate, Icons.event_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _infoCard("Price", price != null ? "$price SAR" : "-", Icons.payments_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _infoCard("Status", status, Icons.toggle_on_rounded)),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "About this activity",
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            _buildDescription(description),

            // ============================
            //       PROVIDER LOCATION
            // ============================
            if (providerId.isNotEmpty)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("providers").doc(providerId).get(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Loading provider location...",
                          style: TextStyle(fontFamily: 'RobotoMono')),
                    );
                  }

                  final providerData = snap.data!.data() as Map<String, dynamic>?;

                  if (providerData == null || providerData['location'] == null) {
                    return const SizedBox();
                  }

                  final loc = providerData['location'];

                  // ============================
                  //   AUTO-DETECT FIELD NAMES
                  // ============================

                  double lat = double.parse(
                    (loc['latitude'] ??
                     loc['lat'] ??
                     loc['Lat'] ??
                     loc['LAT']).toString(),
                  );

                  double lng = double.parse(
                    (loc['longitude'] ??
                     loc['lng'] ??
                     loc['long'] ??
                     loc['lang'] ??
                     loc['Lon'] ??
                     loc['LNG']).toString(),
                  );

                  final address = loc['address'] ?? "Unknown location";

                  return _buildProviderLocation(lat, lng, address);
                },
              ),

            const SizedBox(height: 30),

            _buildBookButton(context),
          ],
        ),
      ),
    );
  }

  // ===================================================
  //                     UI WIDGETS
  // ===================================================

  Widget _buildHeroCard(String title, String type, String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.18),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildChip(type.toUpperCase(), Icons.category),
                    _buildChip("Status: $status", Icons.check_circle),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderLocation(double lat, double lng, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          "Provider Location",
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onTap: () {
            final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
            launchUrl(Uri.parse(url));
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AbsorbPointer(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("provider"),
                    position: LatLng(lat, lng),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
        Text(
          address,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        description,
        style: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          height: 1.5,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Booking flow coming soon ✨",
                style: TextStyle(fontFamily: 'RobotoMono'),
              ),
            ),
          );
        },
        icon: const Icon(Icons.event_available_rounded, size: 22),
        label: const Text(
          "Book this activity",
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
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
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
