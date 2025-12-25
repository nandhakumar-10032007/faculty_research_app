import 'package:flutter/material.dart';
import '../data/faculty_data.dart';
import 'login_selection_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final nameController = TextEditingController();
  final orcidController = TextEditingController();
  final scholarController = TextEditingController();
  final scopusController = TextEditingController();

  void addFaculty() {
    setState(() {
      facultyList.add(
        Faculty(
          name: nameController.text,
          orcidId: orcidController.text,
          scholarId: scholarController.text,
          scopusId: scopusController.text,
        ),
      );
    });

    nameController.clear();
    orcidController.clear();
    scholarController.clear();
    scopusController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginSelectionPage(),
                ),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Faculty Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: orcidController,
              decoration: const InputDecoration(
                labelText: "ORCID ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: scholarController,
              decoration: const InputDecoration(
                labelText: "Google Scholar ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: scopusController,
              decoration: const InputDecoration(
                labelText: "Scopus ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: addFaculty,
              child: const Text("Add Faculty"),
            ),
            const SizedBox(height: 25),
            const Divider(),
            const Text(
              "Added Faculties",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...facultyList.map(
              (f) => ListTile(
                title: Text(f.name),
                subtitle: Text(
                  "ORCID: ${f.orcidId}\nScholar: ${f.scholarId}\nScopus: ${f.scopusId}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
