// home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required String userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
// يمكن جلب الاسم من قاعدة البيانات

  // قائمة الصفحات
  final List<Widget> _pages = [
    const HomePage(),
    const ActivitiesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar مع العنوان وأيقونة القائمة
      appBar: AppBar(
        title: const Text(
          'Saifi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3558),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFDF2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu, // أيقونة الثلاث خطوط
            color: Color(0xFF1F3558),
            size: 30,
          ),
          onPressed: () {
            // افتح القائمة الجانبية
            _openDrawer(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF1F3558),
              size: 28,
            ),
            onPressed: () {
              // الانتقال لصفحة الإشعارات
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFCFDF2),

      // محتوى الصفحة
      body: _pages[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF80C4C0),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          items: const [
            // Home
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            // Activities (في المنتصف)
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Activities',
            ),
            // Profile
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // دالة لفتح القائمة الجانبية
  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}

// صفحة الهوم الرئيسية
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ترحيب شخصي
          _buildWelcomeSection(),
          const SizedBox(height: 30),

          // بطاقة البحث
          _buildSearchCard(),
          const SizedBox(height: 30),

          // قسم التوصيات الشخصية
          _buildRecommendationsSection(),
          const SizedBox(height: 20),

          // الأنشطة المقترحة
          const Text(
            'Suggested Activities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3558),
            ),
          ),
          const SizedBox(height: 20),

          // قائمة الأنشطة
          _buildActivitiesList(),
        ],
      ),
    );
  }

  // قسم الترحيب الشخصي
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رسالة ترحيب دافئة
        Text(
          'Hello, Mohammed! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F3558),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        
        // رسالة ترحيبية لطيفة
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF80C4C0).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF80C4C0),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "I've handpicked these recommendations just for you! ✨",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF1F3558),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // بطاقة البحث
  Widget _buildSearchCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Color(0xFF80C4C0),
              size: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Search activities...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // قسم التوصيات الشخصية
  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalized For You',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3558),
          ),
        ),
        const SizedBox(height: 15),
        
        // رسالة إضافية لطيفة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF80C4C0).withOpacity(0.1),
                const Color(0xFF1F3558).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF80C4C0).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Perfect matches for your family',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F3558),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Based on your location and preferences, I've found activities that your children will love! 🎯",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // قائمة الأنشطة
  Widget _buildActivitiesList() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildActivityCard('Football', Icons.sports_soccer, 'Ages 6-12', 'Near you • 2km'),
          _buildActivityCard('Swimming', Icons.pool, 'Ages 5-10', 'Popular • 5km'),
          _buildActivityCard('Art Class', Icons.brush, 'Ages 4-8', 'Creative • 3km'),
          _buildActivityCard('Music', Icons.music_note, 'Ages 7-14', 'New • 4km'),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, IconData icon, String ageRange, String details) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF80C4C0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: const Color(0xFF80C4C0),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3558),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ageRange,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF80C4C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// صفحة الأنشطة
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Activities Page',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F3558),
        ),
      ),
    );
  }
}

// صفحة البروفايل
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F3558),
        ),
      ),
    );
  }
}