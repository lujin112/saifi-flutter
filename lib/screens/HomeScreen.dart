import 'package:flutter/material.dart';
import 'role_selection_screen.dart'; // لازم تستوردها عشان نرجع لها

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isArabic = false; // ✅ لحفظ اللغة

  final List<Widget> _pages = [
    const HomePage(),
    const ChatbotPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saifi',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3558),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFDF2),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color(0xFF1F3558),
                size: 30,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // ✅ يفتح القائمة
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF1F3558),
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFCFDF2),

      // ✅ Drawer جانبي
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF80C4C0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF80C4C0)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hello, ${widget.userName}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),

            // ✅ Switch Mode عربي / English
            SwitchListTile(
              title: Text(_isArabic ? "العربية" : "English"),
              value: _isArabic,
              onChanged: (value) {
                setState(() {
                  _isArabic = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isArabic
                        ? "تم التبديل للعربية"
                        : "Switched to English"),
                  ),
                );
              },
              secondary: const Icon(Icons.language),
            ),

            // ✅ Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log out"),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RoleSelectionScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF80C4C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ✅ Chatbot و HomePage و ProfilePage نفس الكود اللي قبل
class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Chatbot Page"));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Home Page"));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Profile Page"));
  }
}
