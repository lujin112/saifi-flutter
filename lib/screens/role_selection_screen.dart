import 'package:flutter/material.dart';
import 'theme.dart';
import 'parent_registration_screen.dart';
import 'ClubProviderRegistrationScreen.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeHeadline;
  late final Animation<Offset> _slideLogin;
  late final Animation<Offset> _slideOptions;
  late final Animation<double> _fadeOptions;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeHeadline = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _slideLogin = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
    ));

    _slideOptions = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    ));

    _fadeOptions = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/home.png',
                  height: size.height * 0.18,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeHeadline,
                  child: const Text(
                    "Because every child deserves a summer to remember – easy, fast, endless possibilities with Saifi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400, // أخف من bold
                      height: 1.4, // سطر مريح للقراءة
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SlideTransition(
                  position: _slideLogin,
                  child: _buildFullWidthButton(
                    context: context,
                    label: 'LOG IN',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FadeTransition(
                  opacity: _fadeOptions,
                  child: SlideTransition(
                    position: _slideOptions,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildIconRoleButton(
                            context: context,
                            label: 'PARENTS',
                            icon: Icons.family_restroom,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ParentRegistrationScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildIconRoleButton(
                            context: context,
                            label: 'CLUB PROVIDERS',
                            icon: Icons.sports_soccer,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ClubProviderRegistrationScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFullWidthButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400, // مو bold
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }

  Widget _buildIconRoleButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400, // خط أخف
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label),
      ),
    );
  }
}
