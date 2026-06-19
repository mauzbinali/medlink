enum PaymentStatus { pending, paid, refunded, failed }

class Payment {
  const Payment({
    required this.id,
    required this.appointmentId,
    required this.patientName,
    required this.doctorId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String appointmentId;
  final String patientName;
  final String doctorId;
  final int amount;
  final String method;
  final PaymentStatus status;
  final DateTime createdAt;

  Payment copyWith({PaymentStatus? status}) {
    return Payment(
      id: id,
      appointmentId: appointmentId,
      patientName: patientName,
      doctorId: doctorId,
      amount: amount,
      method: method,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

extension PaymentStatusLabel on PaymentStatus {
  String get label {
    return switch (this) {
      PaymentStatus.pending => 'Pending',
      PaymentStatus.paid => 'Paid',
      PaymentStatus.refunded => 'Refunded',
      PaymentStatus.failed => 'Failed',
    };
  }
}
