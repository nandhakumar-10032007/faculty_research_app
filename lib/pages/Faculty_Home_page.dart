import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_selection_page.dart';

class FacultyHomePage extends StatelessWidget {
  const FacultyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginSelectionPage(),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faculties')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No faculty data available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// PHOTO
                      Center(
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: data['photoUrl'] != null
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child: data['photoUrl'] == null
                              ? Text(
                                  data['name'][0],
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// NAME
                      Center(
                        child: Text(
                          data['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// DEPT + DESIGNATION
                      Center(
                        child: Text(
                          '${data['department']} • ${data['designation']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 15),
                      const Divider(),

                      /// IDS
                      Text('ORCID ID: ${data['orcidId'] ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('Google Scholar ID: ${data['scholarId'] ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('Scopus ID: ${data['scopusId'] ?? '-'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
