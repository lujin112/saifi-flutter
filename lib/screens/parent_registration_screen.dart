import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'ChildInfoScreen.dart';

class ParentRegistrationScreen extends StatefulWidget {
  const ParentRegistrationScreen({super.key});

  @override
  State<ParentRegistrationScreen> createState() =>
      _ParentRegistrationScreenState();
}

class _ParentRegistrationScreenState extends State<ParentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<Map<String, dynamic>> _children = [];

  final List<String> _emailDomains = [
    '@gmail.com',
    '@hotmail.com',
    '@outlook.com',
    '@yahoo.com',
    '@icloud.com'
  ];

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Parent Registration',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/parentReg.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 25),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              label: 'First Name',
                              maxLength: 15,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              label: 'Last Name',
                              maxLength: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        controller: _idController,
                        label: 'ID',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter ID';
                          }
                          if (value.length != 10) {
                            return 'ID must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
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

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
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

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(fontFamily: 'RobotoMono'),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 8 ||
                              !RegExp(r'[A-Z]').hasMatch(value) ||
                              !RegExp(r'[a-z]').hasMatch(value) ||
                              !RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password does not meet requirements';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      ShinyButton(
                        text: "Add Child",
                        onPressed: _showAddChildDialog,
                      ),
                      const SizedBox(height: 20),

                      if (_children.isNotEmpty)
                        ..._children.map((child) => ListTile(
                          title: Text("${child['firstName']} ${child['lastName']}"),
                          subtitle: Text("Gender: ${child['gender']}"),
                        )),

                      const SizedBox(height: 20),

                      ShinyButton(
                        text: "Complete Child Information",
                        onPressed: _registerParent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerParent() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final auth = FirebaseAuth.instance;

      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection("parents").doc(uid).set({
        "user_uid": uid,
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "children_count": _children.length,
        "created_at": FieldValue.serverTimestamp(),
        "location": {
          "lat": 0,
          "lng": 0,
        },
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildInfoScreen(children: _children),
        ),
      );

    } catch (e) {
      _showMessage(context, "Registration Error", e.toString());
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'RobotoMono'),
      decoration: InputDecoration(
        labelText: label,
        counterText: "",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) return 'Please enter $label';
            return null;
          },
    );
  }

  void _showAddChildDialog() {
    final TextEditingController childFirstNameController = TextEditingController();
    final TextEditingController childLastNameController = TextEditingController();
    String? selectedGender;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Child Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                  controller: childFirstNameController,
                  label: 'Child First Name',
                  maxLength: 15),
              const SizedBox(height: 15),
              _buildTextField(
                  controller: childLastNameController,
                  label: 'Child Last Name',
                  maxLength: 15),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) => selectedGender = value,
                validator: (value) => value == null ? 'Select gender' : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ShinyButton(
              text: "Add Child",
              onPressed: () {
                if (childFirstNameController.text.isNotEmpty &&
                    childLastNameController.text.isNotEmpty &&
                    selectedGender != null) {
                  setState(() {
                    _children.add({
                      'firstName': childFirstNameController.text,
                      'lastName': childLastNameController.text,
                      'gender': selectedGender,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
