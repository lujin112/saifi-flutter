// club_provider_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Position? _currentPosition;
  String _locationName = "No location selected";

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _providerNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _crnController = TextEditingController();

  final List<String> _emailDomains = [
    '@gmail.com',
    '@hotmail.com',
    '@outlook.com',
    '@yahoo.com',
    '@icloud.com'
  ];

  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _arrowAnimation =
        Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _providerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _crnController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _locationName =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}";
        } else {
          _locationName =
              "Lat: ${position.latitude}, Lng: ${position.longitude}";
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error detecting location")),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      // 1. Create provider account
      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Prepare provider data
      Map<String, dynamic> providerData = {
        'provider_id': uid,
        'provider_name': _providerNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'crn': _crnController.text.trim().isEmpty
            ? null
            : _crnController.text.trim(),
        'location': _currentPosition == null
            ? null
            : {
                'latitude': _currentPosition!.latitude,
                'longitude': _currentPosition!.longitude,
                'address': _locationName,
              },
        'created_at': DateTime.now(),
      };

      // 3. Save to Firestore
      await firestore.collection('providers').doc(uid).set(providerData);

      // 4. Navigate to next screen
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
                // Provider Name
                TextFormField(
                  controller: _providerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Provider Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter provider name' : null,
                ),
                const SizedBox(height: 15),

                // Email
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
                ),
                const SizedBox(height: 15),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.info_outline,
                          color: Color(0xFF80C4C0)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Password Requirements'),
                            content: const Text(
                              '- At least 8 characters\n'
                              '- At least 1 uppercase letter\n'
                              '- At least 1 lowercase letter\n'
                              '- At least 1 number',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain an uppercase letter';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain a lowercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Password must contain a number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone must be exactly 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // CRN
                TextFormField(
                  controller: _crnController,
                  decoration: const InputDecoration(
                    labelText:
                        'Commercial Registration Number (optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length != 10) {
                      return 'CRN must be exactly 10 digits if provided';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                if (_currentPosition != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text("Selected Location:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}"),
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
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_on,
                          color: Colors.red),
                      onPressed: _getLocation,
                    ),
                  ],
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
                          padding: EdgeInsets.only(
                              right: _arrowAnimation.value),
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
