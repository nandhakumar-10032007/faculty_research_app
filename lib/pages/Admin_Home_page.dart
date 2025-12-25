import 'dart:io';
import 'package:flutter/material.dart';

class FacultyProfilePage extends StatelessWidget {
  final File? image;
  final String orcidId;
  final String scholarId;
  final String scopusId;

  const FacultyProfilePage({
    super.key,
    this.image,
    required this.orcidId,
    required this.scholarId,
    required this.scopusId,
  });

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
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  image != null ? FileImage(image!) : null,
              child: image == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 20),

            const Text(
              'Dr. Sample Faculty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text('ORCID ID: $orcidId'),
            Text('Google Scholar ID: $scholarId'),
            Text('Scopus ID: $scopusId'),

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
