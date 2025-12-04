import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../service/api_service.dart';
import '../service/theme.dart';
import '../home/HomeScreen.dart';
import '../provider/activity_welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController =
      TextEditingController(); // Email or Phone
  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ✅ الدور وطريقة الدخول
  String _selectedRole = "Parent"; // Parent | Provider
  String _loginMethod = "Email";   // Email | Phone

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

  // ===================== ✅ LOGIN (FINAL LOGIC) =====================
  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final identifier = _identifierController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ تنظيف أي جلسة قديمة

    Map<String, dynamic> result;

    // ===================== ✅ PARENT LOGIN =====================
    if (_selectedRole == "Parent") {
      result = await ApiService.loginParent(
        email: _loginMethod == "Email" ? identifier : null,
        phone: _loginMethod == "Phone" ? identifier : null,
        password: password,
      );

      // ✅ حفظ الجلسة بشكل صحيح
      await prefs.setString("parent_id", result["parent_id"].toString());
      await prefs.setString(
        "parent_name",
        "${result["first_name"]} ${result["last_name"]}",
      );
      await prefs.setString("role", "parent");

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName:
                "${result["first_name"]} ${result["last_name"]}",
          ),
        ),
        (route) => false,
      );
    }

    // ===================== ✅ PROVIDER LOGIN =====================
    else {
      result = await ApiService.loginProvider(
        email: _loginMethod == "Email" ? identifier : null,
        phone: _loginMethod == "Phone" ? identifier : null,
        password: password,
      );

      await prefs.setString(
          "provider_id", result["provider_id"].toString());
      await prefs.setString(
          "provider_name", result["name"]?.toString() ?? "");
      await prefs.setString("role", "provider");

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const ActivityWelcomeScreen(activity: {}),
        ),
        (route) => false,
      );
    }
  } catch (e) {
    _showMessage("Invalid login credentials");
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontFamily: 'RobotoMono'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ===================== UI =====================
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

              ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  'assets/login.png',
                  height: 120,
                  width: 120,
                ),
              ),

              const SizedBox(height: 30),

              // ===================== ROLE SWITCH =====================
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildRoleButton("Parent"),
                    _buildRoleButton("Provider"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===================== LOGIN METHOD SWITCH =====================
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      value: "Email",
                      groupValue: _loginMethod,
                      onChanged: (v) =>
                          setState(() => _loginMethod = v!),
                      title: const Text("Email"),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      value: "Phone",
                      groupValue: _loginMethod,
                      onChanged: (v) =>
                          setState(() => _loginMethod = v!),
                      title: const Text("Phone"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ===================== IDENTIFIER FIELD =====================
              TextFormField(
                controller: _identifierController,
                keyboardType: _loginMethod == "Phone"
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                inputFormatters: _loginMethod == "Phone"
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [],
                decoration: InputDecoration(
                  labelText: _loginMethod == "Phone"
                      ? "Phone Number"
                      : "Email",
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";

                  if (_loginMethod == "Email") {
                    if (!value.contains("@") ||
                        !value.contains(".")) {
                      return "Invalid email";
                    }
                  }

                  if (_loginMethod == "Phone") {
                    if (value.length != 10) {
                      return "Phone must be 10 digits";
                    }
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ===================== PASSWORD =====================
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter password'
                        : null,
              ),

              const SizedBox(height: 30),

              // ===================== LOGIN BUTTON =====================
              GestureDetector(
                onTap: _isLoading ? null : _login,
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
                        ? const CircularProgressIndicator(
                            color: Colors.white)
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
            ],
          ),
        ),
      ),
    );
  }

  // ===================== ROLE BUTTON =====================
  Widget _buildRoleButton(String role) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: _selectedRole == role
                ? AppColors.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              role,
              style: TextStyle(
                color: _selectedRole == role
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
