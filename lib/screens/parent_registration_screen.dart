import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ChildInfoScreen.dart'; // سيتم إنشاء هذا الملف

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

  // List to store multiple children
  final List<Map<String, dynamic>> _children = [];
  
  // Email domains for autocomplete
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
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('Parent Registration'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // First Name and Last Name in one row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // ID (Numbers only)
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Phone Number (Numbers only)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Email with domain suggestions
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
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
                    onPressed: () {
                      _showAddChildDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80C4C0),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Add Child',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Display added children
                if (_children.isNotEmpty) ...[
                  const Text(
                    'Added Children:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3558),
                    ),
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

                // Continue Button - تغيير النص والانتقال
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_children.isEmpty) {
                          _showMessage(context, 'No Children Added', 'Please add at least one child before continuing.');
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildInfoScreen(children: _children),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80C4C0),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Complete Child Information', // تغيير النص
                      style: TextStyle(fontSize: 16),
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

  // Show dialog to add child information
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
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: childFirstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Child First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: childLastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Child Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: childAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Child Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C4C0),
              ),
              child: const Text(
                'Add Child',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show confirmation message
  void _showConfirmationMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show message dialog
  void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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