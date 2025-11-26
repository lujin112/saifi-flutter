import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RadioListTile(
              value: "English",
              groupValue: _selectedLanguage,
              activeColor: Colors.teal,
              title: const Text("English"),
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
              },
            ),

            RadioListTile(
              value: "Arabic",
              groupValue: _selectedLanguage,
              activeColor: Colors.teal,
              title: const Text("Arabic"),
              onChanged: (value) {
                setState(() => _selectedLanguage = value.toString());
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Save",
                style: TextStyle(fontSize: 16),
              ),
            )
            
          ],
        ),
      ),
    );
  }
}
