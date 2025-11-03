import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'theme.dart';
import 'HomeScreen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Position? _currentPosition;
  String _locationName = "Detecting location...";
  bool _isLoading = false;
  bool _locationConfirmed = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    } else if (status.isDenied) {
      _showPermissionDeniedMessage();
    } else if (status.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedMessage();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDisabledMessage();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String address = await _getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _locationName = address;
        _updateMapMarker();
      });
    } catch (e) {
      _showErrorGettingLocation();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMapMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            infoWindow: InfoWindow(
              title: 'Your Location',
              snippet:
                  '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
      }
      return "Location: $latitude, $longitude";
    } catch (e) {
      return "Location: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Select Location',
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
                'Choose Your Location',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Search Location (coming soon)',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),

              // زر تحديد الموقع
              GestureDetector(
                onTap: _isLoading ? null : _getCurrentLocation,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: ShinyButton(
                    text: _isLoading ? "Detecting location..." : "Use Current Location",
                    onPressed: _getCurrentLocation,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              if (_currentPosition != null)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Your Current Location',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _locationName,
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // الخريطة
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentPosition != null) _updateMapMarker();
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                          : const LatLng(24.7136, 46.6753),
                      zoom: _currentPosition != null ? 15.0 : 10.0,
                    ),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // زر تأكيد الموقع
              GestureDetector(
                onTap: (_currentPosition != null && !_isLoading) ? _confirmLocation : null,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: ShinyButton(
                    text: _locationConfirmed
                        ? "Location Confirmed"
                        : "Confirm Location",
                    onPressed: _confirmLocation,
                  ),
                ),
              ),

              if (_locationConfirmed) ...[
                const SizedBox(height: 20),
                ShinyButton(
                  text: "Complete Registration & Go to Home",
                  onPressed: _completeRegistrationAndNavigateToHome,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLocation() {
    setState(() => _locationConfirmed = true);
    _saveLocationToDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location confirmed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveLocationToDatabase() {
    if (_currentPosition != null) {
      print(
          'Saving location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    }
  }

  void _completeRegistrationAndNavigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(userName: ''),
      ),
      (route) => false,
    );
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission is required to detect your location'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showPermissionPermanentlyDeniedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text('Please enable location permission from app settings'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationServiceDisabledMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enable location services on your device'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showErrorGettingLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error detecting location'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
