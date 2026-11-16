import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medlink/shared/models/app_notification.dart';
import 'package:medlink/shared/models/appointment.dart';
import 'package:medlink/shared/models/doctor.dart';
import 'package:medlink/shared/models/medicine.dart';
import 'package:medlink/shared/models/payment.dart';
import 'package:medlink/shared/models/prescription.dart';
import 'package:medlink/shared/services/messaging_service.dart';
import 'package:medlink/shared/services/notification_service.dart';
import 'package:medlink/shared/services/prescription_pdf_service.dart';
import 'package:medlink/shared/services/receipt_pdf_service.dart';
import 'package:medlink/shared/services/storage_service.dart';

const _doctor = Doctor(
  id: 'doctor-1',
  name: 'Demo Doctor',
  specialty: 'General Physician',
  qualification: 'MBBS',
  experienceYears: 5,
  fee: 1000,
  rating: 4.5,
  reviewsCount: 2,
  clinicName: 'Demo Clinic',
  clinicAddress: 'Demo Address',
  availability: 'Weekdays',
  imageUrl: '',
  distanceKm: 1,
  isOnlineAvailable: false,
  about: '',
  languages: ['English'],
  services: ['Consultation'],
);

Appointment _appointment({String doctorId = 'doctor-1'}) => Appointment(
  id: 'appointment-1',
  patientName: 'Demo Patient',
  patientAge: 30,
  patientGender: 'Other',
  patientPhone: '+920000000000',
  doctorId: doctorId,
  consultationType: 'Clinic Visit',
  date: DateTime(2027, 1, 2),
  timeSlot: '10:00 AM',
  symptoms: 'Demo symptoms',
  notes: 'Demo notes',
  reportNames: const ['report.jpg'],
  fee: 1000,
  paymentMethod: 'Card',
  paymentStatus: 'Pending',
  status: AppointmentStatus.pending,
  createdAt: DateTime(2027, 1, 1),
);

