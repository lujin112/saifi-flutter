import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ActivityDetailsPage({super.key, required this.data});

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate();
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    } else if (value is String) {
      return value;
    }
    return "-";
  }

  String _formatAgeRange(dynamic value) {
    if (value is List) {
      return value.join(", ");
    } else if (value is String) {
      return value;
    }
    return "All ages";
  }

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Activity';
    final String type = data['type'] ?? 'Activity';
    final String description =
        data['description'] ?? 'No description provided.';
    final String ageRange = _formatAgeRange(data['age_range']);
    final String startDate = _formatDate(data['start_date']);
    final String endDate = _formatDate(data['end_date']);
    final String status = (data['status'] ?? 'active').toString();

    final int? capacity = data['capacity'] is int ? data['capacity'] as int : null;
    final int? duration = data['duration'] is int ? data['duration'] as int : null;
    final num? price = data['price'] is num ? data['price'] as num : null;

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
            // ====== HERO CARD ======
            Container(
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
            ),

            const SizedBox(height: 20),

            // ====== QUICK INFO TAGS ======
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallTag("Age: $ageRange", Icons.group),
                if (capacity != null)
                  _smallTag("Capacity: $capacity", Icons.people_alt_rounded),
                if (duration != null)
                  _smallTag("Duration: $duration Hours", Icons.schedule),
              ],
            ),

            const SizedBox(height: 20),

            // ====== INFO GRID ======
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    title: "Start date",
                    value: startDate,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    title: "End date",
                    value: endDate,
                    icon: Icons.event_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    title: "Price",
                    value: price != null ? "${price.toString()} SAR" : "-",
                    icon: Icons.payments_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                    title: "Status",
                    value: status,
                    icon: Icons.toggle_on_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ====== DESCRIPTION ======
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.primary.withOpacity(0.12)),
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
            ),

            const SizedBox(height: 30),

            // ====== CTA BUTTON (OPTIONAL BOOKING LATER) ======
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // هنا بعدين تروحين لصفحة البوكينق لما تجهزينها
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
            ),
          ],
        ),
      ),
    );
  }

  // ====== HELPERS ======

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

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
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
