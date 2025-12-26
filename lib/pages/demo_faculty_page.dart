import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DemoFacultyPage extends StatefulWidget {
  const DemoFacultyPage({super.key});

  @override
  State<DemoFacultyPage> createState() => _DemoFacultyPageState();
}

class _DemoFacultyPageState extends State<DemoFacultyPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController orcidController = TextEditingController();

  File? selectedImage; // 🖼️ Selected profile image

  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Demo Faculty Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Preview
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  selectedImage != null ? FileImage(selectedImage!) : null,
              child: selectedImage == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Profile Image"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Faculty Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: designationController,
              decoration: const InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: orcidController,
              decoration: const InputDecoration(
                labelText: 'ORCID ID',
                hintText: '0000-0000-0000-0000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                print("Name: ${nameController.text}");
                print("Department: ${departmentController.text}");
                print("Designation: ${designationController.text}");
                print("ORCID: ${orcidController.text}");
                print("Image selected: ${selectedImage != null}");
              },
              child: const Text('Create Faculty Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
