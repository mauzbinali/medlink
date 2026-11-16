import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/models/doctor_approval_status.dart';
import '../../../../shared/models/payment.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../widgets/patient_directory.dart';

class AdminManagementScreen extends ConsumerStatefulWidget {
  const AdminManagementScreen({required this.type, super.key});

  final String type;

  @override
  ConsumerState<AdminManagementScreen> createState() =>
      _AdminManagementScreenState();
}

class _AdminManagementScreenState extends ConsumerState<AdminManagementScreen> {
  String query = '';
  String get type => widget.type;
  bool _matches(String value) => value.toLowerCase().contains(query);

  @override
  Widget build(BuildContext context) {
    final title = switch (type) {
      'users' => 'Patients',
      'doctors' => 'Doctors',
      'appointments' => 'Appointments',
      'payments' => 'Payments',
      'health_tips' => 'Health Tips',
      _ => 'Management',
    };

    return Scaffold(
      appBar: MedLinkAppBar(
        title: title,
        fallbackRoute: AppRoutes.adminDashboard,
      ),
      floatingActionButton: type == 'health_tips'
          ? FloatingActionButton.extended(
              onPressed: () => _showHealthTipSheet(context, ref),
              icon: const Icon(Iconsax.add_circle),
              label: const Text('Add Tip'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SearchBar(
            title: 'Search $title',
            onChanged: (value) =>
                setState(() => query = value.trim().toLowerCase()),
          ),
          const Gap(14),
          ...switch (type) {
            'users' => _patientTiles(ref),
            'doctors' => _doctorTiles(ref),
            'appointments' => _appointmentTiles(ref),
            'payments' => _paymentTiles(ref),
            'health_tips' => _healthTipTiles(context, ref),
            _ => [const SizedBox.shrink()],
          },
        ],
      ),
    );
  }

