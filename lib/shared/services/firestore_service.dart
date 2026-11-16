import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in before saving records.');
    return user.uid;
  }

  Future<Map<String, dynamic>> _appointmentOwners(String appointmentId) async {
    final snapshot = await _db
        .collection('appointments')
        .doc(appointmentId)
        .get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    if (data == null ||
        data['patientId'] is! String ||
        data['doctorUid'] is! String) {
      throw StateError('Appointment has no trusted ownership.');
    }
    return {
      'patientId': data['patientId'],
      'doctorId': data['doctorId'],
      'doctorUid': data['doctorUid'],
    };
  }

  Future<void> saveAppointment(Appointment appointment) async {
    if (!isAvailable) return;
    final uid = _uid;
    final document = _db.collection('appointments').doc(appointment.id);
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(document);
      if (existing.exists) {
        // Updating as a doctor/admin must not replace the original patient.
        transaction.update(document, {
          'date': Timestamp.fromDate(appointment.date),
          'timeSlot': appointment.timeSlot,
          'status': appointment.status.name,
          'paymentStatus': appointment.paymentStatus,
        });
        return;
      }
      // Catalog doctor IDs are not Firebase UIDs; binding is admin-managed.
      final doctor = await transaction.get(
        _db.collection('doctors').doc(appointment.doctorId),
      );
      final ownerUid = doctor.data()?['ownerUid'];
      if (ownerUid is! String ||
          ownerUid.isEmpty ||
          doctor.data()?['isApproved'] != true) {
        throw StateError('Doctor needs a provisioned, approved account.');
      }
      transaction.set(document, {
        'patientId': uid,
        'doctorUid': ownerUid,
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
    });
  }

  Future<void> savePrescription(Prescription prescription) async {
    if (!isAvailable) return;
    final owners = await _appointmentOwners(prescription.appointmentId);
    await _db.collection('prescriptions').doc(prescription.id).set({
      ...owners,
      'prescriptionId': prescription.id,
      'appointmentId': prescription.appointmentId,
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
      'patientId': _uid,
      'recordId': record.id,
      'title': record.title,
      'type': record.type,
      'fileUrl': record.fileName,
      'notes': record.notes,
      'createdAt': Timestamp.fromDate(record.createdAt),
    });
  }

  Future<void> deleteMedicalRecord(String id) async {
    if (!isAvailable) return;
    await _db.collection('medical_records').doc(id).delete();
  }

  Future<void> saveReview(Review review) async {
    if (!isAvailable) return;
    final owners = await _appointmentOwners(review.appointmentId);
    await _db.collection('reviews').doc(review.id).set({
      ...owners,
      'reviewId': review.id,
      'appointmentId': review.appointmentId,
      'rating': review.rating,
      'comment': review.comment,
      'createdAt': Timestamp.fromDate(review.createdAt),
    });
  }

  Future<void> savePayment(Payment payment) async {
    if (!isAvailable) return;
    final owners = await _appointmentOwners(payment.appointmentId);
    await _db.collection('payments').doc(payment.id).set({
      ...owners,
      'paymentId': payment.id,
      'appointmentId': payment.appointmentId,
      'patientName': payment.patientName,
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
