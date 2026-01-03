import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'login_selection_page.dart';
import '../services/orcid_service.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Research Directory'),
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
            .collection('students') // 🔥 ONLY CHANGE
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No student data available'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String orcidId = data['orcidId'] ?? '';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage:
                                (data['photoUrl'] != null &&
                                        data['photoUrl']
                                            .toString()
                                            .isNotEmpty)
                                    ? NetworkImage(data['photoUrl'])
                                    : null,
                            child: (data['photoUrl'] == null ||
                                    data['photoUrl']
                                        .toString()
                                        .isEmpty)
                                ? Text(
                                    (data['name'] ?? 'U')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${data['department'] ?? '-'} • ${data['designation'] ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Divider(),

                      /// 🔥 ORCID COUNTERS (SAME AS FACULTY)
                      orcidId.isEmpty
                          ? const Text('No ORCID linked')
                          : FutureBuilder<Map<String, dynamic>>(
                              future: OrcidService.fetchWorkCounts(orcidId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Text(
                                        'Loading publication metrics…'),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return const Text(
                                      'Publication metrics unavailable');
                                }

                                final counts = snapshot.data!;

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _metricChip(
                                        'Total',
                                        counts['total'] ?? 0),
                                    _metricChip(
                                        'Book Chapters',
                                        counts['bookChapter'] ?? 0),
                                    _metricChip(
                                        'Conferences',
                                        counts['conference'] ?? 0),
                                    _metricChip(
                                        'Patents',
                                        counts['patent'] ?? 0),
                                    _metricChip(
                                        'Books',
                                        counts['book'] ?? 0),
                                  ],
                                );
                              },
                            ),

                      const SizedBox(height: 8),

                      /// ACTION
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.menu_book),
                          label: const Text('View Details'),
                          onPressed: orcidId.isEmpty
                              ? null
                              : () => _showWorkTitles(
                                    context,
                                    data['name'] ?? 'Student',
                                    orcidId,
                                  ),
                        ),
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

  /// Metric chip
  Widget _metricChip(String label, int value) {
    return Chip(
      label: Text('$label: $value',
          style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.blue.shade50,
    );
  }

  /// SHOW PUBLICATIONS
  void _showWorkTitles(
      BuildContext context, String name, String orcidId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return PublicationBottomSheet(
          name: name,
          orcidId: orcidId,
          onViewJson: () =>
              _showRawOrcidJson(context, orcidId),
        );
      },
    );
  }

  /// DEBUG JSON
  void _showRawOrcidJson(
      BuildContext context, String orcidId) async {
    final uri =
        Uri.parse('https://pub.orcid.org/v3.0/$orcidId/works');

    final response = await http.get(
      uri,
      headers: const {
        'Accept': 'application/vnd.orcid+json'
      },
    );

    if (response.statusCode != 200) return;

    final decoded = json.decode(response.body);
    final pretty =
        const JsonEncoder.withIndent('  ').convert(decoded);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ORCID Raw JSON'),
        content: SizedBox(
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              pretty,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
class PublicationBottomSheet extends StatefulWidget {
  final String name;
  final String orcidId;
  final VoidCallback onViewJson;

  const PublicationBottomSheet({
    super.key,
    required this.name,
    required this.orcidId,
    required this.onViewJson,
  });

  @override
  State<PublicationBottomSheet> createState() =>
      _PublicationBottomSheetState();
}

class _PublicationBottomSheetState
    extends State<PublicationBottomSheet> {
  String selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.name} — Publications',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: widget.onViewJson,
                child: const Text(
                  'View ORCID JSON',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              children: [
                _chip('All', 'all'),
                _chip('Patents', 'patent'),
                _chip('Conferences', 'conference-paper'),
                _chip('Book Chapters', 'book-chapter'),
                _chip('Books', 'book'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: FutureBuilder<Map<String, List<WorkItem>>>(
              future: OrcidService.fetchGroupedWorks(widget.orcidId),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No publications found'));
                }

                final grouped = snapshot.data!;

                if (selectedType == 'all') {
                  return ListView(
                    children: grouped.entries.map((entry) {
                      if (entry.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          ...entry.value.map(_workTile),
                        ],
                      );
                    }).toList(),
                  );
                }

                final works = grouped[selectedType] ?? [];

                if (works.isEmpty) {
                  return const Center(
                      child: Text('No works found'));
                }

                return ListView(
                  children: works.map(_workTile).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedType == value,
      selectedColor: Colors.blue.shade200,
      onSelected: (_) {
        setState(() {
          selectedType = value;
        });
      },
    );
  }

  Widget _workTile(WorkItem work) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ${work.title}',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            '${work.year} • ${work.source}',
            style: const TextStyle(
                fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