  List<Widget> _patientTiles(WidgetRef ref) {
    final patients = patientDirectory(
      ref.watch(appControllerProvider).appointments,
    );

    return patients
        .where((patient) => _matches('${patient.name} ${patient.phone}'))
        .map(
          (patient) => Card(
            child: ListTile(
              leading: const Icon(Iconsax.user, color: AppColors.primary),
              title: Text(patient.name),
              subtitle: Text(patient.phone),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _doctorTiles(WidgetRef ref) {
    final statuses = ref.watch(appControllerProvider).doctorStatuses;
    return SampleData.doctors
        .where(
          (doctor) => _matches(
            '${doctor.name} ${doctor.specialty} ${doctor.qualification}',
          ),
        )
        .map((doctor) {
          final status = statuses[doctor.id] ?? DoctorApprovalStatus.pending;
          final color = switch (status) {
            DoctorApprovalStatus.approved => AppColors.success,
            DoctorApprovalStatus.pending => AppColors.warning,
            DoctorApprovalStatus.suspended => AppColors.danger,
            DoctorApprovalStatus.rejected => AppColors.danger,
          };
          return Card(
            child: ListTile(
              leading: Icon(Iconsax.medal_star, color: color),
              title: Text(doctor.name),
              subtitle: Text('${doctor.specialty} | ${doctor.qualification}'),
              trailing: PopupMenuButton<DoctorApprovalStatus>(
                onSelected: (value) => ref
                    .read(appControllerProvider.notifier)
                    .updateDoctorStatus(doctorId: doctor.id, status: value),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: DoctorApprovalStatus.approved,
                    child: Text('Approve'),
                  ),
                  PopupMenuItem(
                    value: DoctorApprovalStatus.suspended,
                    child: Text('Suspend'),
                  ),
                  PopupMenuItem(
                    value: DoctorApprovalStatus.rejected,
                    child: Text('Reject'),
                  ),
                ],
                child: Chip(
                  label: Text(status.label),
                  labelStyle: TextStyle(color: color),
                  backgroundColor: color.withValues(alpha: .12),
                  side: BorderSide.none,
                ),
              ),
            ),
          );
        })
        .toList();
  }

  List<Widget> _appointmentTiles(WidgetRef ref) {
    final appointments = ref.watch(appControllerProvider).appointments;
    if (appointments.isEmpty) {
      return const [
        Card(
          child: ListTile(
            leading: Icon(Iconsax.calendar),
            title: Text('No appointments yet'),
          ),
        ),
      ];
    }

    return appointments
        .where(
          (appointment) => _matches(
            '${appointment.patientName} ${appointment.consultationType} ${appointment.status.label} '
            '${SampleData.doctors.where((doctor) => doctor.id == appointment.doctorId).map((doctor) => doctor.name).join(' ')}',
          ),
        )
        .map((appointment) {
          final doctor = SampleData.doctors.firstWhere(
            (item) => item.id == appointment.doctorId,
            orElse: () => SampleData.doctors.first,
          );
          return Card(
            child: ListTile(
              leading: const Icon(
                Iconsax.calendar_tick,
                color: AppColors.primary,
              ),
              title: Text('${appointment.patientName} -> ${doctor.name}'),
              subtitle: Text(
                '${appointment.consultationType} | ${appointment.status.label}',
              ),
              trailing: Text('Rs.${appointment.fee}'),
            ),
          );
        })
        .toList();
  }

  List<Widget> _paymentTiles(WidgetRef ref) {
    final payments = ref.watch(appControllerProvider).payments;
    if (payments.isEmpty) {
      return const [
        Card(
          child: ListTile(
            leading: Icon(Iconsax.wallet_3),
            title: Text('No payments yet'),
          ),
        ),
      ];
    }

    return payments
        .where(
          (payment) => _matches(
            '${payment.patientName} ${payment.method} ${payment.status.label} '
            '${SampleData.doctors.where((doctor) => doctor.id == payment.doctorId).map((doctor) => doctor.name).join(' ')}',
          ),
        )
        .map((payment) {
          final doctor = SampleData.doctors.firstWhere(
            (item) => item.id == payment.doctorId,
            orElse: () => SampleData.doctors.first,
          );
          final color = switch (payment.status) {
            PaymentStatus.paid => AppColors.success,
            PaymentStatus.pending => AppColors.warning,
            PaymentStatus.refunded => AppColors.primary,
            PaymentStatus.failed => AppColors.danger,
          };
          return Card(
            child: ListTile(
              leading: Icon(Iconsax.wallet_money, color: color),
              title: Text('${payment.patientName} -> ${doctor.name}'),
              subtitle: Text('${payment.method} | ${payment.status.label}'),
              trailing: Text(
                'Rs.${payment.amount}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          );
        })
        .toList();
  }

  List<Widget> _healthTipTiles(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(appControllerProvider).healthTips;
    if (tips.isEmpty) {
      return const [
        Card(
          child: ListTile(
            leading: Icon(Iconsax.heart_tick),
            title: Text('No health tips yet'),
            subtitle: Text('Add health tips for patients from here.'),
          ),
        ),
      ];
    }

    return tips
        .where(
          (tip) =>
              _matches('${tip.title} ${tip.category} ${tip.shortDescription}'),
        )
        .map(
          (tip) => Card(
            child: ListTile(
              leading: const Icon(Iconsax.heart_tick, color: AppColors.teal),
              title: Text(tip.title),
              subtitle: Text(tip.shortDescription),
              trailing: IconButton(
                onPressed: () => _confirmDeleteHealthTip(context, ref, tip.id),
                icon: const Icon(Iconsax.trash),
              ),
            ),
          ),
        )
        .toList();
  }

  void _confirmDeleteHealthTip(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete health tip?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(8),
              const Text('Patients will no longer see this tip.'),
              const Gap(18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Keep'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .deleteHealthTip(id);
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHealthTipSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: 'Protect your posture');
    final categoryController = TextEditingController(text: 'General Health');
    final shortController = TextEditingController(
      text: 'Simple posture changes can reduce neck and back strain.',
    );
    final contentController = TextEditingController(
      text:
          'Keep your screen at eye level, relax your shoulders, and take short movement breaks every hour. If pain spreads to the arm or causes numbness, book a consultation.',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Health Tip',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const Gap(12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const Gap(12),
              TextField(
                controller: shortController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                ),
              ),
              const Gap(12),
              TextField(
                controller: contentController,
                minLines: 4,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Article Content'),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        categoryController.text.trim().isEmpty ||
                        shortController.text.trim().isEmpty ||
                        contentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Complete all health tip fields.'),
                        ),
                      );
                      return;
                    }
                    ref
                        .read(appControllerProvider.notifier)
                        .addHealthTip(
                          title: titleController.text.trim(),
                          category: categoryController.text.trim(),
                          shortDescription: shortController.text.trim(),
                          content: contentController.text.trim(),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Publish Tip'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.title, required this.onChanged});

  final String title;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: title,
        prefixIcon: const Icon(Iconsax.search_normal_1),
      ),
    );
  }
}
