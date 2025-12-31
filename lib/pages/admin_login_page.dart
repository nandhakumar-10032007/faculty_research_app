import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_home_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String errorText = '';
  bool loading = false;

  // 🔐 Logic preserved exactly as provided
  Future<void> adminLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  setState(() {
    loading = true;
    errorText = '';
  });

  try {
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();

    if (!adminDoc.exists) {
      throw FirebaseAuthException(
        code: 'not-admin',
        message: 'You are not authorized as admin',
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomePage()),
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      errorText = e.message ?? 'Login failed';
    });
  } finally {
    setState(() {
      loading = false;
    });
  }
}


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark, secure background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Admin-Specific Branding
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Administrator",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const Text(
              "Access high-level system controls",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 50),

            // Email Field
            _buildAdminField(
              controller: _emailController,
              label: 'Admin Email',
              icon: Icons.security_rounded,
              hint: 'admin@system.com',
            ),
            const SizedBox(height: 20),

            // Password Field
            _buildAdminField(
              controller: _passwordController,
              label: 'Secret Key',
              icon: Icons.vpn_key_rounded,
              isPassword: true,
              hint: '••••••••',
            ),

            // Error Display
            if (errorText.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Text(
                  errorText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 40),

            // Secure Login Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : adminLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'VERIFY & ENTER',
                        style: TextStyle(
                          fontSize: 16,
                         fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.amber.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.amber, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
