import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/state/app_state.dart';

class DoctorDashboardScreen extends ConsumerWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final appointments = state.appointments;
    final pending = appointments
        .where((item) => item.status == AppointmentStatus.pending)
        .toList();
    final confirmed = appointments
        .where((item) => item.status == AppointmentStatus.confirmed)
        .toList();
    final completed = appointments
        .where((item) => item.status == AppointmentStatus.completed)
        .toList();
    final earnings = completed.fold<int>(0, (sum, item) => sum + item.fee);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Iconsax.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _MetricGrid(
            today: confirmed.length,
            pending: pending.length,
            completed: completed.length,
            earnings: earnings,
          ),
          const Gap(18),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push(AppRoutes.doctorAvailability),
                  icon: const Icon(Iconsax.clock),
                  label: const Text('Availability'),
                ),
              ),
              const Gap(10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push(AppRoutes.doctorProfile),
                  icon: const Icon(Iconsax.user_edit),
                  label: const Text('Profile'),
                ),
              ),
            ],
          ),
          const Gap(10),
          FilledButton.tonalIcon(
            onPressed: () => context.push(AppRoutes.doctorEarnings),
            icon: const Icon(Iconsax.wallet_3),
            label: const Text('View Earnings'),
          ),
          const Gap(18),
          const Text(
            'Pending Requests',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const Gap(10),
          if (pending.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Iconsax.tick_circle),
                title: Text('No pending requests'),
                subtitle: Text('New bookings will appear here.'),
              ),
            )
          else
            ...pending.map((item) => _RequestCard(appointment: item)),
          const Gap(18),
          const Text(
            'Today Confirmed',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const Gap(10),
          ...confirmed.map((item) => _ConfirmedCard(appointment: item)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
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
                'Logout from doctor account?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(8),
              const Text('You can sign in again from the login screen.'),
              const Gap(18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Stay'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      icon: const Icon(Iconsax.logout),
                      label: const Text('Logout'),
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
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.today,
    required this.pending,
    required this.completed,
    required this.earnings,
  });

  final int today;
  final int pending;
  final int completed;
  final int earnings;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Iconsax.calendar_tick, 'Today', '$today'),
      (Iconsax.timer, 'Pending', '$pending'),
      (Iconsax.tick_circle, 'Completed', '$completed'),
      (Iconsax.wallet_3, 'Earnings', 'Rs.$earnings'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        childAspectRatio: 1.45,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$1, color: AppColors.primary),
                const Spacer(),
                Text(
                  item.$3,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(item.$2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = SampleData.doctors.firstWhere(
      (item) => item.id == appointment.doctorId,
      orElse: () => SampleData.doctors.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.patientName,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const Gap(6),
            Text('${doctor.specialty} | ${appointment.symptoms}'),
            Text(
              '${DateFormat('MMM d').format(appointment.date)}, ${appointment.timeSlot}',
            ),
            const Gap(14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push('/doctor/patients/${appointment.id}'),
                icon: const Icon(Iconsax.folder_open),
                label: const Text('View Patient Record'),
              ),
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(appControllerProvider.notifier)
                        .updateAppointmentStatus(
                          appointment.id,
                          AppointmentStatus.rejected,
                        ),
                    child: const Text('Reject'),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => ref
                        .read(appControllerProvider.notifier)
                        .updateAppointmentStatus(
                          appointment.id,
                          AppointmentStatus.confirmed,
                        ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmedCard extends ConsumerWidget {
  const _ConfirmedCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Iconsax.video, color: AppColors.primary),
        title: Text(appointment.patientName),
        subtitle: Text('${appointment.timeSlot} | ${appointment.symptoms}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'call') context.push('/video-call/${appointment.id}');
            if (value == 'rx') {
              context.push('/doctor/prescriptions/${appointment.id}/edit');
            }
            if (value == 'record') {
              context.push('/doctor/patients/${appointment.id}');
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'record', child: Text('Patient Record')),
            PopupMenuItem(value: 'call', child: Text('Start Call')),
            PopupMenuItem(value: 'rx', child: Text('Write Prescription')),
          ],
        ),
      ),
    );
  }
}
