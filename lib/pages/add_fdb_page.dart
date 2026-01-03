import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFdbPage extends StatefulWidget {
  const AddFdbPage({super.key});

  @override
  State<AddFdbPage> createState() => _AddFdbPageState();
}

class _AddFdbPageState extends State<AddFdbPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController organizerController = TextEditingController();
  final TextEditingController modeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController certificateUrlController =
      TextEditingController();

  // TEMP (later replace with logged-in faculty data)
  final String facultyId = "giveid";
  final String facultyName = "Muthupandi G";
  final String department = "CSE";

  bool loading = false;

  Future<void> saveFDB() async {
    setState(() {
      loading = true;
    });

    await _firestore.collection('FDB datum').add({
      'title': titleController.text.trim(),
      'organizer': organizerController.text.trim(),
      'mode': modeController.text.trim(),
      'duration': durationController.text.trim(),
      'startDate': startDateController.text.trim(),
      'endDate': endDateController.text.trim(),
      'certificateUrl': certificateUrlController.text.trim(),

      'facultyId': facultyId,
      'facultyName': facultyName,
      'department': department,

      'type': 'FDB',
      'createdBy': facultyName,
      'createdAt': DateTime.now().toString(),
      'updatedAt': DateTime.now().toString(),
    });

    setState(() {
      loading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add FDB"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "FDB Title"),
            ),
            TextField(
              controller: organizerController,
              decoration: const InputDecoration(labelText: "Organizer"),
            ),
            TextField(
              controller: modeController,
              decoration: const InputDecoration(labelText: "Mode (Online/Offline)"),
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: "Duration"),
            ),
            TextField(
              controller: startDateController,
              decoration: const InputDecoration(labelText: "Start Date"),
            ),
            TextField(
              controller: endDateController,
              decoration: const InputDecoration(labelText: "End Date"),
            ),
            TextField(
              controller: certificateUrlController,
              decoration: const InputDecoration(labelText: "Certificate URL"),
            ),
            const SizedBox(height: 24),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: saveFDB,
                    child: const Text("Save FDB"),
                  ),
          ],
        ),
      ),
    );
  }
}
