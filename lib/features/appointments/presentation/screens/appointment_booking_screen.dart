import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/animated_page_list.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({required this.doctorId, super.key});

  final String doctorId;

  @override
  ConsumerState<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends ConsumerState<AppointmentBookingScreen> {
  DateTime selectedDay = DateTime.now();
  String consultationType = 'Clinic Visit';
  String selectedSlot = '10:00 AM';
  String paymentMethod = 'Cash at Clinic';
  String gender = 'Male';
  String? formError;
  final selectedReportNames = <String>{};

  final nameController = TextEditingController(text: 'Ali Raza');
  final ageController = TextEditingController(text: '29');
  final phoneController = TextEditingController(text: '+92 300 1234567');
  final symptomsController = TextEditingController(text: 'Fever and body ache');
  final notesController = TextEditingController();

  final slots = const [
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
    '6:30 PM',
    '7:00 PM',
  ];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    symptomsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = SampleData.doctors.where(
      (doctor) => doctor.id == widget.doctorId,
    );
    if (matches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Book Appointment',
          fallbackRoute: AppRoutes.doctors,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.profile_delete,
          title: 'Doctor not found',
          message: 'Choose another doctor to continue booking.',
        ),
      );
    }
    final doctor = matches.first;
    final records = ref.watch(appControllerProvider).medicalRecords;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Book Appointment',
        fallbackRoute: AppRoutes.doctors,
      ),
      body: AnimatedPageList(
        children: [
          Text(
            doctor.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(4),
          Text('${doctor.specialty} | Rs.${doctor.fee}'),
          const Gap(20),
          _Block(
            title: 'Consultation Type',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Clinic Visit',
                  label: Text('Clinic'),
                  icon: Icon(Iconsax.hospital),
                ),
                ButtonSegment(
                  value: 'Online Consultation',
                  label: Text('Online'),
                  icon: Icon(Iconsax.video),
                ),
              ],
              selected: {consultationType},
              onSelectionChanged: (value) {
                setState(() => consultationType = value.first);
              },
            ),
          ),
          _Block(
            title: 'Select Date',
            child: TableCalendar<void>(
              focusedDay: selectedDay,
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 60)),
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              onDaySelected: (selected, focused) {
                setState(() => selectedDay = selected);
              },
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          _Block(
            title: 'Select Time Slot',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final selected = selectedSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedSlot = slot),
                );
              }).toList(),
            ),
          ),
          _Block(
            title: 'Patient Details',
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Patient Name'),
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: gender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) => setState(() => gender = value!),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const Gap(12),
                TextField(
                  controller: symptomsController,
                  decoration: const InputDecoration(labelText: 'Symptoms'),
                ),
                const Gap(12),
                TextField(
                  controller: notesController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          _Block(
            title: 'Attach Reports',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (records.isEmpty)
                  const Text('No medical records uploaded yet.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: records.map((record) {
                      final selected = selectedReportNames.contains(
                        record.fileName,
                      );
                      return FilterChip(
                        label: Text(record.title),
                        selected: selected,
                        avatar: const Icon(Iconsax.document, size: 16),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              selectedReportNames.add(record.fileName);
                            } else {
                              selectedReportNames.remove(record.fileName);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                const Gap(12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(
                      () => selectedReportNames.add('uploaded-report.pdf'),
                    );
                  },
                  icon: const Icon(Iconsax.document_upload),
                  label: const Text('Add sample report'),
                ),
              ],
            ),
          ),
          _Block(
            title: 'Payment Method',
            child: DropdownButtonFormField<String>(
              initialValue: paymentMethod,
              items: const [
                DropdownMenuItem(
                  value: 'Cash at Clinic',
                  child: Text('Cash at Clinic'),
                ),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
                DropdownMenuItem(value: 'EasyPaisa', child: Text('EasyPaisa')),
                DropdownMenuItem(value: 'JazzCash', child: Text('JazzCash')),
              ],
              onChanged: (value) => setState(() => paymentMethod = value!),
            ),
          ),
          if (formError != null) ...[
            const Gap(4),
            Text(
              formError!,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const Gap(18),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () {
                final age = int.tryParse(ageController.text);
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    symptomsController.text.trim().isEmpty ||
                    age == null ||
                    age <= 0) {
                  setState(
                    () => formError =
                        'Enter patient name, valid age, phone, and symptoms.',
                  );
                  return;
                }
                setState(() => formError = null);
                final appointment = ref
                    .read(appControllerProvider.notifier)
                    .createAppointment(
                      patientName: nameController.text.trim(),
                      patientAge: age,
                      patientGender: gender,
                      patientPhone: phoneController.text.trim(),
                      doctorId: doctor.id,
                      consultationType: consultationType,
                      date: selectedDay,
                      timeSlot: selectedSlot,
                      symptoms: symptomsController.text.trim(),
                      notes: notesController.text.trim(),
                      reportNames: selectedReportNames.isEmpty
                          ? const ['uploaded-report.pdf']
                          : selectedReportNames.toList(),
                      fee: doctor.fee,
                      paymentMethod: paymentMethod,
                    );
                ref
                    .read(appControllerProvider.notifier)
                    .bookAppointment(appointment);
                _showBookingSuccess(context);
              },
              icon: const Icon(Iconsax.tick_circle),
              label: const Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSuccess(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  size: 42,
                  color: AppColors.success,
                ),
              ).animate().scale(duration: 420.ms, curve: Curves.easeOutBack),
              const Gap(16),
              Text(
                'Booking request sent',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Gap(8),
              const Text(
                'The clinic will confirm your slot. You can track updates from My Appointments.',
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.go(AppRoutes.appointments);
                  },
                  icon: const Icon(Iconsax.calendar_tick),
                  label: const Text('View My Appointments'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const Gap(12),
            child,
          ],
        ),
      ),
    );
  }
}
