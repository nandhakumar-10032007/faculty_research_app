import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_selection_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // ---------------- Controllers ----------------
  final nameController = TextEditingController();
  final deptController = TextEditingController();
  final desigController = TextEditingController();
  final orcidController = TextEditingController();
  final scholarController = TextEditingController();
  final scopusController = TextEditingController();

  // ---------------- Image ----------------
  File? selectedImage;
  bool loading = false;

  final picker = ImagePicker();
  final supabase = Supabase.instance.client;

  // ---------------- Pick Image ----------------
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  // ---------------- Upload Image to Supabase (FIXED) ----------------
  Future<String> uploadPhotoToSupabase(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // 🔑 FIX: Convert File → bytes
    Uint8List bytes = await file.readAsBytes();

    await supabase.storage.from('faculty_photos').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // Public URL
    final imageUrl =
        supabase.storage.from('faculty_photos').getPublicUrl(fileName);

    return imageUrl;
  }

  // ---------------- Add Faculty ----------------
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

    String photoUrl = '';

    try {
      // Upload image if selected
      if (selectedImage != null) {
        photoUrl = await uploadPhotoToSupabase(selectedImage!);
      }

      // Save to Firestore
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

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ---------------- Delete Faculty ----------------
  Future<void> deleteFaculty(DocumentSnapshot doc) async {
    await doc.reference.delete();
  }

  // ---------------- Edit Faculty ----------------
  void editFaculty(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    nameController.text = data['name'] ?? '';
    deptController.text = data['department'] ?? '';
    desigController.text = data['designation'] ?? '';
    orcidController.text = data['orcidId'] ?? '';
    scholarController.text = data['scholarId'] ?? '';
    scopusController.text = data['scopusId'] ?? '';
    selectedImage = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Faculty'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field(nameController, 'Name'),
              _field(deptController, 'Department'),
              _field(desigController, 'Designation'),
              _field(orcidController, 'ORCID'),
              _field(scholarController, 'Scholar ID'),
              _field(scopusController, 'Scopus ID'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Photo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String newPhotoUrl = data['photoUrl'] ?? '';

              if (selectedImage != null) {
                newPhotoUrl =
                    await uploadPhotoToSupabase(selectedImage!);
              }

              await doc.reference.update({
                'name': nameController.text.trim(),
                'department': deptController.text.trim(),
                'designation': desigController.text.trim(),
                'orcidId': orcidController.text.trim(),
                'scholarId': scholarController.text.trim(),
                'scopusId': scopusController.text.trim(),
                'photoUrl': newPhotoUrl,
              });

              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ---------------- Clear ----------------
  void _clearForm() {
    nameController.clear();
    deptController.clear();
    desigController.clear();
    orcidController.clear();
    scholarController.clear();
    scopusController.clear();
    selectedImage = null;
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
              MaterialPageRoute(
                builder: (_) => const LoginSelectionPage(),
              ),
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
                  backgroundImage:
                      selectedImage != null ? FileImage(selectedImage!) : null,
                  child: selectedImage == null
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _field(nameController, 'Faculty Name'),
            _field(deptController, 'Department'),
            _field(desigController, 'Designation'),
            _field(orcidController, 'ORCID ID'),
            _field(scholarController, 'Google Scholar ID'),
            _field(scopusController, 'Scopus ID'),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : addFaculty,
                child: loading
                    ? const CircularProgressIndicator()
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
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No faculty added yet'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data =
                        doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              (data['photoUrl'] != null &&
                                      data['photoUrl']
                                          .toString()
                                          .startsWith('http'))
                                  ? NetworkImage(data['photoUrl'])
                                  : null,
                          child: (data['photoUrl'] == null ||
                                  data['photoUrl']
                                      .toString()
                                      .isEmpty)
                              ? Text(
                                  data['name']
                                          .toString()[0]
                                          .toUpperCase(),
                                )
                              : null,
                        ),
                        title: Text(data['name']),
                        subtitle: Text(
                          '${data['department']} • ${data['designation']}',
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) {
                            if (value == 'edit') {
                              editFaculty(doc);
                            } else if (value == 'delete') {
                              deleteFaculty(doc);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
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

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
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
