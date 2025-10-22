// club_provider_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'activity_registration_screen.dart';

class ClubProviderRegistrationScreen extends StatelessWidget {
  const ClubProviderRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF2),
      appBar: AppBar(
        title: const Text('School Registration'),
        backgroundColor: const Color(0xFF80C4C0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'School Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Commercial Registration Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Save school data then navigate to activity registration
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActivityRegistrationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF80C4C0),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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