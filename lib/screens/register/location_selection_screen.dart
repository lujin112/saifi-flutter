import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/theme.dart';
import '../service/api_service.dart';
import '../home/HomeScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  LatLng? _selectedLatLng;

  bool _isLoading = false;
  bool _locationSaved = false;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ تحديد الموقع الحالي
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) await Geolocator.openLocationSettings();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      Position now = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selectedLatLng = LatLng(now.latitude, now.longitude);
      _updateMapMarker(_selectedLatLng!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't detect location"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ✅ البحث بالاسم
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    try {
      final locations =
          await locationFromAddress(_searchController.text);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        _selectedLatLng = LatLng(loc.latitude, loc.longitude);
        _updateMapMarker(_selectedLatLng!);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  void _updateMapMarker(LatLng latLng) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("selected"),
          position: latLng,
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 15),
    );
  }

  // ✅ حفظ الموقع فقط
  Future<void> _saveLocation() async {
    if (_selectedLatLng == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getString("parent_id");

      if (parentId == null || parentId.isEmpty) {
        throw Exception("Parent not logged in");
      }

      await ApiService.updateParentLocation(
        parentId: parentId,
        lat: _selectedLatLng!.latitude,
        lng: _selectedLatLng!.longitude,
      );

      if (!mounted) return;
      setState(() {
        _locationSaved = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save location: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ✅ الانتقال إلى الهوم بدون استدعاء API
  Future<void> _goHome() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String name =
          prefs.getString("parent_name") ?? "Parent";

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigation error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Select Location"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search location",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ShinyButton(
                text: _isLoading ? "Locating..." : "Use Current Location",
                onPressed: _isLoading ? null : _getCurrentLocation,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(24.7136, 46.6753),
                    zoom: 10,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  onTap: (latLng) {
                    _selectedLatLng = latLng;
                    _updateMapMarker(latLng);
                  },
                ),
              ),

              const SizedBox(height: 20),

              if (!_locationSaved)
                ShinyButton(
                  text: _isLoading ? "Saving..." : "Save Location",
                  onPressed:
                      _isLoading || _selectedLatLng == null ? null : _saveLocation,
                ),

              if (_locationSaved) ...[
                const SizedBox(height: 12),
                ShinyButton(text: "Go Home", onPressed: _goHome),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
