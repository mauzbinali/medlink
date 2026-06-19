enum AppointmentStatus { pending, confirmed, rejected, cancelled, completed }

class Appointment {
  const Appointment({
    required this.id,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientPhone,
    required this.doctorId,
    required this.consultationType,
    required this.date,
    required this.timeSlot,
    required this.symptoms,
    required this.notes,
    required this.reportNames,
    required this.fee,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String patientPhone;
  final String doctorId;
  final String consultationType;
  final DateTime date;
  final String timeSlot;
  final String symptoms;
  final String notes;
  final List<String> reportNames;
  final int fee;
  final String paymentMethod;
  final String paymentStatus;
  final AppointmentStatus status;
  final DateTime createdAt;

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? date,
    String? timeSlot,
  }) {
    return Appointment(
      id: id,
      patientName: patientName,
      patientAge: patientAge,
      patientGender: patientGender,
      patientPhone: patientPhone,
      doctorId: doctorId,
      consultationType: consultationType,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      symptoms: symptoms,
      notes: notes,
      reportNames: reportNames,
      fee: fee,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

extension AppointmentStatusLabel on AppointmentStatus {
  String get label {
    return switch (this) {
      AppointmentStatus.pending => 'Pending',
      AppointmentStatus.confirmed => 'Confirmed',
      AppointmentStatus.rejected => 'Rejected',
      AppointmentStatus.cancelled => 'Cancelled',
      AppointmentStatus.completed => 'Completed',
    };
  }
}
