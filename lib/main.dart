import 'package:flutter/material.dart';
import 'pages/demo_add_faculty_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Faculty Research App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
     home: const DemoAddFacultyPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Research App'),
        centerTitle: true,
      ),
    );
  }
}
