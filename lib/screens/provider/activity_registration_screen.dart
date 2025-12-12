import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/theme.dart';
import 'activity_welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';

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
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();

  int? _selectedDuration;
  String? _selectedActivityStatus;
  String? _selectedActivityType;
  String? _selectedGender;

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

  final List<String> _genders = ['Male', 'Female', 'Both'];

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
              _buildTextArea(
                _descriptionController,
                'Description',
                Icons.description_outlined,
              ),
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
                itemBuilder: (d) => "$d Hours",
                onChanged: (val) => setState(() => _selectedDuration = val),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Capacity & Price"),
              _buildInput(
                _capacityController,
                'Capacity',
                Icons.people_alt_outlined,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              _buildInput(
                _priceController,
                'Price (SAR)',
                Icons.attach_money,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Age Range"),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      _minAgeController,
                      'Min Age',
                      Icons.exposure_minus_1,
                      inputType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInput(
                      _maxAgeController,
                      'Max Age',
                      Icons.exposure_plus_1,
                      inputType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Gender"),
              _buildDropdown<String>(
                label: 'Target Gender',
                icon: Icons.wc,
                value: _selectedGender,
                items: _genders,
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
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
// save
Future<void> _saveActivity(BuildContext context) async {
  if (_titleController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _startDateController.text.isEmpty ||
      _endDateController.text.isEmpty ||
      _selectedDuration == null ||
      _selectedActivityStatus == null ||
      _selectedActivityType == null ||
      _selectedGender == null ||
      _minAgeController.text.isEmpty ||
      _maxAgeController.text.isEmpty ||
      _capacityController.text.isEmpty ||
      _priceController.text.isEmpty) {
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

    final activityData = {
      "provider_id": providerId,
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),

      // ✅ تصحيح الذكاء الصناعي
      "gender": _selectedGender!.toLowerCase(),
      "type": _selectedActivityType!.toLowerCase(),

      "age_from": int.parse(_minAgeController.text.trim()),
      "age_to": int.parse(_maxAgeController.text.trim()),
      "price": double.parse(_priceController.text.trim()),
      "capacity": int.parse(_capacityController.text.trim()),
      "duration": _selectedDuration,

      "status": _selectedActivityStatus == "Active",
      "start_date": _startDateController.text.trim(),
      "end_date": _endDateController.text.trim(),
    };

    // ✅ سير احترافي: إنشاء → جلب كامل → انتقال
    final created =
        await ApiService.createActivity(activityData);

    final activityId = created["activity_id"];

    final fullActivity =
        await ApiService.getActivityById(activityId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ActivityWelcomeScreen(activity: fullActivity),
      ),
    );

    _clearForm();
} catch (e) {
  final errorMsg = e.toString().toLowerCase().contains("duplicate")
      ? "This activity already exists with the same title, dates, and gender."
      : "Failed to save activity. Please try again.";

  _showMessage(context, 'Error', errorMsg, false);
}

}


  void _showMessage(
      BuildContext context, String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          icon: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 48,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
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
    _minAgeController.clear();
    _maxAgeController.clear();
    _selectedDuration = null;
    _selectedActivityStatus = null;
    _selectedActivityType = null;
    _selectedGender = null;
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
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) => Text(title);

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
  }) {
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
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
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
                itemBuilder != null ? itemBuilder(item) : item.toString(),
              ),
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

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      setState(() {
        if (isStart) {
          _startDateController.text = formatted;
        } else {
          _endDateController.text = formatted;
        }
      });
    }
  }
}
