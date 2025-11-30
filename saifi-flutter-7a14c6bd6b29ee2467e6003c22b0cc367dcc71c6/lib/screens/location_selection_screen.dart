import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'theme.dart';
import 'HomeScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Position? _currentPosition;
  bool _isLoading = false;
  bool _locationConfirmed = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  Future<String?> _getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("parent_id");
  }

  // -------------------- GET LOCATION --------------------
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) await Geolocator.openLocationSettings();

      Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _currentPosition = last;
        _updateMapMarker();
      }

      Position now = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 8),
      );

      _currentPosition = now;
      _updateMapMarker();
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

  void _updateMapMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("me"),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15,
      ),
    );
  }

  // -------------------- CONFIRM LOCATION (API) --------------------
  Future<void> _confirmLocation() async {
    if (_currentPosition == null) return;

    final parentId = await _getParentId();
    if (parentId == null) return;

    await ApiService.updateParentLocation(
      parentId: parentId,
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
    );

    setState(() => _locationConfirmed = true);
  }

  // -------------------- GO HOME --------------------
  Future<void> _goHome() async {
    final parentId = await _getParentId();
    if (parentId == null) return;

    final parent = await ApiService.getParentById(parentId);
    final String name =
        "${parent["first_name"] ?? ""} ${parent["last_name"] ?? ""}".trim();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(userName: name)),
      (_) => false,
    );
  }

  // -------------------- UI --------------------
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
                ),
              ),

              const SizedBox(height: 20),

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
