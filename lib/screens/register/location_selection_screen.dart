import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/theme.dart';
import '../home/HomeScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Position? _currentPosition;
  LatLng? _selectedLatLng;

  bool _isLoading = false;
  bool _locationConfirmed = false;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  final TextEditingController _searchController = TextEditingController();

  // ✅ زر Use Current Location
  Future<void> _getCurrentLocation() async {
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

      _currentPosition = now;
      _selectedLatLng = LatLng(now.latitude, now.longitude);

      _updateMapMarker(_selectedLatLng!);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't detect location"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  // ✅ تحديث الماركر
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

  // ✅ تأكيد الموقع
  Future<void> _confirmLocation() async {
    if (_selectedLatLng == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("parents").doc(uid).update({
      "location": {
        "lat": _selectedLatLng!.latitude,
        "lng": _selectedLatLng!.longitude,
      },
    });

    setState(() => _locationConfirmed = true);
  }

  void _goHome() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection("parents")
        .doc(uid)
        .get();
    final data = doc.data() ?? {};
    String name = "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}"
        .trim();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name)),
      (_) => false,
    );
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
              // 🔍 البحث
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

              // 📍 زر الموقع الحالي
              ShinyButton(
                text: _isLoading ? "Locating..." : "Use Current Location",
                onPressed: () {
                  if (_isLoading) return;
                  _getCurrentLocation();
                },
              ),

              const SizedBox(height: 20),

              // 🗺️ الخريطة
              Expanded(
                child: GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(24.7136, 46.6753),
                    zoom: 10,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  onTap: (latLng) async {
                    _selectedLatLng = latLng;
                    _updateMapMarker(latLng);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ✅ تأكيد
              ShinyButton(
                text: "Confirm Location",
                onPressed: _confirmLocation,
              ),

              if (_locationConfirmed) ...[
                const SizedBox(height: 20),
                ShinyButton(text: "Go Home", onPressed: _goHome),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
