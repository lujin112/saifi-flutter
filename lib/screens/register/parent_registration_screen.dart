import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/theme.dart';
import '../service/api_service.dart';
import 'ChildInfoScreen.dart';

class ParentRegistrationScreen extends StatefulWidget {
  const ParentRegistrationScreen({super.key});

  @override
  State<ParentRegistrationScreen> createState() =>
      _ParentRegistrationScreenState();
}

class _ParentRegistrationScreenState extends State<ParentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<Map<String, dynamic>> _children = [];
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Parent Registration'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ✅ الصورة بالأعلى
                  Image.asset(
                    "assets/parentReg.png",
                    height: 160,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  _buildRowNames(),
                  const SizedBox(height: 15),
                  _buildPhone(),
                  const SizedBox(height: 15),
                  _buildEmail(),
                  const SizedBox(height: 15),
                  _buildPassword(),

                  const SizedBox(height: 25),
                  ShinyButton(
                    text: "Add Child",
                    onPressed: _showAddChildDialog,
                  ),
                  const SizedBox(height: 20),

                  if (_children.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_children.length, (index) {
                        final child = _children[index];

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                child['gender'] == 'Male'
                                    ? Icons.boy
                                    : Icons.girl,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${child['firstName']} ${child['lastName']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("Gender: ${child['gender']}"),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDeleteChild(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                  const SizedBox(height: 25),

                  // ✅ Checkbox + Terms & Conditions Popup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTermsDialog,
                          child: const Text.rich(
                            TextSpan(
                              text: "I have read and accept the ",
                              children: [
                                TextSpan(
                                  text: "Saifi Terms & Conditions",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ShinyButton(
  text: _isLoading ? "Creating..." : "Create Account",
  onPressed: _isLoading ? null : _registerParentAndChildren,
  child: _isLoading
      ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
      : null,
),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= COMPLETE REGISTRATION =================
 Future<void> _registerParentAndChildren() async {
  if (_isLoading) return;

  if (!_formKey.currentState!.validate()) return;

  if (!_acceptedTerms) {
    if (!mounted) return;
    _showMessage(
      context,
      "Error",
      "You must accept the Saifi Terms & Conditions.",
    );
    return;
  }

  if (_children.isEmpty) {
    if (!mounted) return;
    _showMessage(context, "Error", "Add at least one child.");
    return;
  }

  setState(() => _isLoading = true); // ✅ تشغيل اللودنق فعليًا

  try {
    final parentResult = await ApiService.registerParent(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    final parentId = parentResult["parent_id"].toString();

    final fullName =
        "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("parent_id", parentId);
    await prefs.setString("parent_name", fullName);
    await prefs.setString("role", "parent");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChildInfoScreen(children: _children),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    _showMessage(context, "Registration Failed", e.toString());
  } finally {
    if (mounted) {
      setState(() => _isLoading = false); // ✅ إيقاف اللودنق
    }
  }
}


  // ================= TERMS & CONDITIONS POPUP =================
  void _showTermsDialog() {
    const String termsText = '''
Welcome to Saifi!

By creating an account and using the Saifi platform, you agree to the following:

1. Purpose of Saifi
Saifi helps parents discover, compare, and book summer activities for their children. Saifi is a mediator between parents and activity providers, and does not directly operate or manage the activities.

2. Parent Responsibility
• You are responsible for providing accurate information about yourself and your children.
• You are responsible for reviewing activity details (location, timing, age suitability, price, risks) before booking.
• You are responsible for your child's behavior and safety outside the scope of the activity provider's premises and rules.

3. Activity Provider Responsibility
• Activity providers are solely responsible for the quality, safety, and delivery of their activities.
• Any complaints, incidents, or refunds related to the activity itself should be directed to the provider.

4. Payments & Cancellations
• Some activities may have their own payment and cancellation policies.
• It is your responsibility to read and accept those policies before confirming a booking.

5. Limitation of Liability
• Saifi is not liable for any direct or indirect damages, injuries, delays, cancellations, or disputes arising between you and any activity provider.
• Your use of the platform is at your own risk.

6. Data & Privacy
• Saifi may store your data (such as name, contact details, child profile, and booking history) to improve the service.
• Location data may be used to show activities near you and to enhance recommendations.

7. Communication
• Saifi may contact you via email, SMS, or in-app notifications for important updates, booking confirmations, and service improvements.

8. Changes to Terms
• Saifi may update these Terms & Conditions from time to time. Continued use of the platform means you accept the latest version.

By pressing "I Agree", you confirm that you have read and understood the Saifi Terms & Conditions and agree to be bound by them.
''';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Saifi Terms & Conditions"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: const Text(
              termsText,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              setState(() => _acceptedTerms = true);
              Navigator.pop(context);
            },
            child: const Text(
              "I Agree",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ADD CHILD POPUP =================
  void _showAddChildDialog() {
    final TextEditingController f = TextEditingController();
    final TextEditingController l = TextEditingController();
    String? g;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Child"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _basicField(f, "First Name"),
            const SizedBox(height: 10),
            _basicField(l, "Last Name"),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: (v) => g = v,
              decoration: const InputDecoration(labelText: "Gender"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (f.text.isNotEmpty && l.text.isNotEmpty && g != null) {
                setState(() {
                  _children.add({
                    "firstName": f.text.trim(),
                    "lastName": l.text.trim(),
                    "gender": g!,
                  });
                });

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ================= DELETE CHILD =================
  void _confirmDeleteChild(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Child"),
        content: const Text("Are you sure you want to delete this child?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _children.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _buildRowNames() {
    return Row(
      children: [
        Expanded(
          child: _basicField(_firstNameController, "First Name"),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _basicField(_lastNameController, "Last Name"),
        ),
      ],
    );
  }

  Widget _buildPhone() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: const InputDecoration(labelText: "Phone"),
      validator: (v) {
        if (v == null || v.isEmpty) return "Required";
        if (v.length != 10) return "Phone must be 10 digits";
        return null;
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: "Email"),
      validator: (v) {
        if (v == null || v.isEmpty) return "Required";

        final email = v.trim();

        if (!email.contains('@')) {
          return "Email must contain @";
        }

        if (!email.endsWith('.com')) {
          return "Email must end with .com";
        }

        return null;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? "Required" : null,
    );
  }

  Widget _basicField(TextEditingController c, String lbl,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: lbl),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
    );
  }

  void _showMessage(BuildContext context, String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }
}
