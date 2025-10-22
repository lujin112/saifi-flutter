// location_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'HomeScreen.dart'; // تأكد من وجود هذا الملف

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

  // طلب صلاحيات الموقع
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    final status = await Permission.location.request();
    
    if (status.isGranted) {
      await _getCurrentLocation();
    } else if (status.isDenied) {
      _showPermissionDeniedMessage();
    } else if (status.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedMessage();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  // الحصول على الموقع الحالي
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDisabledMessage();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // الحصول على اسم الموقع من الإحداثيات
      String address = await _getAddressFromLatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        _locationName = address;
        _updateMapMarker();
      });
    } catch (e) {
      _showErrorGettingLocation();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // تحديث العلامة على الخريطة
  void _updateMapMarker() {
    if (_currentPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: InfoWindow(
              title: 'Your Location',
              snippet: '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        };
      });

      // تحريك الكاميرا إلى الموقع
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  // تحويل الإحداثيات إلى عنوان
  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude,
      );
      
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
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3558),
              ),
            ),
            const SizedBox(height: 20),
            
            // Location search input
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Search Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            
            // Current location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80C4C0),
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: _isLoading 
                    ? const Text('Detecting location...')
                    : const Text('Use Current Location'),
              ),
            ),
            const SizedBox(height: 30),
            
            // Location information
            if (_currentPosition != null) ...[
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Your Current Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _locationName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Coordinates: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Map with Google Maps
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      _updateMapMarker();
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : const LatLng(24.7136, 46.6753), // موقع افتراضي (الرياض)
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
            
            // Confirm location button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _currentPosition != null && !_isLoading
                    ? () {
                        _confirmLocation();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _locationConfirmed 
                      ? Colors.green 
                      : const Color(0xFF80C4C0),
                  foregroundColor: Colors.white,
                ),
                child: _locationConfirmed
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Location Confirmed',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : const Text(
                        'Confirm Location',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            // Continue to home button
            if (_locationConfirmed) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _completeRegistrationAndNavigateToHome();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Complete Registration & Go to Home',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmLocation() {
    setState(() {
      _locationConfirmed = true;
    });
    
    // حفظ الإحداثيات في الداتابيس
    _saveLocationToDatabase();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location confirmed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveLocationToDatabase() {
    // حفظ الإحداثيات في الداتابيس
    if (_currentPosition != null) {
      print('Saving location to database: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      // هنا تضيف كود حفظ في الداتابيس
      // Database.saveLocation(_currentPosition!.latitude, _currentPosition!.longitude, _locationName);
    }
  }

  void _completeRegistrationAndNavigateToHome() {
    // الانتقال مباشرة للصفحة الرئيسية بدون Dialog
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen(userName: '',)),
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