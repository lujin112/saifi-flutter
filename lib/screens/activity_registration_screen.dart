// activity_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivityRegistrationScreen extends StatefulWidget {
  const ActivityRegistrationScreen({super.key});

  @override
  State<ActivityRegistrationScreen> createState() => _ActivityRegistrationScreenState();
}

class _ActivityRegistrationScreenState extends State<ActivityRegistrationScreen> {
  // Controllers for form fields
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Selected values
  int? _selectedDuration;
  final List<String> _selectedAgeRanges = [];
  String? _selectedActivityStatus;
  String? _selectedActivityType; // ✅ جديد

  // Age ranges
  final List<String> _ageRanges = [
    '3-5 years',
    '6-8 years',
    '9-12 years',
    '13-15 years',
    '16-18 years',
    'All ages'
  ];

  // Duration options (1 to 8 hours)
  final List<int> _durations = [1, 2, 3, 4, 5, 6, 7, 8];

  // Activity types (مرتبطة مع اهتمامات الطفل)
  final List<String> _activityTypes = [
    'Sports',
    'Languages',
    'Self-defense',
    'Arts',
    'Literature & Communication',
    'Technology',
    'Clubs & Activities'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('Activity Registration'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Activity Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Activity Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // ✅ Activity Type (مهم للتوصية)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Activity Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedActivityType,
                items: _activityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityType = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              
              // Activity Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 15),

              // Start Date
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectStartDate(context),
              ),
              const SizedBox(height: 15),

              // End Date
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectEndDate(context),
              ),
              const SizedBox(height: 15),

              // Duration
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDuration,
                items: _durations.map((duration) {
                  return DropdownMenuItem(
                    value: duration,
                    child: Text('$duration ${duration == 1 ? 'hour' : 'hours'}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Capacity
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),

              // Age Range
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age Range *', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _ageRanges.map((ageRange) {
                        final isSelected = _selectedAgeRanges.contains(ageRange);
                        return FilterChip(
                          label: Text(ageRange),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAgeRanges.add(ageRange);
                              } else {
                                _selectedAgeRanges.remove(ageRange);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF80C4C0),
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Activity Status
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Activity Status',
                  border: OutlineInputBorder(),
                ),
                value: _selectedActivityStatus,
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedActivityStatus = value;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Save Activity Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveActivity(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C4C0),
                  ),
                  child: const Text(
                    'SAVE ACTIVITY',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  void _saveActivity(BuildContext context) {
    if (_titleController.text.isEmpty ||
        _selectedDuration == null ||
        _selectedAgeRanges.isEmpty ||
        _selectedActivityStatus == null ||
        _selectedActivityType == null) { // ✅ تحقق من التايب
      _showMessage(context, 'Error', 'Please fill all required fields', false);
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _showMessage(context, 'Success', 'Activity information has been saved successfully!', true);
    });
  }

  void _showMessage(BuildContext context, String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          icon: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 48,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) _clearForm();
              },
              child: Text(
                isSuccess ? 'OK' : 'TRY AGAIN',
                style: TextStyle(
                  color: isSuccess ? const Color(0xFF80C4C0) : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _capacityController.clear();
      _priceController.clear();
      _selectedDuration = null;
      _selectedAgeRanges.clear();
      _selectedActivityStatus = null;
      _selectedActivityType = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
