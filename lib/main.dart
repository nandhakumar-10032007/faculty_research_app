import 'package:flutter/material.dart';
import 'pages/login_selection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginSelectionPage(), // 👈 VERY IMPORTANT
    );
  }
}
