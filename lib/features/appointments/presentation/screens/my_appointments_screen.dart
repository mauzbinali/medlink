import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';
import '../../../patient/presentation/widgets/patient_bottom_nav.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appControllerProvider).appointments;
    final upcoming = appointments
        .where(
          (item) =>
              item.status == AppointmentStatus.pending ||
              item.status == AppointmentStatus.confirmed,
        )
        .toList();
    final completed = appointments
        .where((item) => item.status == AppointmentStatus.completed)
        .toList();
    final cancelled = appointments
        .where(
          (item) =>
              item.status == AppointmentStatus.cancelled ||
              item.status == AppointmentStatus.rejected,
        )
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
        body: TabBarView(
          children: [
            _AppointmentList(appointments: upcoming),
            _AppointmentList(appointments: completed),
            _AppointmentList(appointments: cancelled),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const _EmptyState(label: 'No appointments in this tab yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _AppointmentCard(
          appointment: appointments[index],
        ).animate(delay: (40 * index).ms).fadeIn().slideY(begin: .05, end: 0);
      },
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.appointment});

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    doctor.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Chip(label: Text(appointment.status.label)),
              ],
            ),
            Text(doctor.specialty),
            const Gap(12),
            _Meta(
              icon: Iconsax.calendar,
              text: DateFormat('EEE, MMM d').format(appointment.date),
            ),
            _Meta(icon: Iconsax.clock, text: appointment.timeSlot),
            _Meta(icon: Iconsax.video, text: appointment.consultationType),
            _Meta(icon: Iconsax.wallet_3, text: 'Rs.${appointment.fee}'),
            const Gap(14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.push('/patient/appointments/${appointment.id}'),
                    child: const Text('Details'),
                  ),
                ),
                const Gap(10),
                if (appointment.status == AppointmentStatus.pending ||
                    appointment.status == AppointmentStatus.confirmed)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmCancel(context, ref),
                      child: const Text('Cancel'),
                    ),
                  ),
                if (appointment.status == AppointmentStatus.confirmed) ...[
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          context.push('/video-call/${appointment.id}'),
                      child: const Text('Join Call'),
                    ),
                  ),
                ],
                if (appointment.status == AppointmentStatus.completed)
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _showReviewSheet(context, ref),
                      child: const Text('Rate Doctor'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
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
                'Cancel appointment?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(8),
              const Text(
                'This will move the visit to your cancelled appointments.',
              ),
              const Gap(18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Keep Visit'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .updateAppointmentStatus(
                              appointment.id,
                              AppointmentStatus.cancelled,
                            );
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Cancel Visit'),
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

  void _showReviewSheet(BuildContext context, WidgetRef ref) {
    double rating = 5;
    final commentController = TextEditingController(
      text: 'Great consultation.',
    );

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rate consultation',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(16),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                allowHalfRating: true,
                itemSize: 30,
                itemBuilder: (context, _) =>
                    const Icon(Iconsax.star1, color: AppColors.warning),
                onRatingUpdate: (value) => rating = value,
              ),
              const Gap(14),
              TextField(
                controller: commentController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref
                        .read(appControllerProvider.notifier)
                        .addReview(
                          doctorId: appointment.doctorId,
                          appointmentId: appointment.id,
                          rating: rating,
                          comment: commentController.text.trim(),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const Gap(8),
          Text(text),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MedLinkEmptyState(
      icon: Iconsax.calendar_remove,
      title: 'Nothing here yet',
      message: label,
    );
  }
}
