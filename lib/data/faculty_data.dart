class Faculty {
  final String id;
  final String name;
  final String department;
  final String designation;
  final String orcidId;
  final String scholarId;
  final String scopusId;

  Faculty({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.orcidId,
    required this.scholarId,
    required this.scopusId,
  });

  factory Faculty.fromFirestore(String id, Map<String, dynamic> data) {
    return Faculty(
      id: id,
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      designation: data['designation'] ?? '',
      orcidId: data['orcidId'] ?? '',
      scholarId: data['scholarId'] ?? '',
      scopusId: data['scopusId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'designation': designation,
      'orcidId': orcidId,
      'scholarId': scholarId,
      'scopusId': scopusId,
      'createdAt': DateTime.now(),
    };
  }
}
