import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  TextEditingController _emailController = TextEditingController();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Parent Registration',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/parentReg.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // First Name & Last Name
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

                    // ID
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

                    // Phone
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
                          return 'Please enter Phone Number';
                        }
                        if (value.length != 10) {
                          return 'Phone must be exactly 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Email with validation of domain
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        hintText: 'username@example.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!_emailDomains
                            .any((domain) => value.endsWith(domain))) {
                          return 'Email must end with ${_emailDomains.join(", ")}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password with rules icon
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.info_outline,
                              color: AppColors.primary),
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
                          return 'Please enter Password';
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
                    const SizedBox(height: 30),

                    // Add Child Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _showAddChildDialog,
                        child: const Text('Add Child'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Display children
                    if (_children.isNotEmpty) ...[
                      const Text(
                        'Added Children:',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 10),
                      ..._children.map((child) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(
                              Icons.child_care, // الأيقونة الأصلية
                              color: child['gender'] == 'Female'
                                  ? Colors.pinkAccent
                                  : AppColors.primary,
                              size: 32,
                            ),
                            title: Text(
                                '${child['firstName']} ${child['lastName']}'),
                            subtitle: Text('Gender: ${child['gender']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _children.remove(child);
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_children.isEmpty) {
                              _showMessage(
                                context,
                                'No Children Added',
                                'Please add at least one child before continuing.',
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChildInfoScreen(children: _children),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Complete Child Information'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field with validator
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
      decoration: InputDecoration(
        labelText: label,
        counterText: "", // يخفي العداد
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (maxLength != null && value.length > maxLength) {
              return '$label cannot exceed $maxLength characters';
            }
            return null;
          },
    );
  }

  // Dialog for adding child
  void _showAddChildDialog() {
    final TextEditingController childFirstNameController =
        TextEditingController();
    final TextEditingController childLastNameController =
        TextEditingController();
    String? selectedGender;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Child Information'),
          content: SingleChildScrollView(
            child: Column(
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

                // Gender dropdown
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text('Female'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedGender = value;
                  },
                  validator: (value) =>
                      value == null ? 'Please select gender' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
                  _showConfirmationMessage(
                      context, 'Child added successfully!');
                } else {
                  _showMessage(context, 'Error', 'Please fill all fields');
                }
              },
              child: const Text('Add Child'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
