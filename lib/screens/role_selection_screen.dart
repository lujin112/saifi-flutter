import 'package:flutter/material.dart';
import 'theme.dart';
import 'parent_registration_screen.dart';
import 'ClubProviderRegistrationScreen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/home.png',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              const Text(
                'WELCOME,\nJOIN US!',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 60),
              _buildRoleButton(
                context: context,
                label: 'AS PARENTS',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentRegistrationScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                context: context,
                label: 'AS CLUB PROVIDERS',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ClubProviderRegistrationScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Already a user? Log in',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
