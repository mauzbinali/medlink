import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class DoctorPatientDetailScreen extends ConsumerWidget {
  const DoctorPatientDetailScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final appointmentMatches = state.appointments.where(
      (item) => item.id == appointmentId,
    );
    if (appointmentMatches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Patient Record',
          fallbackRoute: AppRoutes.doctorDashboard,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.profile_delete,
          title: 'Patient record not found',
          message: 'This appointment record could not be opened.',
        ),
      );
    }
    final appointment = appointmentMatches.first;
    final doctor = SampleData.doctors.firstWhere(
      (item) => item.id == appointment.doctorId,
      orElse: () => SampleData.doctors.first,
    );
    final prescriptions = state.prescriptions
        .where((item) => item.appointmentId == appointment.id)
        .toList();

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Patient Record',
        fallbackRoute: AppRoutes.doctorDashboard,
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
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Iconsax.user, color: Colors.white),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.patientName,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${appointment.patientAge} years | ${appointment.patientGender}',
                            ),
                          ],
                        ),
                      ),
                      Chip(label: Text(appointment.status.label)),
                    ],
                  ),
                  const Divider(height: 28),
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
                  _Info(
                    icon: Iconsax.calendar,
                    label: 'Visit',
                    value:
                        '${DateFormat('MMM d').format(appointment.date)}, ${appointment.timeSlot}',
                  ),
                  _Info(
                    icon: Iconsax.medal_star,
                    label: 'Doctor',
                    value: doctor.name,
                  ),
                ],
              ),
            ),
          ),
          const Gap(14),
          _SectionCard(
            title: 'Attached Reports',
            icon: Iconsax.document_upload,
            children: appointment.reportNames.isEmpty
                ? [const Text('No reports attached to this appointment.')]
                : appointment.reportNames
                      .map(
                        (report) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Iconsax.document),
                          title: Text(report),
                          trailing: const Icon(Iconsax.eye),
                        ),
                      )
                      .toList(),
          ),
          const Gap(14),
          _SectionCard(
            title: 'Medical Records',
            icon: Iconsax.folder,
            children: state.medicalRecords
                .map(
                  (record) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Iconsax.document_text),
                    title: Text(record.title),
                    subtitle: Text('${record.type} | ${record.fileName}'),
                  ),
                )
                .toList(),
          ),
          const Gap(14),
          _SectionCard(
            title: 'Prescriptions',
            icon: Iconsax.note_text,
            children: prescriptions.isEmpty
                ? [
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/doctor/prescriptions/$appointmentId/edit',
                      ),
                      icon: const Icon(Iconsax.document_text),
                      label: const Text('Write Prescription'),
                    ),
                  ]
                : prescriptions
                      .map(
                        (prescription) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Iconsax.health),
                          title: Text(prescription.diagnosis),
                          subtitle: Text(
                            '${prescription.medicines.length} medicine(s)',
                          ),
                        ),
                      )
                      .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const Gap(8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const Gap(12),
            ...children,
          ],
        ),
      ),
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
            width: 82,
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
