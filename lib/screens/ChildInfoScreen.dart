import 'package:flutter/material.dart';
import 'location_selection_screen.dart';

class ChildInfoScreen extends StatelessWidget {
  final List<Map<String, dynamic>> children;

  const ChildInfoScreen({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('Child Information'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Children Information & Interests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F3558),
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView.builder(
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // معلومات الطفل الأساسية
                          Row(
                            children: [
                              const Icon(Icons.child_care, color: Color(0xFF80C4C0)),
                              const SizedBox(width: 10),
                              Text(
                                '${child['firstName']} ${child['lastName']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F3558),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Age: ${child['age']} years',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // الاهتمامات
                          const Text(
                            'Select Interests:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Sports Interests
                          _buildInterestSection(
                            title: 'Sports',
                            interests: ['Football', 'Tennis', 'Paddle', 'Basketball', 'Swimming', 'Volleyball'],
                          ),
                          const SizedBox(height: 15),
                          
                          // Languages Interests
                          _buildInterestSection(
                            title: 'Languages', 
                            interests: ['English', 'French', 'Chinese', 'Spanish', 'Arabic'],
                          ),
                          const SizedBox(height: 15),
                          
                          // Self-defense Interests
                          _buildInterestSection(
                            title: 'Self-defense',
                            interests: ['Karate', 'Taekwondo', 'Judo', 'Kung Fu', 'Boxing', 'Aikido'],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _saveAndNavigateToLocation(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80C4C0),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save & Continue to Location',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء قسم الاهتمامات
  Widget _buildInterestSection({required String title, required List<String> interests}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F3558),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((interest) {
            return FilterChip(
              label: Text(interest),
              selected: false,
              onSelected: (bool selected) {
                // هنا يمكن إضافة منطق لحفظ الاهتمامات المختارة
              },
              selectedColor: const Color(0xFF80C4C0),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ],
    );
  }

  void _saveAndNavigateToLocation(BuildContext context) {
    // حفظ المعلومات ثم الانتقال لصفحة الموقع
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Children information and interests have been saved successfully!'),
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الرسالة
                // الانتقال لصفحة الموقع
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationSelectionScreen(),
                  ),
                );
              },
              child: const Text('Continue to Location'),
            ),
          ],
        );
      },
    );
  }
}