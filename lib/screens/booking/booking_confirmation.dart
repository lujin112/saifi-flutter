import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';

class BookingConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> childData;
  final Map<String, dynamic> activityData;

  const BookingConfirmScreen({
    super.key,
    required this.childData,
    required this.activityData,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool agreed = false;
  bool saving = false;

  // ✅ حساب العمر من PostgreSQL
  int calculateAge(dynamic birthDate) {
    try {
      if (birthDate == null) return 0;
      final birth = DateTime.parse(birthDate.toString());
      final today = DateTime.now();
      int age = today.year - birth.year;

      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }

      return age;
    } catch (_) {
      return 0;
    }
  }

  // ✅ تنسيق التاريخ
  String safeDate(dynamic v) {
    try {
      if (v == null) return "-";
      final s = v.toString();
      return s.length >= 10 ? s.substring(0, 10) : s;
    } catch (_) {
      return "-";
    }
  }

  // ✅ إرسال الحجز إلى PostgreSQL (مطابق للسكيما)
  Future<void> confirmBooking() async {
    if (!agreed || saving) return;

    setState(() => saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("parent_id");

      if (parentId == null || parentId.isEmpty) {
        setState(() => saving = false);
        return;
      }

      await ApiService.createBooking(
        parentId: parentId,
        childId: widget.childData["child_id"].toString(),
        activityId: widget.activityData["activity_id"].toString(),
        providerId: widget.activityData["provider_id"].toString(),
        status: "on_progress",
        bookingDate: DateTime.now().toIso8601String().substring(0, 10),
      );

      setState(() => saving = false);

      Navigator.pushReplacementNamed(context, "/booking");
    } catch (e) {
      setState(() => saving = false);
      print("BOOKING ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.childData;
    final activity = widget.activityData;

    final int childAge = calculateAge(child["birthdate"]);

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        title: const Text("تأكيد الحجز"),
        elevation: 0.4,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CHILD CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${child['first_name'] ?? ''} ${child['last_name'] ?? ''}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("العمر: $childAge"),
                  Text("الجنس: ${child['gender'] ?? '-'}"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ ACTIVITY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffeef3ff),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("تاريخ البداية: ${safeDate(activity['start_date'])}"),
                  Text("تاريخ النهاية: ${safeDate(activity['end_date'])}"),
                ],
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Checkbox(
                  value: agreed,
                  onChanged: (v) => setState(() => agreed = v!),
                ),
                const Expanded(
                  child: Text("أوافق على الشروط والأحكام"),
                ),
              ],
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: agreed ? confirmBooking : null,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تأكيد الحجز"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
