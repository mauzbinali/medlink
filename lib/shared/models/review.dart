class Review {
  const Review({
    required this.id,
    required this.doctorId,
    required this.appointmentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String doctorId;
  final String appointmentId;
  final double rating;
  final String comment;
  final DateTime createdAt;
}
