import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'role_selection_screen.dart';
import 'chatbot_screen.dart';
import 'theme.dart';
import 'activity_details_page.dart';
import 'ChildInfoScreen.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isArabic = false;
  bool _isExpanded = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userName: widget.userName),
      const ChatbotScreen(),
      ProfilePage(),
    ];
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
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.textDark, size: 30),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 28),
                onPressed: () {},
              ),
            ],
          ),

          drawer: Drawer(
            backgroundColor: AppColors.background,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFF64AFAA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Saifi Menu',
                      style: TextStyle(
                        fontFamily: 'RobotoMono',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text("العربية", style: TextStyle(fontFamily: 'RobotoMono')),
                  value: _isArabic,
                  onChanged: (val) => setState(() => _isArabic = val),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.primary),
                  title: const Text('Log out', style: TextStyle(fontFamily: 'RobotoMono')),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),

          body: _pages[_currentIndex],

          // ======================= تم استبدال الناف بار =======================
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

                // ---------------- LEFT SIDE ----------------
                Row(
                  children: [
                    _navItem(
                      label: "Home",
                      icon: Icons.home,
                      isSelected: _currentIndex == 0,
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                          _isExpanded = false;
                        });
                      },
                    ),

                    if (_isExpanded)
                      _navItem(
                        label: "Chatbot",
                        icon: Icons.chat_bubble,
                        isSelected: _currentIndex == 1,
                        onTap: () {
                          setState(() {
                            _currentIndex = 1;
                            _isExpanded = false;
                          });
                        },
                      ),
                  ],
                ),

                // ----------- PLUS BUTTON ----------
                GestureDetector(
                  onTap: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // ---------------- RIGHT SIDE ----------------
                Row(
                  children: [
                    if (_isExpanded)
                      _navItem(
                        label: "Add Kid",
                        icon: Icons.child_care,
                        isSelected: false,
                        onTap: () {
                          setState(() => _isExpanded = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChildInfoScreen(children: []),
                            ),
                          );
                        },
                      ),

                    _navItem(
                      label: "Profile",
                      icon: Icons.person,
                      isSelected: _currentIndex == 2,
                      onTap: () {
                        setState(() {
                          _currentIndex = 2;
                          _isExpanded = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== nav item helper =====================
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
            Icon(icon,
                size: 26,
                color: isSelected ? AppColors.primary : Colors.grey),
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

// ======================== HOME PAGE ===========================
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
          const SizedBox(height: 30),
          _buildSearchCard(),
          const SizedBox(height: 30),
          _buildRecommendationsSection(),
          const SizedBox(height: 30),
          const Text(
            'Suggested Activities',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          _buildActivitiesList(context),
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
          child: Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "I've handpicked these recommendations just for you! ✨",
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primary, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search activities...',
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            Colors.white.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 22),
        const SizedBox(width: 8),

        // أهم تعديل
        Expanded(
          child: const Text(
            'Perfect matches for your family',
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),

    const SizedBox(height: 8),

    const Text(
      "Based on your preferences, I’ve found activities that your children will love! 🎯",
      style: TextStyle(
        fontFamily: 'RobotoMono',
        fontSize: 14,
        color: Colors.grey,
        height: 1.5,
      ),
    ),
  ],
),

    );
  }

  Widget _buildActivitiesList(BuildContext context) {
    return SizedBox(
      height: 210,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('providers').snapshots(),
        builder: (context, providerSnapshot) {
          if (providerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!providerSnapshot.hasData || providerSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No providers found",
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
              ),
            );
          }

          final providers = providerSnapshot.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchAllActivities(providers),
            builder: (context, activitySnapshot) {
              if (!activitySnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final activities = activitySnapshot.data!;

              if (activities.isEmpty) {
                return const Center(
                  child: Text(
                    "No activities available",
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activities.length,
                itemBuilder: (context, i) {
                  final data = activities[i];

                  return _buildActivityCard(
                    data['title'] ?? 'No Title',
                    data,
                    context,
                    
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllActivities(
      List<QueryDocumentSnapshot> providers) async {
    List<Map<String, dynamic>> all = [];

    for (var provider in providers) {
      final actSnapshot = await provider.reference.collection('activities').get();

      for (var a in actSnapshot.docs) {
        all.add(a.data());
      }
    }

    return all;
  }

  Widget _buildActivityCard(
    String title, Map<String, dynamic> fullData, BuildContext context) {

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ActivityDetailsPage(
            data: fullData,
            activityId: fullData["activity_id"] ?? "",
          ),
        ),
      );
    },
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 5,
        shadowColor: AppColors.primary.withOpacity(0.25),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_activity_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
