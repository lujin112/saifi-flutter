import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../service/api_service.dart';
import '../service/theme.dart';

class EditParentProfileScreen extends StatefulWidget {
  final String parentId;

  const EditParentProfileScreen({super.key, required this.parentId});

  @override
  State<EditParentProfileScreen> createState() =>
      _EditParentProfileScreenState();
}

class _EditParentProfileScreenState extends State<EditParentProfileScreen> {
  final TextEditingController _first = TextEditingController();
  final TextEditingController _last = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _location = TextEditingController();

  double? _lat;
  double? _lng;

  bool _loading = true;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // =========================
  // ✅ Load Parent Data
  // =========================
  Future<void> _loadData() async {
    try {
      final parent = await ApiService.getParentById(widget.parentId);

      _first.text = parent["first_name"] ?? "";
      _last.text = parent["last_name"] ?? "";
      _phone.text = parent["phone"] ?? "";

      final lat = parent["location_lat"];
      final lng = parent["location_lng"];

      if (lat != null && lng != null) {
        _lat = double.tryParse(lat.toString());
        _lng = double.tryParse(lng.toString());
        _location.text = "$_lat, $_lng";
      } else {
        _lat = null;
        _lng = null;
        _location.text = "";
      }
    } catch (e) {
      print("LOAD PROFILE ERROR: $e");
    }

    setState(() => _loading = false);
  }

  // =========================
  // ✅ Save Changes
  // =========================
  Future<void> _save() async {
    setState(() => _loading = true);

    try {
      await ApiService.updateParent(
        parentId: widget.parentId,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        phone: _phone.text.trim(),
      );

      if (_location.text.isNotEmpty) {
        final parts = _location.text.split(",");

        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());

          if (lat != null && lng != null) {
            await ApiService.updateParentLocation(
              parentId: widget.parentId,
              lat: lat,
              lng: lng,
            );
          }
        }
      }

      setState(() {
        _editMode = false;
        _loading = false;
      });

      _loadData();
    } catch (e) {
      print("UPDATE PROFILE ERROR: $e");
      setState(() => _loading = false);
    }
  }

  // =========================
  // ✅ Map View
  // =========================
  Widget _mapView() {
    if (_lat == null || _lng == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text("No location set"),
      );
    }

    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 6),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_lat!, _lng!),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("parent_location"),
              position: LatLng(_lat!, _lng!),
            ),
          },
          zoomControlsEnabled: false,
          myLocationEnabled: false,
        ),
      ),
    );
  }

  // =========================
  // ✅ Profile Field Card
  // =========================
  Widget _profileItem({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool enabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Parent Profile"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _editMode = !_editMode);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            _mapView(),

            _profileItem(
              icon: Icons.person,
              label: "First Name",
              controller: _first,
              enabled: _editMode,
            ),

            _profileItem(
              icon: Icons.person_outline,
              label: "Last Name",
              controller: _last,
              enabled: _editMode,
            ),

            _profileItem(
              icon: Icons.phone,
              label: "Phone Number",
              controller: _phone,
              enabled: _editMode,
            ),

            _profileItem(
              icon: Icons.location_on,
              label: "Location (lat, lng)",
              controller: _location,
              enabled: _editMode,
            ),

            if (_editMode) ...[
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
