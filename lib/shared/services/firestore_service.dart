import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/appointment.dart';
import '../models/doctor_approval_status.dart';
import '../models/medical_record.dart';
import '../models/payment.dart';
import '../models/prescription.dart';
import '../models/review.dart';

class FirestoreService {
  // ignore: prefer_initializing_formals
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Future<void> saveAppointment(Appointment appointment) async {
    if (!isAvailable) return;
    await _db.collection('appointments').doc(appointment.id).set({
      'appointmentId': appointment.id,
      'patientName': appointment.patientName,
      'patientAge': appointment.patientAge,
      'patientGender': appointment.patientGender,
      'patientPhone': appointment.patientPhone,
      'doctorId': appointment.doctorId,
      'consultationType': appointment.consultationType,
      'date': Timestamp.fromDate(appointment.date),
      'timeSlot': appointment.timeSlot,
      'status': appointment.status.name,
      'symptoms': appointment.symptoms,
      'notes': appointment.notes,
      'reportUrls': appointment.reportNames,
      'fee': appointment.fee,
      'paymentStatus': appointment.paymentStatus,
      'paymentMethod': appointment.paymentMethod,
      'createdAt': Timestamp.fromDate(appointment.createdAt),
    });
  }

  Future<void> savePrescription(Prescription prescription) async {
    if (!isAvailable) return;
    await _db.collection('prescriptions').doc(prescription.id).set({
      'prescriptionId': prescription.id,
      'appointmentId': prescription.appointmentId,
      'doctorId': prescription.doctorId,
      'patientName': prescription.patientName,
      'diagnosis': prescription.diagnosis,
      'medicines': prescription.medicines
          .map(
            (medicine) => {
              'name': medicine.name,
              'dosage': medicine.dosage,
              'frequency': medicine.frequency,
              'duration': medicine.duration,
              'instructions': medicine.instructions,
            },
          )
          .toList(),
      'instructions': prescription.instructions,
      'followUpDate': Timestamp.fromDate(prescription.followUpDate),
      'createdAt': Timestamp.fromDate(prescription.createdAt),
    });
  }

  Future<void> saveMedicalRecord(MedicalRecord record) async {
    if (!isAvailable) return;
    await _db.collection('medical_records').doc(record.id).set({
      'recordId': record.id,
      'title': record.title,
      'type': record.type,
      'fileUrl': record.fileName,
      'notes': record.notes,
      'createdAt': Timestamp.fromDate(record.createdAt),
    });
  }

  Future<void> saveReview(Review review) async {
    if (!isAvailable) return;
    await _db.collection('reviews').doc(review.id).set({
      'reviewId': review.id,
      'doctorId': review.doctorId,
      'appointmentId': review.appointmentId,
      'rating': review.rating,
      'comment': review.comment,
      'createdAt': Timestamp.fromDate(review.createdAt),
    });
  }

  Future<void> savePayment(Payment payment) async {
    if (!isAvailable) return;
    await _db.collection('payments').doc(payment.id).set({
      'paymentId': payment.id,
      'appointmentId': payment.appointmentId,
      'patientName': payment.patientName,
      'doctorId': payment.doctorId,
      'amount': payment.amount,
      'method': payment.method,
      'status': payment.status.name,
      'createdAt': Timestamp.fromDate(payment.createdAt),
    });
  }

  Future<void> saveDoctorStatus({
    required String doctorId,
    required DoctorApprovalStatus status,
  }) async {
    if (!isAvailable) return;
    await _db.collection('doctors').doc(doctorId).set({
      'doctorId': doctorId,
      'isApproved': status == DoctorApprovalStatus.approved,
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
