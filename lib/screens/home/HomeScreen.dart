import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'browse_activities_screen.dart';
import '../register/role_selection_screen.dart';
import 'chatbot_screen.dart';
import '../service/theme.dart';
import 'profile_page.dart';
import '../booking/booking_screen.dart';
import 'add_child.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isArabic = false;
  String _userName = "";

  late List<Widget> _pages;

@override
void initState() {
  super.initState();
  _loadUserName();

  _pages = [
    HomePage(userName: _userName),
    const ChatbotScreen(),
    ProfilePage(),
  ];
}

Future<void> _loadUserName() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString("parent_name") ?? "";

  setState(() {
    _userName = name;
    _pages = [
      HomePage(userName: _userName),
      const ChatbotScreen(),
      ProfilePage(),
    ];
  });
}


 Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // يمسح parent_id و parent_name وأي جلسة

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    (route) => false, // يمسح كل الستاك
  );
}


  void _openAddChildForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddChildScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Directionality(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Saifi',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.textDark,
                  size: 26,
                ),
                onPressed: _logout, // ✅ الآن يعمل فعليًا
              ),
            ],
          ),

          body: _pages[_currentIndex],

          bottomNavigationBar: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navItem(
                  label: "Home",
                  icon: Icons.home,
                  isSelected: _currentIndex == 0,
                  onTap: () {
                    setState(() => _currentIndex = 0);
                  },
                ),

                GestureDetector(
                  onTap: _openAddChildForm,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                _navItem(
                  label: "Profile",
                  icon: Icons.person,
                  isSelected: _currentIndex == 2,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'RobotoMono',
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ---------------- HOME PAGE ----------------

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(userName),
          const SizedBox(height: 25),
          _buildSlideshow(),
          const SizedBox(height: 30),
          _buildMainOptions(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name 👋',
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.15), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: const Text(
            "Welcome back! Ready to explore new experiences?",
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideshow() {
    final PageController controller = PageController();

    Timer.periodic(const Duration(seconds: 6), (_) {
      if (controller.hasClients) {
        final nextPage = (controller.page ?? 0).round() == 0 ? 1 : 0;
        controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    return SizedBox(
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView(
          controller: controller,
          children: const [
            Image(
              image: AssetImage("assets/slideshow1.png"),
              fit: BoxFit.cover,
            ),
            Image(
              image: AssetImage("assets/slideshow2.png"),
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOptions(BuildContext context) {
    return Column(
      children: [
        _homeButton(
  icon: Icons.explore,
  title: "Browse Activities",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BrowseActivitiesScreen(),
      ),
    );
  },
),

        _homeButton(
          icon: Icons.smart_toy,
          title: "Saifi Assistant",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            );
          },
        ),
        _homeButton(
          icon: Icons.event_note,
          title: "My Bookings",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _homeButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 30),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
