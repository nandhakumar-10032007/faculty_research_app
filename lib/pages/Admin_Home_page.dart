import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// Ensure this path matches your project structure
import 'login_selection_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // ---------------- TEXT CONTROLLERS ----------------
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final desigController = TextEditingController();
  final orcidController = TextEditingController();
  final scholarController = TextEditingController();
  final scopusController = TextEditingController();

  // ---------------- IMAGE PICKER ----------------
  File? selectedImage;
  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // ---------------- ADD FACULTY ----------------
  Future<void> addFaculty() async {
    if (nameController.text.isEmpty ||
        deptController.text.isEmpty ||
        desigController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill required fields')),
      );
      return;
    }

    setState(() => loading = true);

    String? photoUrl;

    try {
      // 1. Upload photo to Firebase Storage
      if (selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('faculty_photos')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(selectedImage!);
        photoUrl = await ref.getDownloadURL();
      }

      // 2. Save data to Firestore
      await FirebaseFirestore.instance.collection('faculties').add({
        'name': nameController.text.trim(),
        'department': deptController.text.trim(),
        'designation': desigController.text.trim(),
        'orcidId': orcidController.text.trim(),
        'scholarId': scholarController.text.trim(),
        'scopusId': scopusController.text.trim(),
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Clear form
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _clearForm() {
    nameController.clear();
    deptController.clear();
    desigController.clear();
    orcidController.clear();
    scholarController.clear();
    scopusController.clear();
    setState(() => selectedImage = null);
  }

  // ---------------- DELETE FACULTY (Includes Storage Cleanup) ----------------
  Future<void> _deleteFaculty(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final String? photoUrl = data['photoUrl'];

      // Delete image from storage first
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(photoUrl).delete();
      }

      // Delete Firestore document
      await doc.reference.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginSelectionPage()),
              (_) => false,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage:
                      selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _field(nameController, 'Faculty Name'),
            _field(deptController, 'Department'),
            _field(desigController, 'Designation'),
            _field(orcidController, 'ORCID ID'),
            _field(scholarController, 'Google Scholar ID'),
            _field(scopusController, 'Scopus ID'),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : addFaculty,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add Faculty'),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text(
              'Faculty List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faculties')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No faculty added yet'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: data['photoUrl'] != null
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child: data['photoUrl'] == null
                              ? Text(data['name'][0])
                              : null,
                        ),
                        title: Text(data['name'] ?? 'N/A'),
                        subtitle: Text(
                          '${data['department']} • ${data['designation']}',
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'delete') _deleteFaculty(doc);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPER WIDGETS ----------------
  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    deptController.dispose();
    desigController.dispose();
    orcidController.dispose();
    scholarController.dispose();
    scopusController.dispose();
    super.dispose();
  }
}
