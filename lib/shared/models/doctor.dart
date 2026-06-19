class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.experienceYears,
    required this.fee,
    required this.rating,
    required this.reviewsCount,
    required this.clinicName,
    required this.clinicAddress,
    required this.availability,
    required this.imageUrl,
    required this.distanceKm,
    required this.isOnlineAvailable,
    required this.about,
    required this.languages,
    required this.services,
  });

  final String id;
  final String name;
  final String specialty;
  final String qualification;
  final int experienceYears;
  final int fee;
  final double rating;
  final int reviewsCount;
  final String clinicName;
  final String clinicAddress;
  final String availability;
  final String imageUrl;
  final double distanceKm;
  final bool isOnlineAvailable;
  final String about;
  final List<String> languages;
  final List<String> services;
}
