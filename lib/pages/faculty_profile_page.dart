import 'dart:io';
import 'package:flutter/material.dart';

class FacultyProfilePage extends StatelessWidget {
  final File image;

  const FacultyProfilePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: FileImage(image),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dr. Sample Faculty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('ORCID ID: 0000-0002-1234-5678'),
            const Text('Google Scholar ID: scholar123'),
            const Text('Scopus ID: 987654321'),
            const Divider(height: 30),
            const Text('Publications: 25'),
            const Text('Citations: 430'),
            const Text('h-index: 12'),
          ],
        ),
      ),
    );
  }
}
