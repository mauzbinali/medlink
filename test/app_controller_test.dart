import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medlink/shared/models/appointment.dart';
import 'package:medlink/shared/models/payment.dart';
import 'package:medlink/shared/services/firestore_service.dart';
import 'package:medlink/shared/services/service_providers.dart';
import 'package:medlink/shared/state/app_state.dart';

void main() {
  late ProviderContainer container;
  late AppController controller;

  setUp(() {
    container = ProviderContainer();
    controller = container.read(appControllerProvider.notifier);
  });
  tearDown(() => container.dispose());

  Appointment booking({String paymentMethod = 'Card', DateTime? date}) {
    return controller.createAppointment(
      patientName: 'Test Patient',
      patientAge: 30,
      patientGender: 'Other',
      patientPhone: '+923001234567',
      doctorId: 'doctor-test',
      consultationType: 'Clinic Visit',
      date: date ?? DateTime.now().add(const Duration(days: 2)),
      timeSlot: '10:00 AM',
      symptoms: 'Test symptoms',
      notes: '',
      reportNames: [],
      fee: 1000,
      paymentMethod: paymentMethod,
    );
  }

  test('online method selection does not claim payment was collected', () {
    final appointment = booking();
    controller.bookAppointment(appointment);
    expect(appointment.paymentStatus, 'Pending');
    expect(
      container.read(appControllerProvider).payments.first.status,
      PaymentStatus.pending,
    );
  });

  test('duplicate appointment and overlapping slot are rejected', () {
    final appointment = booking();
    controller.bookAppointment(appointment);
    expect(() => controller.bookAppointment(appointment), throwsStateError);
    expect(() => controller.bookAppointment(booking()), throwsStateError);
    expect(container.read(appControllerProvider).appointments.length, 2);
  });

  test('past booking date is rejected', () {
    expect(
      () => controller.bookAppointment(
        booking(date: DateTime.now().subtract(const Duration(days: 1))),
      ),
      throwsArgumentError,
    );
  });

  test('invalid slot text is rejected', () {
    final appointment = booking();
    expect(
      () => controller.bookAppointment(
        appointment.copyWith(timeSlot: 'not-a-time'),
      ),
      throwsArgumentError,
    );
  });

  test('elapsed time today is rejected', () {
    final now = DateTime.now();
    final appointment = booking(date: DateTime(now.year, now.month, now.day));
    expect(
      () => controller.bookAppointment(
        appointment.copyWith(timeSlot: '12:00 AM'),
      ),
      throwsArgumentError,
    );
  });

  test('cancelling unpaid appointment does not create a refund', () {
    final appointment = booking(paymentMethod: 'Cash at Clinic');
    controller.bookAppointment(appointment);
    controller.updateAppointmentStatus(
      appointment.id,
      AppointmentStatus.cancelled,
    );
    final state = container.read(appControllerProvider);
    expect(state.payments.first.status, PaymentStatus.failed);
    expect(state.appointments.first.paymentStatus, 'Cancelled');
    controller.updateAppointmentStatus(
      appointment.id,
      AppointmentStatus.confirmed,
    );
    expect(
      container.read(appControllerProvider).appointments.first.status,
      AppointmentStatus.cancelled,
    );
  });

  test('paid seed booking refund updates receipt status as well', () {
    controller.updateAppointmentStatus(
      'apt-seed-1',
      AppointmentStatus.cancelled,
    );
    final state = container.read(appControllerProvider);
    expect(state.payments.first.status, PaymentStatus.refunded);
    expect(state.appointments.first.paymentStatus, 'Refunded');
  });

  test('rescheduling requires confirmation and detects slot conflicts', () {
    final appointment = booking();
    controller.bookAppointment(appointment);
    controller.updateAppointmentStatus(
      appointment.id,
      AppointmentStatus.confirmed,
    );
    controller.rescheduleAppointment(
      id: appointment.id,
      date: appointment.date,
      timeSlot: '11:00 AM',
    );
    expect(
      container.read(appControllerProvider).appointments.first.status,
      AppointmentStatus.pending,
    );
    controller.bookAppointment(booking());
    expect(
      () => controller.rescheduleAppointment(
        id: appointment.id,
        date: appointment.date,
        timeSlot: '10:00 AM',
      ),
      throwsStateError,
    );
  });

  test('only completed appointments can receive one valid review', () {
    final appointment = booking();
    controller.bookAppointment(appointment);
    void review(double rating) => controller.addReview(
      doctorId: appointment.doctorId,
      appointmentId: appointment.id,
      rating: rating,
      comment: 'Good visit',
    );
    review(5);
    expect(container.read(appControllerProvider).reviews, isEmpty);
    controller.updateAppointmentStatus(
      appointment.id,
      AppointmentStatus.confirmed,
    );
    controller.updateAppointmentStatus(
      appointment.id,
      AppointmentStatus.completed,
    );
    review(double.nan);
    review(6);
    expect(container.read(appControllerProvider).reviews, isEmpty);
    review(5);
    review(4);
    expect(container.read(appControllerProvider).reviews.length, 1);
  });

  test('payment persistence waits for appointment persistence', () async {
    final service = _RecordingFirestore();
    container.dispose();
    container = ProviderContainer(
      overrides: [firestoreServiceProvider.overrideWithValue(service)],
    );
    controller = container.read(appControllerProvider.notifier);
    controller.bookAppointment(booking());
    await Future<void>.delayed(Duration.zero);
    expect(service.calls, ['appointment', 'payment']);
  });

  test(
    'failed persistence is visible and does not save orphan payment',
    () async {
      final service = _RecordingFirestore(failAppointment: true);
      container.dispose();
      container = ProviderContainer(
        overrides: [firestoreServiceProvider.overrideWithValue(service)],
      );
      controller = container.read(appControllerProvider.notifier);
      controller.bookAppointment(booking());
      await Future<void>.delayed(Duration.zero);
      expect(service.calls, ['appointment']);
      expect(
        container.read(appControllerProvider).notifications.first.type,
        'sync_error',
      );
    },
  );
}

class _RecordingFirestore extends FirestoreService {
  _RecordingFirestore({this.failAppointment = false});
  final bool failAppointment;
  final calls = <String>[];

  @override
  Future<void> saveAppointment(Appointment appointment) async {
    await Future<void>.delayed(Duration.zero);
    calls.add('appointment');
    if (failAppointment) throw StateError('Offline');
  }

  @override
  Future<void> savePayment(Payment payment) async {
    calls.add('payment');
  }
}
