import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // حساب العمر بشكل آمن (String + Timestamp)
  int calculateAge(dynamic birthDate) {
    try {
      DateTime birth;

      if (birthDate is Timestamp) {
        birth = birthDate.toDate();
      } else if (birthDate is String) {
        birth = DateTime.parse(birthDate);
      } else {
        return 0;
      }

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

  // safe date
  String safeDate(dynamic v) {
    try {
      if (v is Timestamp) {
        final d = v.toDate();
        return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      }

      if (v is String) {
        if (v.length >= 10) return v.substring(0, 10);
        return v;
      }
    } catch (_) {}

    return "-";
  }

  // تأكيد الحجز
  Future<void> confirmBooking() async {
    if (!agreed || saving) return;

    setState(() => saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("booking").add({
      "childAge": calculateAge(widget.childData["birthday"] ?? ""),
    });

    setState(() => saving = false);

    Navigator.pushNamed(context, "/booking");
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.childData;
    final activity = widget.activityData;

    final int childAge = calculateAge(child["birthday"]);

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

            // CHILD CARD
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
                  Text(child['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 6),
                  Text("العمر: $childAge"),
                  Text("الجنس: ${child['gender']}"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ACTIVITY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffeef3ff),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
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
                const Expanded(child: Text("أوافق على الشروط والأحكام")),
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
