import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../service/api_service.dart';
import 'ProviderBookingsPage.dart';

class ProviderActivityDetailsPage extends StatefulWidget {
  final String? activityId; // ✅ الآن يقبل null

  const ProviderActivityDetailsPage({
    super.key,
    this.activityId,
  });

  @override
  State<ProviderActivityDetailsPage> createState() =>
      _ProviderActivityDetailsPageState();
}

class _ProviderActivityDetailsPageState
    extends State<ProviderActivityDetailsPage> {
  String? loggedProviderId;
  Map<String, dynamic>? activityData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final prefs = await SharedPreferences.getInstance();
    loggedProviderId = prefs.getString("provider_id");

    print("🧠 LOGGED PROVIDER ID: $loggedProviderId");
    print("🧠 SENT ACTIVITY ID: ${widget.activityId}");

    if (loggedProviderId == null) {
      setState(() {
        errorMessage = "Provider not logged in";
        isLoading = false;
      });
      return;
    }

    try {
      // ✅ إذا جاء ID من الصفحة السابقة
      if (widget.activityId != null &&
          widget.activityId!.trim().isNotEmpty) {
        final data =
            await ApiService.getActivityById(widget.activityId!);

        if (data["provider_id"] != loggedProviderId) {
          throw Exception("Unauthorized activity access");
        }

        setState(() {
          activityData = data;
          isLoading = false;
        });
        return;
      }

      // ✅ إذا ما جاء ID (نجيب أول Activity للبروفايدر)
      final providerActivities =
          await ApiService.getProviderActivities(
              loggedProviderId!);

      if (providerActivities.isEmpty) {
        setState(() {
          errorMessage = "No activities found for this provider";
          isLoading = false;
        });
        return;
      }

      setState(() {
        activityData = providerActivities.first;
        isLoading = false;
      });
    } catch (e) {
      print("❌ DETAILS PAGE ERROR: $e");
      setState(() {
        errorMessage = "Failed to load activity";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // ✅ AppBar ثابت بالثيم
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            "Activity Details",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 2,
        ),

        body: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: Colors.white),
              )
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : _buildActivityContent(),
      ),
    );
  }

  Widget _buildActivityContent() {
    final a = activityData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a["title"] ?? "",
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),

            _infoSection("Description", a["description"] ?? "-"),
            _infoSection("Type", a["type"] ?? "-"),
            _infoSection("Price", "${a["price"]} SAR"),
            _infoSection("Capacity", "${a["capacity"] ?? "-"}"),
            _infoSection(
                "Duration", "${a["duration"] ?? "-"} hours"),
            _infoSection(
                "Status", a["status"] == true ? "Active" : "Inactive"),
            _infoSection(
                "Age Range", "${a["age_from"]} - ${a["age_to"]}"),
            _infoSection("Start Date",
                a["start_date"]?.toString() ?? "-"),
            _infoSection("End Date",
                a["end_date"]?.toString() ?? "-"),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize:
                    const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderBookingsPage(
                      activityId: a["activity_id"],
                    ),
                  ),
                );
              },
              child: const Text(
                "View Bookings",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
