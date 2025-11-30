import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'select_child_screen.dart';
import '../services/api_service.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String activityId;

  const ActivityDetailsPage({
    super.key,
    required this.data,
    required this.activityId,
  });

  // ---------------------------------------------------
  String _formatDate(dynamic value) {
    if (value is String) return value;
    return "-";
  }

  String _formatAgeRange(dynamic value) {
    if (value is String) return value;
    return "All ages";
  }

  // ---------------------------------------------------
  Future<String> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("parent_id")!;
  }

  // ---------------------------------------------------
  Future<List<Map<String, dynamic>>> _getChildren() async {
    final parentId = await _getParentId();
    final children = await ApiService.getChildrenByParent(parentId);
    return children;
  }

  // ---------------------------------------------------
  Future<String> _getProviderName(String providerId) async {
    if (providerId.isEmpty) return "Provider";
    final provider = await ApiService.getProviderById(providerId);
    return provider["name"] ?? "Provider";
  }

  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Activity';
    final String type = data['type'] ?? 'Activity';
    final String description =
        data['description'] ?? 'No description provided.';

    final String ageRange = _formatAgeRange(
      "${data["age_from"]}-${data["age_to"]}",
    );

    final String startDate = _formatDate(data['start_date']);
    final String endDate = _formatDate(data['end_date']);

    final String status = (data['status'] ?? true) ? "active" : "inactive";
    final String providerId = data['provider_id'] ?? "";

    final int? duration = data['duration'];
    final num? price = data['price'];

    int minAge = data["age_from"] ?? 0;
    int maxAge = data["age_to"] ?? 99;

    final String activityGender = data["gender"] ?? "both";

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

      // ---------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO CARD
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
                if (duration != null)
                  _smallTag("Duration: $duration Hours", Icons.schedule),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    "Start date",
                    startDate,
                    Icons.calendar_today_rounded,
                  ),
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
                    "Price",
                    price != null ? "$price SAR" : "-",
                    Icons.payments,
                  ),
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

            const SizedBox(height: 30),

            _buildBookButton(context, minAge, maxAge, activityGender),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  Widget _buildBookButton(
    BuildContext context,
    int minAge,
    int maxAge,
    String gender,
  ) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          final kids = await _getChildren();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectChildScreen(
                children: kids,
                activityData: {
                  "activity_id": activityId,
                  "title": data["title"],
                  "price": data["price"],
                  "providerId": data["provider_id"],
                  "min_age": minAge,
                  "max_age": maxAge,
                  "gender": data["gender"] ?? "both",
                  "start_date": data["start_date"]?.toString() ?? "",
                  "end_date": data["end_date"]?.toString() ?? "",
                },
              ),
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
    String providerName,
  ) {
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
                Text(providerName, style: const TextStyle(color: Colors.grey)),
              ],
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
