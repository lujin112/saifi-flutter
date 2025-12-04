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
  // ✅ CALCULATE AGE FROM BIRTH DATE
  // ---------------------------------------------------------
  int _calculateAge(dynamic birthDate) {
    if (birthDate == null) return 0;

    try {
      final date = birthDate is DateTime
          ? birthDate
          : DateTime.parse(birthDate.toString());

      final today = DateTime.now();
      int age = today.year - date.year;

      if (today.month < date.month ||
          (today.month == date.month && today.day < date.day)) {
        age--;
      }

      return age;
    } catch (_) {
      return 0;
    }
  }

  // ---------------------------------------------------------
  // ✅ ELIGIBILITY LOGIC (MATCHES BACKEND 100%)
  // ---------------------------------------------------------
  Map<String, dynamic> checkEligibility(Map<String, dynamic> child) {
    List<String> reasons = [];

    // -------- CHILD AGE --------
    int age = 0;

    if (child["birthdate"] != null) {
      age = _calculateAge(child["birthdate"]);
    } else if (child["age"] != null) {
      age = child["age"] is int
          ? child["age"]
          : int.tryParse(child["age"].toString()) ?? 0;
    }

    // -------- CHILD GENDER --------
    String gender =
        (child["gender"] ?? "unknown").toString().toLowerCase();

    // -------- ACTIVITY AGE RANGE (POSTGRES COMPATIBLE) --------
    int minAge = int.tryParse(activityData["age_from"].toString()) ?? 0;
    int maxAge = int.tryParse(activityData["age_to"].toString()) ?? 99;

    // -------- ACTIVITY GENDER --------
    String activityGender =
        (activityData["gender"] ?? "both").toString().toLowerCase();

    // -------- AGE CHECK --------
    if (age < minAge || age > maxAge) {
      reasons.add(
          "العمر غير مناسب: المطلوب من $minAge إلى $maxAge سنة.");
    }

    // -------- GENDER CHECK --------
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
                final List<String> reasons =
                    List<String>.from(result["reasons"]);

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
                            children:
                                reasons.map((r) => Text("• $r")).toList(),
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
                          child:
                              const Icon(Icons.child_care, size: 30),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            "${child['first_name'] ?? ''} ${child['last_name'] ?? ''}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: eligible
                                  ? Colors.black
                                  : Colors.grey.shade700,
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
