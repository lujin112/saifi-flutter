import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'HomeScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Position? _currentPosition;
  bool _isLoading = false;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) await Geolocator.openLocationSettings();

      Position now = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 8),
      );

      setState(() {
        _currentPosition = now;
        _markers = {
          Marker(
            markerId: const MarkerId("current"),
            position: LatLng(now.latitude, now.longitude),
          )
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(now.latitude, now.longitude),
          16,
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't detect current location"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmLocation() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please get your current location first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("parents").doc(uid).update({
      "location": {
        "lat": _currentPosition!.latitude,
        "lng": _currentPosition!.longitude,
      }
    });

    final doc = await FirebaseFirestore.instance.collection("parents").doc(uid).get();
    final data = doc.data() ?? {};
    String name = "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}".trim();

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
        body: Column(
          children: [
            const SizedBox(height: 20),

            // زر تحديد الموقع
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ShinyButton(
                text: _isLoading ? "Finding your location..." : "Use Current Location",
                onPressed: () {
                  if (_isLoading) return;
                  _getCurrentLocation();
                },
              ),
            ),

            const SizedBox(height: 10),

            // الخريطة
            Expanded(
              child: GoogleMap(
                onMapCreated: (c) => _mapController = c,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(24.7136, 46.6753), // Riyadh default
                  zoom: 10,
                ),
                markers: _markers,
                myLocationEnabled: true,
              ),
            ),

            const SizedBox(height: 15),

            // زر تأكيد الموقع
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ShinyButton(
                text: "Confirm Location",
                onPressed: _confirmLocation,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
