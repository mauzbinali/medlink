import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:medlink/features/admin/presentation/screens/admin_management_screen.dart';
import 'package:medlink/features/appointments/presentation/screens/appointment_booking_screen.dart';
import 'package:medlink/features/appointments/presentation/screens/appointment_detail_screen.dart';
import 'package:medlink/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:medlink/features/doctor/presentation/screens/doctor_dashboard_screen.dart';
import 'package:medlink/features/patient/presentation/screens/doctor_list_screen.dart';
import 'package:medlink/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:medlink/shared/data/sample_data.dart';
import 'package:medlink/shared/models/appointment.dart';
import 'package:medlink/shared/state/app_state.dart';
import 'package:table_calendar/table_calendar.dart';

class _Appointments extends AppController {
  _Appointments(this.date, this.type);
  final DateTime date;
  final String type;

  @override
  AppState build() {
    final initial = super.build();
    final seed = initial.appointments.first;
    return initial.copyWith(
      appointments: [
        Appointment(
          id: seed.id,
          patientName: seed.patientName,
          patientAge: seed.patientAge,
          patientGender: seed.patientGender,
          patientPhone: seed.patientPhone,
          doctorId: seed.doctorId,
          consultationType: type,
          date: date,
          timeSlot: seed.timeSlot,
          symptoms: seed.symptoms,
          notes: seed.notes,
          reportNames: seed.reportNames,
          fee: seed.fee,
          paymentMethod: seed.paymentMethod,
          paymentStatus: seed.paymentStatus,
          status: seed.status,
          createdAt: seed.createdAt,
        ),
      ],
    );
  }
}

class _RejectedSlot extends AppController {
  _RejectedSlot(this.invalidDate);
  final bool invalidDate;

  Never _reject() {
    if (invalidDate) throw ArgumentError('Choose a future time.');
    throw StateError('This slot is already booked. Choose another time.');
  }

  @override
  void bookAppointment(Appointment appointment) => _reject();

  @override
  void rescheduleAppointment({
    required String id,
    required DateTime date,
    required String timeSlot,
  }) => _reject();
}

Future<void> _show(
  WidgetTester tester,
  Widget screen, {
  Brightness brightness = Brightness.light,
  String location = '/test',
  ProviderContainer? container,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: location,
    routes: [GoRoute(path: '/test', builder: (_, _) => screen)],
  );
  addTearDown(router.dispose);
  // Use system fonts: production themes request external Inter assets.
  final app = MaterialApp.router(
    theme: ThemeData(useMaterial3: true, brightness: brightness),
    routerConfig: router,
  );
  await tester.pumpWidget(
    container == null
        ? ProviderScope(child: app)
        : UncontrolledProviderScope(container: container, child: app),
  );
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _scrollPage(WidgetTester tester) async {
  final list = find.byType(ListView).first;
  for (var i = 0; i < 7; i++) {
    await tester.drag(list, const Offset(0, -420));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  }
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final brightness in Brightness.values) {
    testWidgets('patient home phone ${brightness.name}', (tester) async {
      await _show(tester, const PatientHomeScreen(), brightness: brightness);
      expect(find.textContaining('Hello,'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _scrollPage(tester);
    });

    testWidgets('doctor dashboard phone ${brightness.name}', (tester) async {
      await _show(
        tester,
        const DoctorDashboardScreen(),
        brightness: brightness,
      );
      expect(find.text('Doctor Dashboard'), findsOneWidget);
      expect(find.text('No confirmed appointments today'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _scrollPage(tester);
    });

    testWidgets('admin dashboard phone ${brightness.name}', (tester) async {
      await _show(tester, const AdminDashboardScreen(), brightness: brightness);
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _scrollPage(tester);
    });
  }

  testWidgets('specialty query actually filters doctors', (tester) async {
    await _show(
      tester,
      const DoctorListScreen(),
      location: '/test?specialty=Cardiologist',
    );
    expect(find.text('1 doctors match your search'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('online booking query selects online mode', (tester) async {
    await _show(
      tester,
      AppointmentBookingScreen(doctorId: SampleData.doctors.first.id),
      location: '/test?type=online',
    );
    final control = tester.widget<SegmentedButton<String>>(
      find.byType(SegmentedButton<String>),
    );
    expect(control.selected, {'Online Consultation'});
    final calendar = tester.widget<TableCalendar<void>>(
      find.byType(TableCalendar<void>),
    );
    expect(calendar.firstDay.hour, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('confirmed clinic appointment has no call control', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appControllerProvider.overrideWith(
          () => _Appointments(
            DateTime.now().add(const Duration(days: 1)),
            'Clinic Visit',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _show(tester, const MyAppointmentsScreen(), container: container);
    expect(find.text('Join Call'), findsNothing);
    expect(find.text('Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('old appointment reschedule opens in bounds and scrolls', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appControllerProvider.overrideWith(
          () => _Appointments(DateTime(2020), 'Clinic Visit'),
        ),
      ],
    );
    addTearDown(container.dispose);
    await _show(
      tester,
      const AppointmentDetailScreen(appointmentId: 'apt-seed-1'),
      container: container,
    );
    await tester.scrollUntilVisible(find.text('Reschedule'), 350);
    await tester.tap(find.text('Reschedule'));
    await tester.pumpAndSettle();
    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(DateUtils.isSameDay(picker.initialDate, DateTime.now()), isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('admin patient search is functional', (tester) async {
    await _show(tester, const AdminManagementScreen(type: 'users'));
    await tester.enterText(find.byType(TextField), 'Nobody');
    await tester.pump();
    expect(find.text('Ali Raza'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Ali');
    await tester.pump();
    expect(find.text('Ali Raza'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final invalidDate in [false, true]) {
    final message = invalidDate
        ? 'Choose a future time.'
        : 'This slot is already booked. Choose another time.';
    testWidgets(
      'booking displays ${invalidDate ? 'date' : 'conflict'} errors',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            appControllerProvider.overrideWith(
              () => _RejectedSlot(invalidDate),
            ),
          ],
        );
        addTearDown(container.dispose);
        await _show(
          tester,
          AppointmentBookingScreen(doctorId: SampleData.doctors.first.id),
          container: container,
        );
        await tester.scrollUntilVisible(
          find.text('Confirm Booking'),
          500,
          scrollable: find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(find.text('Confirm Booking'));
        await tester.pump(const Duration(seconds: 2));
        expect(find.text(message), findsOneWidget);
        expect(find.text('Booking request sent'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 2));
      },
    );

    testWidgets(
      'reschedule displays ${invalidDate ? 'date' : 'conflict'} errors',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            appControllerProvider.overrideWith(
              () => _RejectedSlot(invalidDate),
            ),
          ],
        );
        addTearDown(container.dispose);
        await _show(
          tester,
          const AppointmentDetailScreen(appointmentId: 'apt-seed-1'),
          container: container,
        );
        await tester.scrollUntilVisible(find.text('Reschedule'), 350);
        await tester.tap(find.text('Reschedule'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Save New Slot'));
        await tester.tap(find.text('Save New Slot'));
        await tester.pump();
        expect(find.text(message), findsOneWidget);
        expect(find.byType(CalendarDatePicker), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
