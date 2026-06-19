import 'medicine.dart';

class Prescription {
  const Prescription({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.patientName,
    required this.diagnosis,
    required this.medicines,
    required this.instructions,
    required this.followUpDate,
    required this.createdAt,
  });

  final String id;
  final String appointmentId;
  final String doctorId;
  final String patientName;
  final String diagnosis;
  final List<Medicine> medicines;
  final String instructions;
  final DateTime followUpDate;
  final DateTime createdAt;
}
