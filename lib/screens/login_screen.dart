import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController(); // Email OR Phone
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String? _selectedRole; // Parent or Provider
  String? _selectedLoginMethod; // Email or Phone

  late AnimationController _iconController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null || _selectedLoginMethod == null) {
      _showMessage("Please choose your role and login method.");
      return;
    }

    setState(() => _isLoading = true);

    String collection =
        _selectedRole == "Parent" ? "parents" : "providers";

    String field =
        _selectedLoginMethod == "Email" ? "email" : "phone";

    String typedValue = _identifierController.text.trim();
    String typedPassword = _passwordController.text.trim();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where(field, isEqualTo: typedValue)
          .get();

      if (snapshot.docs.isEmpty) {
        _showMessage("Account not found.");
        setState(() => _isLoading = false);
        return;
      }

      final data = snapshot.docs.first.data();

      if (data["password"] != typedPassword) {
        _showMessage("Incorrect password.");
        setState(() => _isLoading = false);
        return;
      }

      // Login success → HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: data["first_name"] ?? typedValue,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      _showMessage("Login error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'RobotoMono')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Login', style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Icon Animation
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Icon(
                  Icons.lock_outline,
                  size: 90,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome back to Saifi",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 40),

              // اختيار الدور Parent / Provider
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Who are you?",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Parent", child: Text("Parent")),
                  DropdownMenuItem(value: "Provider", child: Text("Provider")),
                ],
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) =>
                    v == null ? "Please select your role" : null,
              ),

              const SizedBox(height: 20),

              // طريقة تسجيل الدخول Email أو Phone
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Login using",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Email", child: Text("Email")),
                  DropdownMenuItem(value: "Phone", child: Text("Phone Number")),
                ],
                onChanged: (v) => setState(() => _selectedLoginMethod = v),
                validator: (v) =>
                    v == null ? "Please select a login method" : null,
              ),

              const SizedBox(height: 20),

              // حقل Email أو Phone حسب الاختيار
              TextFormField(
                controller: _identifierController,
                decoration: InputDecoration(
                  labelText: _selectedLoginMethod == "Phone"
                      ? "Phone Number"
                      : "Email",
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    _selectedLoginMethod == "Phone"
                        ? Icons.phone
                        : Icons.email_outlined,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'This field cannot be empty' : null,
              ),

              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
              ),

              const SizedBox(height: 30),

              // Login Button
              GestureDetector(
                onTap: _isLoading ? null : _login,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.95),
                          AppColors.primary.withOpacity(0.75),
                        ],
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
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
