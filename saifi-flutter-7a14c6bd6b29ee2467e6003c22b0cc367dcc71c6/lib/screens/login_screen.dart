import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // ✅ LOGIN VIA API
  // =========================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.loginParent(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final parent = result["parent"];
      final parentId = parent["parent_id"];
      final userName =
          "${parent["first_name"] ?? ""} ${parent["last_name"] ?? ""}".trim();

      // ✅ حفظ parent_id محليًا بدل FirebaseAuth
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("parent_id", parentId);

      setState(() => _isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: userName),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // ✅ UI (لم نلمسه)
  // =========================
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
                child: const Icon(
                  Icons.lock_outline,
                  size: 90,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Welcome back to Saifi",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "Sign in to continue",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: AppColors.textDark.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 20),

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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Don’t have an account? ",
                    style: TextStyle(fontFamily: 'RobotoMono'),
                  ),
                  Text(
                    "Sign up",
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
