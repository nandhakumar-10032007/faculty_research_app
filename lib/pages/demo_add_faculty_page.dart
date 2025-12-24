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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            ElevatedButton(
              onPressed: selectedImage == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FacultyProfilePage(image: selectedImage!),
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
