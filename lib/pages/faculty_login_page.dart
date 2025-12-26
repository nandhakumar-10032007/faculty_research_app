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

  bool loading = false;
  String errorText = '';

  bool isCollegeEmail(String email) {
    return email.endsWith('@citchennai.net');
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

    if (password.length < 6) {
      setState(() {
        errorText = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      loading = true;
      errorText = '';
    });

    try {
      // 🔐 Try login
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _goToFacultyHome(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      // 👤 If user not found → REGISTER automatically
      if (e.code == 'user-not-found') {
        try {
          UserCredential newUser =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(newUser.user!.uid)
              .set({
            'email': email,
            'role': 'faculty',
            'createdAt': Timestamp.now(),
          });

          await _goToFacultyHome(newUser.user!.uid);
        } catch (e) {
          setState(() {
            errorText = 'Account creation failed';
          });
        }
      } else {
        setState(() {
          errorText = e.message ?? 'Login failed';
        });
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _goToFacultyHome(String uid) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FacultyHomePage()),
    );
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