Prescription _prescription({int count = 1, String doctorId = 'doctor-1'}) =>
    Prescription(
      id: 'prescription-1',
      appointmentId: 'appointment-1',
      doctorId: doctorId,
      patientName: 'Demo Patient',
      diagnosis: 'Demo diagnosis',
      medicines: List.generate(
        count,
        (index) => Medicine(
          name: 'Demo medicine $index',
          dosage: 'Demo dosage',
          frequency: 'Demo frequency',
          duration: 'Demo duration',
          instructions: 'Individual instructions $index',
        ),
      ),
      instructions: 'General demo instructions',
      followUpDate: DateTime(2027, 1, 9),
      createdAt: DateTime(2027, 1, 2),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('appointment copy preserves fields when payment status is omitted', () {
    final original = _appointment();
    final copy = original.copyWith(status: AppointmentStatus.confirmed);
    expect(copy.paymentStatus, 'Pending');
    expect(copy.id, original.id);
    expect(copy.patientName, original.patientName);
    expect(copy.patientAge, original.patientAge);
    expect(copy.patientGender, original.patientGender);
    expect(copy.patientPhone, original.patientPhone);
    expect(copy.doctorId, original.doctorId);
    expect(copy.consultationType, original.consultationType);
    expect(copy.symptoms, original.symptoms);
    expect(copy.notes, original.notes);
    expect(copy.reportNames, original.reportNames);
    expect(copy.fee, original.fee);
    expect(copy.paymentMethod, original.paymentMethod);
    expect(copy.createdAt, original.createdAt);
    expect(copy.date, original.date);
    expect(copy.timeSlot, original.timeSlot);
    expect(original.status, AppointmentStatus.pending);
  });

  test(
    'appointment copy coordinates status and payment without mutating source',
    () {
      final original = _appointment().copyWith(paymentStatus: 'Paid');
      final cancelled = original.copyWith(
        status: AppointmentStatus.cancelled,
        paymentStatus: 'Refunded',
      );
      expect(cancelled.status, AppointmentStatus.cancelled);
      expect(cancelled.paymentStatus, 'Refunded');
      expect(original.paymentStatus, 'Paid');
      final rescheduled = original.copyWith(
        date: DateTime(2027, 1, 3),
        timeSlot: '11:00 AM',
      );
      expect(rescheduled.date, DateTime(2027, 1, 3));
      expect(rescheduled.timeSlot, '11:00 AM');
      expect(rescheduled.paymentStatus, 'Paid');
    },
  );

  test('payment and notification copies preserve source values', () {
    final createdAt = DateTime(2027);
    final payment = Payment(
      id: 'payment-1',
      appointmentId: 'appointment-1',
      patientName: 'Demo Patient',
      doctorId: 'doctor-1',
      amount: 1000,
      method: 'Card',
      status: PaymentStatus.pending,
      createdAt: createdAt,
    );
    expect(payment.copyWith().status, PaymentStatus.pending);
    final failed = payment.copyWith(status: PaymentStatus.failed);
    expect(failed.status, PaymentStatus.failed);
    expect(failed.amount, payment.amount);
    expect(failed.appointmentId, payment.appointmentId);
    expect(failed.createdAt, createdAt);
    expect(payment.status, PaymentStatus.pending);
    final notification = AppNotification(
      id: 'notification-1',
      title: 'Title',
      body: 'Body',
      type: 'appointment',
      isRead: false,
      createdAt: createdAt,
    );
    final read = notification.copyWith(isRead: true);
    expect(read.isRead, isTrue);
    expect(read.title, notification.title);
    expect(read.body, notification.body);
    expect(read.createdAt, createdAt);
    expect(notification.isRead, isFalse);
  });

  test('long prescription generates multiple PDF pages', () async {
    final bytes = await PrescriptionPdfService.build(
      doctor: _doctor,
      prescription: _prescription(count: 80),
    );
    final pdf = latin1.decode(bytes);
    expect(pdf, startsWith('%PDF-'));
    expect(RegExp(r'/Type\s*/Page\b').allMatches(pdf).length, greaterThan(1));
  });

  test('receipt generates a PDF for matching doctor', () async {
    final bytes = await ReceiptPdfService.build(
      doctor: _doctor,
      appointment: _appointment(),
    );
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
  });

  test(
    'PDFs reject a mismatched doctor instead of misattributing records',
    () async {
      await expectLater(
        PrescriptionPdfService.build(
          doctor: _doctor,
          prescription: _prescription(doctorId: 'another-doctor'),
        ),
        throwsArgumentError,
      );
      await expectLater(
        ReceiptPdfService.build(
          doctor: _doctor,
          appointment: _appointment(doctorId: 'another-doctor'),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'upload rejects paths outside the intended user/file segments',
    () async {
      final storage = StorageService();
      for (final value in ['', ' ', '.', '..', 'a/b', r'a\b']) {
        await expectLater(
          storage.uploadMedicalFile(
            userId: value,
            file: File('unused.jpg'),
            fileName: 'report.jpg',
          ),
          throwsArgumentError,
        );
        await expectLater(
          storage.uploadMedicalFile(
            userId: 'user-1',
            file: File('unused.jpg'),
            fileName: value,
          ),
          throwsArgumentError,
        );
      }
    },
  );

  test('Firebase-less services leave valid demo calls unavailable', () async {
    expect(await MessagingService().initialize(), isNull);
    expect(
      await StorageService().uploadMedicalFile(
        userId: 'user-1',
        file: File('unused.jpg'),
        fileName: 'report.jpg',
      ),
      isNull,
    );
  });

  test('local notifications skip unsupported desktop targets', () async {
    for (final platform in [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      final notifications = NotificationService();
      expect(notifications.isSupported, isFalse);
      await notifications.initialize();
      await notifications.showLocal(id: 1, title: 'Title', body: 'Body');
    }
  });

  test('Android local notifications request runtime permission', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    final calls = <String>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final notifications = NotificationService();
    await notifications.initialize();
    expect(
      calls,
      containsAllInOrder(['initialize', 'requestNotificationsPermission']),
    );
  });
}
