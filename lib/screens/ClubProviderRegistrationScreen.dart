// club_provider_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'activity_registration_screen.dart';

class ClubProviderRegistrationScreen extends StatefulWidget {
  const ClubProviderRegistrationScreen({super.key});

  @override
  State<ClubProviderRegistrationScreen> createState() => _ClubProviderRegistrationScreenState();
}

class _ClubProviderRegistrationScreenState extends State<ClubProviderRegistrationScreen> {
  Position? _currentPosition;
  String _locationName = "No location selected";

  final TextEditingController _passwordController = TextEditingController();

  Future<void> _getLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _locationName = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        } else {
          _locationName = "Lat: ${position.latitude}, Lng: ${position.longitude}";
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error detecting location")),
      );
    }
  }

  void _register() {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password cannot be empty")),
      );
      return;
    }

    // هنا تقدر تحفظ البيانات (المدرسة + الموقع + الباسوورد) في قاعدة البيانات
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ActivityRegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('School Registration'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'School Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Commercial Registration Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              if (_currentPosition != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Selected Location:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}"),
                        Text("Address: $_locationName"),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _locationName,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on, color: Colors.red),
                    onPressed: _getLocation,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C4C0),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
