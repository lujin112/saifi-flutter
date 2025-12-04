import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import '../service/theme.dart';

class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({super.key});

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  Map<String, dynamic>? providerData;
  bool isLoading = true;

  LatLng? _providerLatLng;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // =====================
  // ✅ LOAD PROVIDER PROFILE
  // =====================
  Future<void> _loadProviderProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final providerId = prefs.getString("provider_id");

    if (providerId == null || providerId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await ApiService.getProviderById(providerId);

      _nameController.text = data["name"] ?? "";
      _emailController.text = data["email"] ?? "";
      _phoneController.text = data["phone"] ?? "";

      if (data["location_lat"] != null && data["location_lng"] != null) {
        _providerLatLng = LatLng(
          data["location_lat"],
          data["location_lng"],
        );
      }

      setState(() {
        providerData = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ LOAD PROFILE ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // =====================
  // ✅ UPDATE PROFILE (FORCED SAFE)
  // =====================
  Future<void> _updateProfile() async {
    print("🔥 UPDATE BUTTON PRESSED");

    if (providerData == null) return;

    final prefs = await SharedPreferences.getInstance();
    final providerId = prefs.getString("provider_id");
    if (providerId == null) return;

    try {
      setState(() => isLoading = true);

      final Map<String, dynamic> updateData = {};

      if (_nameController.text.trim().isNotEmpty &&
          _nameController.text.trim() != providerData!["name"]) {
        updateData["name"] = _nameController.text.trim();
      }

      if (_emailController.text.trim().isNotEmpty &&
          _emailController.text.trim() != providerData!["email"]) {
        updateData["email"] = _emailController.text.trim();
      }

      if (_phoneController.text.trim().isNotEmpty &&
          _phoneController.text.trim() != providerData!["phone"]) {
        updateData["phone"] = _phoneController.text.trim();
      }

      if (_providerLatLng != null) {
        updateData["location_lat"] = _providerLatLng!.latitude;
        updateData["location_lng"] = _providerLatLng!.longitude;
        updateData["address"] = providerData!["address"];
      }

      if (updateData.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No changes to update")),
        );
        return;
      }

      print("✅ UPDATE DATA SENT: $updateData");

      await ApiService.updateProvider(
        providerId: providerId,
        data: updateData,
      );

      await _loadProviderProfile();

      setState(() {
        _editMode = false;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      print("❌ UPDATE ERROR: $e");
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Provider Profile"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: Icon(_editMode ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() => _editMode = !_editMode);
              },
            ),
          ],
        ),

        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : providerData == null
                ? const Center(
                    child: Text(
                      "Failed to load provider data",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.business,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              _editMode
                                  ? _input(_nameController, "Provider Name")
                                  : Text(
                                      providerData!["name"] ?? "",
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        _infoCard(
                          title: "Contact Information",
                          children: [
                            _editMode
                                ? _input(_emailController, "Email Address")
                                : _infoRow(Icons.email,
                                    providerData!["email"]),
                            _editMode
                                ? _input(_phoneController, "Phone")
                                : _infoRow(Icons.phone,
                                    providerData!["phone"]),
                          ],
                        ),

                        if (_providerLatLng != null) ...[
                          const SizedBox(height: 20),
                          _infoCard(
                            title: "Location",
                            children: [
                              SizedBox(
                                height: 200,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _providerLatLng!,
                                      zoom: 14,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId:
                                            const MarkerId("provider"),
                                        position: _providerLatLng!,
                                      ),
                                    },
                                    onTap: _editMode
                                        ? (latLng) {
                                            setState(() {
                                              _providerLatLng = latLng;
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_editMode) ...[
                          const SizedBox(height: 30),

                          // ✅ زر محفوظ من سرقة اللمس
                          ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize:
                                  const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  // =====================
  // ✅ UI HELPERS
  // =====================

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.primary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primary),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
