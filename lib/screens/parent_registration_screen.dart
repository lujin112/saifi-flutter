import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'ChildInfoScreen.dart'; // الملف اللي راح تكمله لاحقاً

class ParentRegistrationScreen extends StatefulWidget {
  const ParentRegistrationScreen({super.key});

  @override
  State<ParentRegistrationScreen> createState() => _ParentRegistrationScreenState();
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
              // الصورة أعلى الفورم
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
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 15),

                    // Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 15),

                    // Email with autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.contains('@')) {
                          return const Iterable<String>.empty();
                        }
                        return _emailDomains.where((String domain) {
                          return domain.contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        final currentText = _emailController.text.split('@').first;
                        _emailController.text = '$currentText$selection';
                      },
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        _emailController = fieldTextEditingController;
                        return TextFormField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            hintText: 'username',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
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
                            leading: const Icon(Icons.child_care),
                            title: Text('${child['firstName']} ${child['lastName']}'),
                            subtitle: Text('Age: ${child['age']}'),
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

  // Custom text field using theme
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Dialogs as في كودك السابق
  void _showAddChildDialog() {
    final TextEditingController childFirstNameController = TextEditingController();
    final TextEditingController childLastNameController = TextEditingController();
    final TextEditingController childAgeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Child Information'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(controller: childFirstNameController, label: 'Child First Name'),
                const SizedBox(height: 15),
                _buildTextField(controller: childLastNameController, label: 'Child Last Name'),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: childAgeController,
                  label: 'Child Age',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    childAgeController.text.isNotEmpty) {
                  setState(() {
                    _children.add({
                      'firstName': childFirstNameController.text,
                      'lastName': childLastNameController.text,
                      'age': childAgeController.text,
                    });
                  });
                  Navigator.of(context).pop();
                  _showConfirmationMessage(context, 'Child added successfully!');
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
