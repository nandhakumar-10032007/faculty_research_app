import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'faculty_home_page.dart';

class FacultyLoginPage extends StatefulWidget {
  const FacultyLoginPage({super.key});

  @override
  State<FacultyLoginPage> createState() => _FacultyLoginPageState();
}

class _FacultyLoginPageState extends State<FacultyLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String errorText = '';
  bool loading = false;

  bool isCollegeEmail(String email) {
    return email.endsWith('@citchennai.net'); // 🔴 CHANGE DOMAIN HERE
  }

  Future<void> facultyLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (!isCollegeEmail(email)) {
    setState(() {
      errorText = 'Use college email only';
    });
    return;
  }

  setState(() {
    loading = true;
    errorText = '';
  });

  try {
    // 🔐 Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    // 📦 Read Firestore role
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      throw 'User role not found';
    }

    final role = userDoc['role'];

    if (role != 'faculty') {
      throw 'Not a faculty account';
    }

    // ✅ SUCCESS → Faculty Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FacultyHomePage()),
    );
  } catch (e) {
    setState(() {
      errorText = 'Invalid faculty login';
    });
  } finally {
    setState(() {
      loading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faculty Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Faculty Email",
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
              onPressed: loading ? null : facultyLogin,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
            if (errorText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(errorText, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
