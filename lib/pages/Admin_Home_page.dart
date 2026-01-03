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

  // ⭐ NEW: destination selector
  String destination = 'faculty'; // faculty | student

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

  // ---------------- Upload Image to Supabase ----------------
  Future<String> uploadPhotoToSupabase(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Uint8List bytes = await file.readAsBytes();

    await supabase.storage.from('faculty_photos').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return supabase.storage.from('faculty_photos').getPublicUrl(fileName);
  }

  // ---------------- Add Faculty / Student ----------------
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
      if (selectedImage != null) {
        photoUrl = await uploadPhotoToSupabase(selectedImage!);
      }

      final data = {
        'name': nameController.text.trim(),
        'department': deptController.text.trim(),
        'designation': desigController.text.trim(),
        'orcidId': orcidController.text.trim(),
        'scholarId': scholarController.text.trim(),
        'scopusId': scopusController.text.trim(),
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // ⭐ SAVE BASED ON DESTINATION
      final collectionName =
          destination == 'faculty' ? 'faculties' : 'students';

      await FirebaseFirestore.instance
          .collection(collectionName)
          .add(data);

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            destination == 'faculty'
                ? 'Faculty added successfully'
                : 'Student added successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ---------------- Delete ----------------
 Future<void> deleteFaculty(DocumentSnapshot doc) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete this record?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await doc.reference.delete();
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

  // ---------------Edit---------------------
  void showEditDialog(DocumentSnapshot doc) {
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
      title: const Text('Edit Details'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ PHOTO EDIT (FIXED)
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!) as ImageProvider
                    : (data['photoUrl'] != null &&
                            data['photoUrl'].toString().startsWith('http'))
                        ? NetworkImage(data['photoUrl']) as ImageProvider
                        : null,
                child: selectedImage == null &&
                        (data['photoUrl'] == null ||
                            data['photoUrl'].toString().isEmpty)
                    ? const Icon(Icons.camera_alt)
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            _field(nameController, 'Name'),
            _field(deptController, 'Department'),
            _field(desigController, 'Designation'),
            _field(orcidController, 'ORCID ID'),
            _field(scholarController, 'Scholar ID'),
            _field(scopusController, 'Scopus ID'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _clearForm();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            String photoUrl = data['photoUrl'] ?? '';

            // upload new image only if selected
            if (selectedImage != null) {
              photoUrl = await uploadPhotoToSupabase(selectedImage!);
            }

            await doc.reference.update({
              'name': nameController.text.trim(),
              'department': deptController.text.trim(),
              'designation': desigController.text.trim(),
              'orcidId': orcidController.text.trim(),
              'scholarId': scholarController.text.trim(),
              'scopusId': scopusController.text.trim(),
              'photoUrl': photoUrl,
            });

            Navigator.pop(context);
            _clearForm();
          },
          child: const Text('Save'),
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
    final activeCollection =
        destination == 'faculty' ? 'faculties' : 'students';

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
            // ⭐ DESTINATION SELECTOR
            Row(
              children: [
                const Text(
                  'Destination:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Radio<String>(
                  value: 'faculty',
                  groupValue: destination,
                  onChanged: (v) => setState(() => destination = v!),
                ),
                const Text('Faculty'),
                Radio<String>(
                  value: 'student',
                  groupValue: destination,
                  onChanged: (v) => setState(() => destination = v!),
                ),
                const Text('Student'),
              ],
            ),

            const SizedBox(height: 10),

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
            _field(nameController, destination == 'faculty'
                ? 'Faculty Name'
                : 'Student Name'),
            _field(deptController, 'Department'),
            _field(desigController, destination == 'faculty'
                ? 'Designation'
                : 'Designation'),
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
                    : Text(destination == 'faculty'
                        ? 'Add Faculty'
                        : 'Add Student'),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),

            Text(
              destination == 'faculty'
                  ? 'Faculty List'
                  : 'Student List',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ DYNAMIC LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(activeCollection)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      destination == 'faculty'
                          ? 'No faculty added yet'
                          : 'No students added yet',
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;

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
                                  data['photoUrl'].toString().isEmpty)
                              ? Text(
                                  (data['name'] ?? 'U').toString()[0].toUpperCase(),
                                )

                              : null,
                        ),
                       title: Text(data['name'] ?? 'No Name'),
                        subtitle: Text(
                         '${data['department'] ?? 'N/A'} • ${data['designation'] ?? 'N/A'}',
                        ),

                         trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                             if (value == 'edit') {
                                if (value == 'edit') {
                                      showEditDialog(doc);
                                }

                             } else if (value == 'delete') {
                             deleteFaculty(doc);
                             }
                           },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                  child: Text('Edit'),
                              ),
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
