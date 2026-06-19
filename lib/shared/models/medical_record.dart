class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.fileName,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String type;
  final String fileName;
  final String notes;
  final DateTime createdAt;
}
