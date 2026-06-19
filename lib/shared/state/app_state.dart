import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_data.dart';
import '../models/app_notification.dart';
import '../models/appointment.dart';
import '../models/chat_message.dart';
import '../models/doctor_approval_status.dart';
import '../models/health_tip.dart';
import '../models/medical_record.dart';
import '../models/medicine.dart';
import '../models/payment.dart';
import '../models/prescription.dart';
import '../models/review.dart';
import '../services/service_providers.dart';

class AppState {
  const AppState({
    required this.appointments,
    required this.prescriptions,
    required this.medicalRecords,
    required this.reviews,
    required this.favoriteDoctorIds,
    required this.notifications,
    required this.healthTips,
    required this.payments,
    required this.chatMessages,
    required this.doctorStatuses,
  });

  final List<Appointment> appointments;
  final List<Prescription> prescriptions;
  final List<MedicalRecord> medicalRecords;
  final List<Review> reviews;
  final Set<String> favoriteDoctorIds;
  final List<AppNotification> notifications;
  final List<HealthTip> healthTips;
  final List<Payment> payments;
  final List<ChatMessage> chatMessages;
  final Map<String, DoctorApprovalStatus> doctorStatuses;

  AppState copyWith({
    List<Appointment>? appointments,
    List<Prescription>? prescriptions,
    List<MedicalRecord>? medicalRecords,
    List<Review>? reviews,
    Set<String>? favoriteDoctorIds,
    List<AppNotification>? notifications,
    List<HealthTip>? healthTips,
    List<Payment>? payments,
    List<ChatMessage>? chatMessages,
    Map<String, DoctorApprovalStatus>? doctorStatuses,
  }) {
    return AppState(
      appointments: appointments ?? this.appointments,
      prescriptions: prescriptions ?? this.prescriptions,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      reviews: reviews ?? this.reviews,
      favoriteDoctorIds: favoriteDoctorIds ?? this.favoriteDoctorIds,
      notifications: notifications ?? this.notifications,
      healthTips: healthTips ?? this.healthTips,
      payments: payments ?? this.payments,
      chatMessages: chatMessages ?? this.chatMessages,
      doctorStatuses: doctorStatuses ?? this.doctorStatuses,
    );
  }
}

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);

class AppController extends Notifier<AppState> {
  final _uuid = const Uuid();

