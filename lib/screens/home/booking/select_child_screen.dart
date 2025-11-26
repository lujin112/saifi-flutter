import 'package:flutter/material.dart';
import 'booking_confirmation.dart';

class SelectChildScreen extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final Map<String, dynamic> activityData;

  const SelectChildScreen({
    super.key,
    required this.children,
    required this.activityData,
  });

  // ---------------------------------------------------------
  // Eligibility Logic
  // ---------------------------------------------------------
 Map<String, dynamic> checkEligibility(Map<String, dynamic> child) {
  List<String> reasons = [];

  // Child age parsing
  int age = 0;
  try {
    age = child['age'] is int
        ? child['age']
        : int.tryParse(child['age'].toString()) ?? 0;
  } catch (_) {
    age = 0;
  }

  String gender = child['gender'] ?? "unknown";

  // Activity age range "9-12"
  int minAge = 0;
  int maxAge = 99;

  final rawRange = activityData["age_range"];

  if (rawRange is String && rawRange.contains("-")) {
    final parts = rawRange.split("-");
    if (parts.length >= 2) {
      minAge = int.tryParse(parts[0].trim()) ?? 0;
      maxAge = int.tryParse(parts[1].trim()) ?? 99;
    }
  }

  // Activity gender
  String activityGender = activityData["gender"] ?? "both";

  // Age check
  if (age < minAge || age > maxAge) {
    reasons.add("العمر غير مناسب: المطلوب من $minAge إلى $maxAge سنة.");
  }

  // Gender check
  if (activityGender != "both" && gender != activityGender) {
    reasons.add("الجنس غير مناسب لهذا النشاط.");
  }

  return {
    "isEligible": reasons.isEmpty,
    "reasons": reasons,
  };
}



  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("اختر الطفل"),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),

      body: children.isEmpty
          ? const Center(
              child: Text(
                "لا يوجد أطفال مسجلين",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                final result = checkEligibility(child);

                final bool eligible = result["isEligible"];
                final List<String> reasons = result["reasons"];

                return GestureDetector(
                  onTap: () {
                    if (!eligible) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("لا يمكن حجز النشاط"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: reasons.map((r) => Text("• $r")).toList(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("موافق"),
                            )
                          ],
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmScreen(
                          childData: child,
                          activityData: activityData,
                        ),
                      ),
                    );
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: eligible ? Colors.white : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: eligible
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: eligible
                                ? const Color(0xffe8efff)
                                : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.child_care, size: 30),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            "${child['first_name'] ?? ''} ${child['last_name'] ?? ''}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  eligible ? Colors.black : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
