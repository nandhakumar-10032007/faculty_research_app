import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewFdbPage extends StatelessWidget {
  const ViewFdbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View FDB"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('FDB datum')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No FDB records found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    data['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text("Faculty : ${data['facultyName'] ?? ''}"),
                      Text("Department : ${data['department'] ?? ''}"),
                      Text("Organizer : ${data['organizer'] ?? ''}"),
                      Text("Mode : ${data['mode'] ?? ''}"),
                      Text("Duration : ${data['duration'] ?? ''}"),
                      Text(
                        "Date : ${data['startDate'] ?? ''} - ${data['endDate'] ?? ''}",
                      ),
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
