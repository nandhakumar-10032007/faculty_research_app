import 'package:flutter/material.dart';
import 'admin_login_page.dart';
import 'faculty_login_page.dart';

class LoginSelectionPage extends StatelessWidget {
  const LoginSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminLoginPage(),
                  ),
                );
              },
              child: const Text('Admin Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacultyLoginPage(),
                  ),
                );
              },
              child: const Text('Faculty Login'),
            ),
          ],
        ),
      ),
    );
  }
}
