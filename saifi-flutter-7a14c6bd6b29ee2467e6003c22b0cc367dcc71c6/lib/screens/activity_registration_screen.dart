import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'activity_welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ActivityRegistrationScreen extends StatefulWidget {
  const ActivityRegistrationScreen({super.key});

  @override
  State<ActivityRegistrationScreen> createState() =>
      _ActivityRegistrationScreenState();
}

class _ActivityRegistrationScreenState
    extends State<ActivityRegistrationScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int? _selectedDuration;
  final List<String> _selectedAgeRanges = [];
  String? _selectedActivityStatus;
  String? _selectedActivityType;

  final List<String> _ageRanges = [
    '3-5 years',
    '6-8 years',
    '9-12 years',
    '13-15 years',
    '16-18 years',
    'All ages'
  ];

  final List<int> _durations = [1, 2, 3, 4, 5, 6, 7, 8];

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
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Activity Registration',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Activity',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Basic Details"),
              _buildInput(_titleController, 'Activity Title', Icons.title),
              const SizedBox(height: 15),

              _buildDropdown<String>(
                label: 'Activity Type',
                icon: Icons.category_outlined,
                value: _selectedActivityType,
                items: _activityTypes,
                onChanged: (val) => setState(() => _selectedActivityType = val),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Description"),
              _buildTextArea(_descriptionController, 'Description',
                  Icons.description_outlined),
              const SizedBox(height: 20),

              _buildSectionTitle("Duration & Dates"),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Start Date',
                      controller: _startDateController,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'End Date',
                      controller: _endDateController,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDropdown<int>(
                label: 'Duration',
                icon: Icons.timer_outlined,
                value: _selectedDuration,
                items: _durations,
                itemBuilder: (d) => "$d ${d == 1 ? 'hour' : 'hours'}",
                onChanged: (val) => setState(() => _selectedDuration = val),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Capacity & Price"),
              _buildInput(_capacityController, 'Capacity',
                  Icons.people_alt_outlined,
                  inputType: TextInputType.number),
              const SizedBox(height: 15),

              _buildInput(
                _priceController,
                'Price (SAR)',
                Icons.attach_money,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Target Ages"),
              _buildAgeRangeSelection(),
              const SizedBox(height: 20),

              _buildSectionTitle("Status"),
              _buildDropdown<String>(
                label: 'Activity Status',
                icon: Icons.check_circle_outline,
                value: _selectedActivityStatus,
                items: const ['Active', 'Inactive', 'Draft'],
                onChanged: (val) =>
                    setState(() => _selectedActivityStatus = val),
              ),

              const SizedBox(height: 30),

              ShinyButton(
                text: "SAVE ACTIVITY",
                onPressed: () => _saveActivity(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTextArea(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                  itemBuilder != null ? itemBuilder(item) : item.toString()),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            const Icon(Icons.calendar_today, color: AppColors.primary),
      ),
    );
  }

  Widget _buildAgeRangeSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Age Range *',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ageRanges.map((age) {
              final isSelected = _selectedAgeRanges.contains(age);
              return FilterChip(
                label: Text(age),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAgeRanges.add(age);
                    } else {
                      _selectedAgeRanges.remove(age);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.grey[200],
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontFamily: 'RobotoMono',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month}-${picked.day}";
      setState(() {
        if (isStart) {
          _startDateController.text = formatted;
        } else {
          _endDateController.text = formatted;
        }
      });
    }
  }

  Future<void> _saveActivity(BuildContext context) async {
  if (_titleController.text.isEmpty ||
      _selectedDuration == null ||
      _selectedAgeRanges.isEmpty ||
      _selectedActivityStatus == null ||
      _selectedActivityType == null) {
    _showMessage(context, 'Error', 'Please fill all required fields', false);
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final providerId = prefs.getString("provider_id");

    if (providerId == null || providerId.isEmpty) {
      _showMessage(context, 'Error', 'Provider not logged in!', false);
      return;
    }

    final rawAge = _selectedAgeRanges.first.replaceAll(" years", "");
    final parts = rawAge.contains("-") ? rawAge.split("-") : [];

    final activityData = {
      "provider_id": providerId,
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "gender": null,
      "age_from": parts.isNotEmpty ? int.tryParse(parts[0]) : 0,
      "age_to": parts.length > 1 ? int.tryParse(parts[1]) : 99,
      "price": double.tryParse(_priceController.text.trim()) ?? 0.0,
      "duration": _selectedDuration,
      "type": _selectedActivityType,
      "status": _selectedActivityStatus == "Active",
      "start_date": _startDateController.text.trim(),
      "end_date": _endDateController.text.trim(),
    };

    final result = await ApiService.createActivity(activityData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityWelcomeScreen(activity: result),
      ),
    );

    _clearForm();
  } catch (e) {
    _showMessage(context, 'Error', 'Failed to save activity: $e', false);
  }
}


  void _showMessage(
      BuildContext context, String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
                fontFamily: 'RobotoMono', fontWeight: FontWeight.w600),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'RobotoMono'),
          ),
          icon: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 48,
          ),
          actions: [
            TextButton(
              child: Text(
                success ? 'OK' : 'TRY AGAIN',
                style: TextStyle(
                  color: success ? AppColors.primary : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  void _clearForm() {
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
    setState(() {});
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
