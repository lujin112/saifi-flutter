import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api_service.dart';
import 'activity_registration_screen.dart';

class ClubProviderRegistrationScreen extends StatefulWidget {
  const ClubProviderRegistrationScreen({super.key});

  @override
  State<ClubProviderRegistrationScreen> createState() =>
      _ClubProviderRegistrationScreenState();
}

class _ClubProviderRegistrationScreenState
    extends State<ClubProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _providerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isEmailMode = true;
  bool _obscurePassword = true;
  bool _isRegistering = false;

  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;
  String _locationName = "No location selected";

  @override
  void dispose() {
    _providerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🔍 Search location
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    try {
      final locations = await locationFromAddress(_searchController.text);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        setState(() {
          _selectedLatLng = LatLng(loc.latitude, loc.longitude);
          _locationName = _searchController.text;
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_selectedLatLng!),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  // ✅ REGISTER
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select location")),
      );
      return;
    }

    if (_isRegistering) return;

    setState(() => _isRegistering = true);

    try {
      final providerData = {
        "name": _providerNameController.text.trim(),
        "email": _isEmailMode ? _emailController.text.trim() : null,
        "phone": !_isEmailMode ? _phoneController.text.trim() : null,
        "password": _passwordController.text.trim(),
        "location_lat": _selectedLatLng!.latitude,
        "location_lng": _selectedLatLng!.longitude,
        "address": _locationName,
      };

      final registerResult =
          await ApiService.registerProvider(providerData);

      final loginResult = await ApiService.loginProvider(
        email: _isEmailMode ? _emailController.text.trim() : null,
        phone: !_isEmailMode ? _phoneController.text.trim() : null,
        password: _passwordController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          "provider_id", loginResult["provider_id"].toString());
      await prefs.setString(
          "provider_name", loginResult["name"].toString());

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ActivityRegistrationScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('Club Provider Registration'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset("assets/provider.png", height: 200),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _providerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Provider Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter provider name' : null,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Email"),
                    Switch(
                      value: !_isEmailMode,
                      activeColor: const Color(0xFF80C4C0),
                      onChanged: (v) {
                        setState(() => _isEmailMode = !v);
                      },
                    ),
                    const Text("Phone"),
                  ],
                ),

                if (_isEmailMode)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter email';
                      if (!v.contains('@') || !v.endsWith('.com')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.length != 10) {
                        return 'Phone must be 10 digits';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 8
                          ? null
                          : 'Password too short',
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search location",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchLocation,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(24.7136, 46.6753),
                        zoom: 12,
                      ),
                      onMapCreated: (c) => _mapController = c,
                      markers: _selectedLatLng == null
                          ? {}
                          : {
                              Marker(
                                markerId: const MarkerId("selected"),
                                position: _selectedLatLng!,
                              ),
                            },
                      onTap: (latLng) async {
                        final placemarks =
                            await placemarkFromCoordinates(
                          latLng.latitude,
                          latLng.longitude,
                        );

                        setState(() {
                          _selectedLatLng = latLng;
                          if (placemarks.isNotEmpty) {
                            final p = placemarks.first;
                            _locationName =
                                "${p.street ?? ''}, ${p.locality ?? ''}";
                          } else {
                            _locationName =
                                "Lat: ${latLng.latitude}, Lng: ${latLng.longitude}";
                          }
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _locationName,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isRegistering ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80C4C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isRegistering
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
