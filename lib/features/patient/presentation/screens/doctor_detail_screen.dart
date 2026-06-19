import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/animated_page_list.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({required this.doctorId, super.key});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = SampleData.doctors.where((item) => item.id == doctorId);
    if (matches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Doctor Details',
          fallbackRoute: AppRoutes.doctors,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.profile_delete,
          title: 'Doctor not found',
          message: 'This profile is no longer available.',
        ),
      );
    }
    final doctor = matches.first;
    final state = ref.watch(appControllerProvider);
    final isFavorite = state.favoriteDoctorIds.contains(doctorId);
    final reviews = state.reviews
        .where((item) => item.doctorId == doctorId)
        .toList();

    return Scaffold(
      appBar: MedLinkAppBar(
        title: 'Doctor Details',
        fallbackRoute: AppRoutes.doctors,
        actions: [
          IconButton(
            onPressed: () => ref
                .read(appControllerProvider.notifier)
                .toggleFavorite(doctorId),
            icon: Icon(isFavorite ? Icons.favorite : Iconsax.heart),
            color: isFavorite ? AppColors.danger : null,
          ),
        ],
      ),
      body: AnimatedPageList(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Hero(
                      tag: 'doctor-photo-${doctor.id}',
                      child: CachedNetworkImage(
                        imageUrl:
                            '${doctor.imageUrl}?auto=format&fit=crop&w=400&q=80',
                        width: 112,
                        height: 132,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.line,
                          highlightColor: Colors.white,
                          child: Container(
                            width: 112,
                            height: 132,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 112,
                          height: 132,
                          color: AppColors.sky,
                          child: const Icon(
                            Iconsax.profile_2user,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Gap(6),
                        Text(doctor.specialty),
                        const Gap(10),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.star1,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const Gap(6),
                            Text(
                              '${doctor.rating} (${doctor.reviewsCount} reviews)',
                            ),
                          ],
                        ),
                        const Gap(10),
                        Text(
                          'Rs.${doctor.fee}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.about),
                  const Gap(16),
                  _InfoRow(icon: Iconsax.teacher, text: doctor.qualification),
                  _InfoRow(
                    icon: Iconsax.briefcase,
                    text: '${doctor.experienceYears} years experience',
                  ),
                  _InfoRow(icon: Iconsax.hospital, text: doctor.clinicName),
                  _InfoRow(icon: Iconsax.location, text: doctor.clinicAddress),
                  _InfoRow(icon: Iconsax.clock, text: doctor.availability),
                ],
              ),
            ),
          ),
          const Gap(16),
          Text(
            'Services',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.services
                .map((service) => Chip(label: Text(service)))
                .toList(),
          ),
          const Gap(18),
          Text(
            'Reviews',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(10),
          if (reviews.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Iconsax.star),
                title: Text('No patient reviews yet'),
                subtitle: Text('Reviews will appear after completed visits.'),
              ),
            )
          else
            ...reviews.map(
              (review) => Card(
                child: ListTile(
                  leading: const Icon(Iconsax.star1, color: AppColors.warning),
                  title: Text('${review.rating} / 5'),
                  subtitle: Text(review.comment),
                ),
              ),
            ),
          const Gap(100),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push('/patient/doctors/$doctorId/book'),
                icon: const Icon(Iconsax.video),
                label: const Text('Online'),
              ),
            ),
            const Gap(12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () =>
                    context.push('/patient/doctors/$doctorId/book'),
                icon: const Icon(Iconsax.calendar_add),
                label: const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const Gap(8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
