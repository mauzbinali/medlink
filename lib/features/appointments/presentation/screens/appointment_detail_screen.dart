import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/services/receipt_pdf_service.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref
        .watch(appControllerProvider)
        .appointments
        .where((item) => item.id == appointmentId);
    if (matches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Appointment Details',
          fallbackRoute: '/patient/appointments',
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.calendar_remove,
          title: 'Appointment not found',
          message: 'This appointment may have been removed or rescheduled.',
        ),
      );
    }
    final appointment = matches.first;
    final doctor = SampleData.doctors.firstWhere(
      (item) => item.id == appointment.doctorId,
      orElse: () => SampleData.doctors.first,
    );

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Appointment Details',
        fallbackRoute: '/patient/appointments',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Chip(label: Text(appointment.status.label)),
                    ],
                  ),
                  const Gap(8),
                  Text('${doctor.specialty} | ${doctor.clinicName}'),
                  const Divider(height: 28),
                  _Info(
                    icon: Iconsax.calendar,
                    label: 'Date',
                    value: DateFormat(
                      'EEEE, MMM d, yyyy',
                    ).format(appointment.date),
                  ),
                  _Info(
                    icon: Iconsax.clock,
                    label: 'Time',
                    value: appointment.timeSlot,
                  ),
                  _Info(
                    icon: Iconsax.video,
                    label: 'Type',
                    value: appointment.consultationType,
                  ),
                  _Info(
                    icon: Iconsax.wallet_3,
                    label: 'Fee',
                    value: 'Rs.${appointment.fee}',
                  ),
                  _Info(
                    icon: Iconsax.card,
                    label: 'Payment',
                    value:
                        '${appointment.paymentMethod} - ${appointment.paymentStatus}',
                  ),
                ],
              ),
            ),
          ),
          const Gap(14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Info',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Gap(12),
                  _Info(
                    icon: Iconsax.user,
                    label: 'Name',
                    value: appointment.patientName,
                  ),
                  _Info(
                    icon: Iconsax.profile_2user,
                    label: 'Age/Gender',
                    value:
                        '${appointment.patientAge}, ${appointment.patientGender}',
                  ),
                  _Info(
                    icon: Iconsax.call,
                    label: 'Phone',
                    value: appointment.patientPhone,
                  ),
                  _Info(
                    icon: Iconsax.health,
                    label: 'Symptoms',
                    value: appointment.symptoms,
                  ),
                  if (appointment.notes.isNotEmpty)
                    _Info(
                      icon: Iconsax.note_text,
                      label: 'Notes',
                      value: appointment.notes,
                    ),
                ],
              ),
            ),
          ),
          const Gap(14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reports',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Gap(10),
                  if (appointment.reportNames.isEmpty)
                    const Text('No reports attached.')
                  else
                    ...appointment.reportNames.map(
                      (report) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Iconsax.document,
                          color: AppColors.primary,
                        ),
                        title: Text(report),
                        trailing: const Icon(Iconsax.document_download),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Gap(18),
          OutlinedButton.icon(
            onPressed: () async {
              final bytes = await ReceiptPdfService.build(
                appointment: appointment,
                doctor: doctor,
              );
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'medlink-receipt-${appointment.id}.pdf',
              );
            },
            icon: const Icon(Iconsax.receipt),
            label: const Text('Download Receipt'),
          ),
          const Gap(10),
          OutlinedButton.icon(
            onPressed: () =>
                context.push('/appointments/${appointment.id}/chat'),
            icon: const Icon(Iconsax.message_text),
            label: const Text('Chat With Clinic'),
          ),
          const Gap(10),
          if (appointment.status == AppointmentStatus.confirmed)
            FilledButton.icon(
              onPressed: () => context.push('/video-call/${appointment.id}'),
              icon: const Icon(Iconsax.video),
              label: const Text('Join Video Consultation'),
            ),
          if (appointment.status == AppointmentStatus.pending ||
              appointment.status == AppointmentStatus.confirmed) ...[
            const Gap(10),
            OutlinedButton.icon(
              onPressed: () => _showRescheduleSheet(context, ref, appointment),
              icon: const Icon(Iconsax.calendar_edit),
              label: const Text('Reschedule'),
            ),
            const Gap(10),
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(appControllerProvider.notifier)
                  .updateAppointmentStatus(
                    appointment.id,
                    AppointmentStatus.cancelled,
                  ),
              icon: const Icon(Iconsax.close_circle),
              label: const Text('Cancel Appointment'),
            ),
          ],
        ],
      ),
    );
  }

  void _showRescheduleSheet(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
  ) {
    var selectedDate = appointment.date.add(const Duration(days: 1));
    var selectedSlot = appointment.timeSlot;
    final slots = const [
      '10:00 AM',
      '11:30 AM',
      '5:00 PM',
      '6:30 PM',
      '7:00 PM',
    ];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reschedule Appointment',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const Gap(14),
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    onDateChanged: (date) =>
                        setState(() => selectedDate = date),
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((slot) {
                      return ChoiceChip(
                        label: Text(slot),
                        selected: selectedSlot == slot,
                        onSelected: (_) => setState(() => selectedSlot = slot),
                      );
                    }).toList(),
                  ),
                  const Gap(18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .rescheduleAppointment(
                              id: appointment.id,
                              date: selectedDate,
                              timeSlot: selectedSlot,
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Save New Slot'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const Gap(8),
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
