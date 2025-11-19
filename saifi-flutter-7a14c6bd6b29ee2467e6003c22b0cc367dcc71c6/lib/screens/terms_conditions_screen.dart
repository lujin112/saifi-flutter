import 'package:flutter/material.dart';
import 'booking_confirmation.dart';

class TermsConditionsScreen extends StatefulWidget {
  final Map<String, dynamic> activityData;
  final Map<String, dynamic> childData;

  const TermsConditionsScreen({
    super.key,
    required this.activityData,
    required this.childData,
  });

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "• Your child must attend the activity on time.\n"
                  "• Refund is subject to provider policy.\n"
                  "• Transportation is optional.\n"
                  "• Saifi is not responsible for provider misconduct.\n"
                  "• Parent must verify child information.",
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),

            Row(
              children: [
                Checkbox(
                  value: accepted,
                  onChanged: (v) => setState(() => accepted = v!),
                ),
                const Text("I accept the terms & conditions")
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: accepted
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmScreen(
                            activityData: widget.activityData,
                            childData: widget.childData,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
              ),
              child: const Text(
                "Proceed",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