  @override
  AppState build() {
    final now = DateTime.now();
    final doctor = SampleData.doctors.first;
    final appointment = Appointment(
      id: 'apt-seed-1',
      patientName: 'Ali Raza',
      patientAge: 29,
      patientGender: 'Male',
      patientPhone: '+92 300 1234567',
      doctorId: doctor.id,
      consultationType: 'Online Consultation',
      date: now.add(const Duration(days: 1)),
      timeSlot: '10:00 AM',
      symptoms: 'Fever and body ache',
      notes: 'Fever started yesterday night.',
      reportNames: const ['cbc-report.pdf'],
      fee: doctor.fee,
      paymentMethod: 'EasyPaisa',
      paymentStatus: 'Paid',
      status: AppointmentStatus.confirmed,
      createdAt: now.subtract(const Duration(hours: 3)),
    );
    final payment = Payment(
      id: 'pay-seed-1',
      appointmentId: appointment.id,
      patientName: appointment.patientName,
      doctorId: appointment.doctorId,
      amount: appointment.fee,
      method: appointment.paymentMethod,
      status: PaymentStatus.paid,
      createdAt: appointment.createdAt,
    );

    return AppState(
      appointments: [appointment],
      prescriptions: [
        Prescription(
          id: 'rx-seed-1',
          appointmentId: appointment.id,
          doctorId: doctor.id,
          patientName: appointment.patientName,
          diagnosis: 'Viral fever with mild dehydration',
          medicines: const [
            Medicine(
              name: 'Panadol 500mg',
              dosage: '1 tablet',
              frequency: 'Twice a day',
              duration: '5 days',
              instructions: 'After meal',
            ),
          ],
          instructions: 'Drink fluids, rest, and return if fever persists.',
          followUpDate: now.add(const Duration(days: 7)),
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ],
      medicalRecords: [
        MedicalRecord(
          id: 'record-seed-1',
          title: 'CBC Blood Test',
          type: 'Blood Test',
          fileName: 'cbc-report.pdf',
          notes: 'Uploaded before consultation.',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ],
      reviews: const [],
      favoriteDoctorIds: {doctor.id},
      notifications: [
        AppNotification(
          id: 'notif-seed-1',
          title: 'Appointment confirmed',
          body: '${doctor.name} confirmed your online consultation.',
          type: 'appointment_confirmed',
          isRead: false,
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
      ],
      healthTips: SampleData.healthTips,
      payments: [payment],
      chatMessages: [
        ChatMessage(
          id: 'chat-seed-1',
          appointmentId: appointment.id,
          sender: ChatSender.clinic,
          message:
              'Your appointment is confirmed. Please keep your reports ready before the call.',
          createdAt: now.subtract(const Duration(minutes: 25)),
        ),
      ],
      doctorStatuses: {
        for (final doctor in SampleData.doctors)
          doctor.id: DoctorApprovalStatus.approved,
        SampleData.doctors.last.id: DoctorApprovalStatus.pending,
      },
    );
  }

  void bookAppointment(Appointment appointment) {
    final payment = Payment(
      id: _uuid.v4(),
      appointmentId: appointment.id,
      patientName: appointment.patientName,
      doctorId: appointment.doctorId,
      amount: appointment.fee,
      method: appointment.paymentMethod,
      status: appointment.paymentStatus == 'Paid'
          ? PaymentStatus.paid
          : PaymentStatus.pending,
      createdAt: DateTime.now(),
    );
    _safePersist(
      ref.read(firestoreServiceProvider).saveAppointment(appointment),
    );
    _safePersist(ref.read(firestoreServiceProvider).savePayment(payment));
    state = state.copyWith(
      appointments: [appointment, ...state.appointments],
      payments: [payment, ...state.payments],
      chatMessages: [
        ChatMessage(
          id: _uuid.v4(),
          appointmentId: appointment.id,
          sender: ChatSender.clinic,
          message:
              'Booking received. The clinic will confirm your slot shortly.',
          createdAt: DateTime.now(),
        ),
        ...state.chatMessages,
      ],
      notifications: [
        _notification(
          title: 'Appointment booked',
          body:
              'Your ${appointment.consultationType.toLowerCase()} is pending.',
          type: 'appointment_booked',
        ),
        _notification(
          title: 'Reminder scheduled',
          body: 'We will remind you before ${appointment.timeSlot}.',
          type: 'appointment_reminder_scheduled',
        ),
        ...state.notifications,
      ],
    );
  }

  Appointment createAppointment({
    required String patientName,
    required int patientAge,
    required String patientGender,
    required String patientPhone,
    required String doctorId,
    required String consultationType,
    required DateTime date,
    required String timeSlot,
    required String symptoms,
    required String notes,
    required List<String> reportNames,
    required int fee,
    required String paymentMethod,
  }) {
    return Appointment(
      id: _uuid.v4(),
      patientName: patientName,
      patientAge: patientAge,
      patientGender: patientGender,
      patientPhone: patientPhone,
      doctorId: doctorId,
      consultationType: consultationType,
      date: date,
      timeSlot: timeSlot,
      symptoms: symptoms,
      notes: notes,
      reportNames: reportNames,
      fee: fee,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'Cash at Clinic' ? 'Unpaid' : 'Paid',
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  void updateAppointmentStatus(String id, AppointmentStatus status) {
    if (!state.appointments.any((appointment) => appointment.id == id)) {
      return;
    }
    final updated = [
      for (final appointment in state.appointments)
        if (appointment.id == id)
          appointment.copyWith(status: status)
        else
          appointment,
    ];
    final changed = updated.firstWhere((appointment) => appointment.id == id);
    _safePersist(ref.read(firestoreServiceProvider).saveAppointment(changed));
    final shouldRefund =
        status == AppointmentStatus.cancelled ||
        status == AppointmentStatus.rejected;
    final updatedPayments = shouldRefund
        ? [
            for (final payment in state.payments)
              if (payment.appointmentId == id)
                payment.copyWith(status: PaymentStatus.refunded)
              else
                payment,
          ]
        : state.payments;
    if (shouldRefund) {
      for (final payment in updatedPayments.where(
        (payment) => payment.appointmentId == id,
      )) {
        _safePersist(ref.read(firestoreServiceProvider).savePayment(payment));
      }
    }
    state = state.copyWith(
      appointments: updated,
      payments: updatedPayments,
      notifications: [
        _notification(
          title: 'Appointment ${status.label.toLowerCase()}',
          body: 'Your appointment status changed to ${status.label}.',
          type: 'appointment_${status.name}',
        ),
        ...state.notifications,
      ],
    );
  }

  void rescheduleAppointment({
    required String id,
    required DateTime date,
    required String timeSlot,
  }) {
    if (!state.appointments.any((appointment) => appointment.id == id)) {
      return;
    }
    final updated = [
      for (final appointment in state.appointments)
        if (appointment.id == id)
          appointment.copyWith(date: date, timeSlot: timeSlot)
        else
          appointment,
    ];
    final changed = updated.firstWhere((appointment) => appointment.id == id);
    _safePersist(ref.read(firestoreServiceProvider).saveAppointment(changed));
    state = state.copyWith(
      appointments: updated,
      notifications: [
        _notification(
          title: 'Appointment rescheduled',
          body: 'Your appointment moved to $timeSlot.',
          type: 'appointment_rescheduled',
        ),
        ...state.notifications,
      ],
    );
  }

  void toggleFavorite(String doctorId) {
    final favorites = {...state.favoriteDoctorIds};
    favorites.contains(doctorId)
        ? favorites.remove(doctorId)
        : favorites.add(doctorId);
    state = state.copyWith(favoriteDoctorIds: favorites);
  }

  void addReview({
    required String doctorId,
    required String appointmentId,
    required double rating,
    required String comment,
  }) {
    final review = Review(
      id: _uuid.v4(),
      doctorId: doctorId,
      appointmentId: appointmentId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _safePersist(ref.read(firestoreServiceProvider).saveReview(review));
    state = state.copyWith(reviews: [review, ...state.reviews]);
  }

  void addMedicalRecord({
    required String title,
    required String type,
    required String fileName,
    required String notes,
  }) {
    final record = MedicalRecord(
      id: _uuid.v4(),
      title: title,
      type: type,
      fileName: fileName,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _safePersist(ref.read(firestoreServiceProvider).saveMedicalRecord(record));
    state = state.copyWith(medicalRecords: [record, ...state.medicalRecords]);
  }

  void deleteMedicalRecord(String id) {
    state = state.copyWith(
      medicalRecords: [
        for (final record in state.medicalRecords)
          if (record.id != id) record,
      ],
    );
  }

  void createPrescription(String appointmentId) {
    createPrescriptionWithDetails(
      appointmentId: appointmentId,
      diagnosis: 'Seasonal infection',
      medicines: const [
        Medicine(
          name: 'Panadol 500mg',
          dosage: '1 tablet',
          frequency: 'Twice daily',
          duration: '5 days',
          instructions: 'After meal',
        ),
        Medicine(
          name: 'ORS',
          dosage: '1 sachet',
          frequency: 'Once daily',
          duration: '3 days',
          instructions: 'Mix with clean water',
        ),
      ],
      instructions: 'Rest, hydrate, and avoid cold drinks.',
      followUpDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  void createPrescriptionWithDetails({
    required String appointmentId,
    required String diagnosis,
    required List<Medicine> medicines,
    required String instructions,
    required DateTime followUpDate,
  }) {
    final appointmentMatches = state.appointments.where(
      (item) => item.id == appointmentId,
    );
    if (appointmentMatches.isEmpty) return;
    final appointment = appointmentMatches.first;
    final prescription = Prescription(
      id: _uuid.v4(),
      appointmentId: appointment.id,
      doctorId: appointment.doctorId,
      patientName: appointment.patientName,
      diagnosis: diagnosis,
      medicines: medicines,
      instructions: instructions,
      followUpDate: followUpDate,
      createdAt: DateTime.now(),
    );
    _safePersist(
      ref.read(firestoreServiceProvider).savePrescription(prescription),
    );
    state = state.copyWith(
      prescriptions: [prescription, ...state.prescriptions],
      notifications: [
        _notification(
          title: 'Prescription available',
          body: 'Your doctor has shared a new prescription.',
          type: 'prescription_available',
        ),
        ...state.notifications,
      ],
    );
  }

  void markAllNotificationsRead() {
    state = state.copyWith(
      notifications: [
        for (final notification in state.notifications)
          notification.copyWith(isRead: true),
      ],
    );
  }

  void addHealthTip({
    required String title,
    required String category,
    required String shortDescription,
    required String content,
  }) {
    state = state.copyWith(
      healthTips: [
        HealthTip(
          id: _uuid.v4(),
          title: title,
          category: category,
          shortDescription: shortDescription,
          content: content,
        ),
        ...state.healthTips,
      ],
    );
  }

  void deleteHealthTip(String id) {
    state = state.copyWith(
      healthTips: [
        for (final tip in state.healthTips)
          if (tip.id != id) tip,
      ],
    );
  }

  void sendChatMessage({
    required String appointmentId,
    required ChatSender sender,
    required String message,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      chatMessages: [
        ChatMessage(
          id: _uuid.v4(),
          appointmentId: appointmentId,
          sender: sender,
          message: trimmed,
          createdAt: DateTime.now(),
        ),
        ...state.chatMessages,
      ],
    );
  }

  void updateDoctorStatus({
    required String doctorId,
    required DoctorApprovalStatus status,
  }) {
    final statuses = {...state.doctorStatuses, doctorId: status};
    _safePersist(
      ref
          .read(firestoreServiceProvider)
          .saveDoctorStatus(doctorId: doctorId, status: status),
    );
    state = state.copyWith(
      doctorStatuses: statuses,
      notifications: [
        _notification(
          title: 'Doctor ${status.label.toLowerCase()}',
          body: 'Admin changed doctor status to ${status.label}.',
          type: 'doctor_status_${status.name}',
        ),
        ...state.notifications,
      ],
    );
  }

  AppNotification _notification({
    required String title,
    required String body,
    required String type,
  }) {
    return AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
    );
  }

  void _safePersist(Future<void> operation) {
    unawaited(operation.catchError((_) {}));
  }
}
