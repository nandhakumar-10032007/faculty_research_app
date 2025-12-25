import 'package:flutter/material.dart';
import '../data/faculty_data.dart';
import 'login_selection_page.dart';

class FacultyHomePage extends StatelessWidget {
  const FacultyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Faculty Page'),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginSelectionPage(),

          ),
        );
      },
    ),
  ],
),

      body: facultyList.isEmpty
          ? const Center(
              child: Text(
                'No faculty data available',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: facultyList.length,
              itemBuilder: (context, index) {
                final faculty = facultyList[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Text(
                              faculty.name.isNotEmpty
                                  ? faculty.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Center(
                          child: Text(
                            faculty.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),
                        const Divider(),

                       Text('ORCID ID: ${faculty.orcidId}'),
                        const SizedBox(height: 5),
                        Text('Google Scholar ID: ${faculty.scholarId}'),
                        const SizedBox(height: 5),
                        Text('Scopus ID: ${faculty.scopusId}'),

                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
