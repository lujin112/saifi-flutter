// club_provider_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'activity_registration_screen.dart';

class ClubProviderRegistrationScreen extends StatefulWidget {
  const ClubProviderRegistrationScreen({super.key});

  @override
  State<ClubProviderRegistrationScreen> createState() =>
      _ClubProviderRegistrationScreenState();
}

class _ClubProviderRegistrationScreenState
    extends State<ClubProviderRegistrationScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _providerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isEmailMode = true;

  final List<String> _emailDomains = [
    '@gmail.com',
    '@hotmail.com',
    '@outlook.com',
    '@yahoo.com',
    '@icloud.com'
  ];

  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  GoogleMapController? _mapController;
  LatLng? _selectedLatLng;
  String _locationName = "No location selected";

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _providerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🔐 PASSWORD HASH FUNCTION
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 🔍 البحث عن الموقع بالاسم
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    try {
      List<Location> locations =
          await locationFromAddress(_searchController.text);

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential;

      if (_isEmailMode) {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: "${_phoneController.text.trim()}@provider.saifi",
          password: _passwordController.text.trim(),
        );
      }

      String uid = userCredential.user!.uid;

      Map<String, dynamic> providerData = {
        'provider_id': uid,
        'provider_name': _providerNameController.text.trim(),
        'email': _isEmailMode ? _emailController.text.trim() : null,
        'phone_number': _phoneController.text.trim(),
        'password_hash': hashPassword(_passwordController.text.trim()),
        'location': _selectedLatLng == null
            ? null
            : {
                'latitude': _selectedLatLng!.latitude,
                'longitude': _selectedLatLng!.longitude,
                'address': _locationName,
              },
        'created_at': DateTime.now(),
      };

      await firestore.collection('providers').doc(uid).set(providerData);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ActivityRegistrationScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration error: $e")),
      );
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
                Image.asset(
                  "assets/provider.png",
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _providerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Provider Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter provider name' : null,
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
                const SizedBox(height: 10),

                if (_isEmailMode)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!_emailDomains
                          .any((domain) => value.endsWith(domain))) {
                        return 'Email must end with ${_emailDomains.join(", ")}';
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone must be 10 digits';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 8 ? null : 'Invalid password',
                ),

                const SizedBox(height: 20),

                // 🔍 البحث عن الموقع
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

                // 🗺️ الخريطة المصغرة
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
                        target: LatLng(24.7136, 46.6753), // الرياض
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: _selectedLatLng == null
                          ? {}
                          : {
                              Marker(
                                markerId: const MarkerId("selected"),
                                position: _selectedLatLng!,
                              ),
                            },
                      onTap: (latLng) async {
                        List<Placemark> placemarks =
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
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _register,
                    child: AnimatedBuilder(
                      animation: _arrowAnimation,
                      builder: (context, child) {
                        return Padding(
                          padding:
                              EdgeInsets.only(right: _arrowAnimation.value),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 48,
                            color: Color(0xFF80C4C0),
                          ),
                        );
                      },
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
