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

  Future<void> adminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      loading = true;
      errorText = '';
    });

    try {
      // 🔐 Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 📦 Firestore admin check (IMPORTANT FIX)
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins') // ✅ correct collection
          .doc(uid)
          .get();

      if (!adminDoc.exists) {
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'You are not an admin',
        );
      }

      // ✅ SUCCESS → Admin Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      print("LOGIN ERROR CODE: ${e.code}");
      print("LOGIN ERROR MESSAGE: ${e.message}");

      setState(() {
        errorText = e.message ?? 'Login failed';
      });
    } catch (e) {
      print("UNKNOWN ERROR: $e");
      setState(() {
        errorText = 'Something went wrong';
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
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Admin Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : adminLogin,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
            if (errorText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                errorText,
                style: const TextStyle(color: Colors.red),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
