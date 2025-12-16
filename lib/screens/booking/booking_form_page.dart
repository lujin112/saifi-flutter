import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../service/theme.dart';
import 'booking_screen.dart';

class BookingFormPage extends StatefulWidget {
  final Map<String, dynamic> activity;

  const BookingFormPage({super.key, required this.activity});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;
  bool _loadingChildren = true;
  bool _showNotes = false;

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  // --------------------------------------------------
  Future<void> _loadChildren() async {
    try {
      setState(() => _loadingChildren = true);

      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("parent_id");

      if (parentId == null || parentId.isEmpty) {
        setState(() => _loadingChildren = false);
        return;
      }

      final children = await ApiService.getChildrenByParent(parentId)
          .timeout(const Duration(seconds: 10));

      final activityGender =
          (widget.activity["gender"] ?? "both").toString().toLowerCase();

      final filtered = children.where((c) {
        final gender = (c["gender"] ?? "").toString().toLowerCase();
        final genderOk = activityGender == "both" || gender == activityGender;

        return genderOk;
      }).toList();

      setState(() {
        _children = filtered;
        _loadingChildren = false;
      });
    } catch (_) {
      setState(() => _loadingChildren = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load children")),
        );
      }
    }
  }

  // --------------------------------------------------
  // ✅✅✅ منطق البوكنق كما هو ✅✅✅
  Future<void> _submitBooking() async {
    if (_selectedChild == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields")),
      );
      return;
    }

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString("parent_id");

    if (parentId == null || parentId.isEmpty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired, please login again")),
      );
      return;
    }

    try {
      await ApiService.createBooking(
        parentId: parentId,
        childId: _selectedChild!["child_id"].toString(),
        activityId: widget.activity["activity_id"].toString(),
        providerId: widget.activity["provider_id"].toString(),
        bookingDate: DateTime.now().toIso8601String(),
        startDate: _startDate!.toIso8601String().substring(0, 10),
        endDate: _endDate!.toIso8601String().substring(0, 10),
        notes: _showNotes && _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      setState(() => _loading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Booking Submitted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 14),
              Text(
                "Please visit the center to complete the payment process.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingScreen()),
                );
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }
  }

  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final a = widget.activity;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Booking"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Activity Card WITH ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.05),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_activity,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a["title"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("${a["price"]} SAR"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Select Child Title WITH ICON
            const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(Icons.child_care, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Select Child",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (_loadingChildren)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else if (_children.isEmpty)
              const Text("No eligible children found.")
            else
              Column(
                children: _children.map((c) {
                  final selected = _selectedChild == c;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedChild = c;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${c["first_name"]} ${c["last_name"]}",
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            if (_selectedChild != null) ...[
              const SizedBox(height: 20),
              const Text(
                "Do you want to tell us something about your child?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Yes"),
                      value: true,
                      groupValue: _showNotes,
                      onChanged: (_) {
                        setState(() => _showNotes = true);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("No"),
                      value: false,
                      groupValue: _showNotes,
                      onChanged: (_) {
                        setState(() => _showNotes = false);
                      },
                    ),
                  ),
                ],
              ),
              if (_showNotes)
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Write notes here...",
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                      child: Text(
                        _startDate == null
                            ? "Select Start Date"
                            : _startDate!.toString().substring(0, 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _endDate = picked);
                        }
                      },
                      child: Text(
                        _endDate == null
                            ? "Select End Date"
                            : _endDate!.toString().substring(0, 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitBooking,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm Booking"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
