import '../../../../shared/models/appointment.dart';

// Appointments do not expose patient IDs, so use normalized phone when present.
List<({String name, String phone})> patientDirectory(
  List<Appointment> appointments,
) {
  final patients = <String, ({String name, String phone})>{};
  for (final appointment in appointments) {
    final phone = appointment.patientPhone.replaceAll(RegExp(r'\D'), '');
    final key = phone.isEmpty
        ? appointment.patientName.trim().toLowerCase()
        : phone;
    patients.putIfAbsent(
      key,
      () => (name: appointment.patientName, phone: appointment.patientPhone),
    );
  }
  return patients.values.toList();
}
