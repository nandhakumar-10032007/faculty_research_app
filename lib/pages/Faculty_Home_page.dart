import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'faculty_profile_page.dart';

class DemoAddFacultyPage extends StatefulWidget {
  const DemoAddFacultyPage({super.key});

  @override
  State<DemoAddFacultyPage> createState() => _DemoAddFacultyPageState();
}

class _DemoAddFacultyPageState extends State<DemoAddFacultyPage> {
  File? selectedImage;

  final TextEditingController orcidController = TextEditingController();
  final TextEditingController scholarController = TextEditingController();
  final TextEditingController scopusController = TextEditingController();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Faculty (Demo)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: orcidController,
              decoration: const InputDecoration(
                labelText: 'ORCID ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: scholarController,
              decoration: const InputDecoration(
                labelText: 'Google Scholar ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: scopusController,
              decoration: const InputDecoration(
                labelText: 'Scopus ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacultyProfilePage(
                      image: selectedImage,
                      orcidId: orcidController.text,
                      scholarId: scholarController.text,
                      scopusId: scopusController.text,
                    ),
                  ),
                );
              },
              child: const Text('View Faculty Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
