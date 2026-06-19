import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/animated_page_list.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../widgets/patient_bottom_nav.dart';

class PatientHomeScreen extends ConsumerWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final firstName = auth.name.trim().isEmpty
        ? 'there'
        : auth.name.trim().split(RegExp(r'\s+')).first;
    final unreadCount = state.notifications
        .where((item) => !item.isRead)
        .length;

    return Scaffold(
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
      body: SafeArea(
        child: AnimatedPageList(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const Gap(4),
                      const Row(
                        children: [
                          Icon(Iconsax.location, size: 16),
                          Gap(6),
                          Text(AppConstants.defaultCity),
                        ],
                      ),
                    ],
                  ),
                ),
                Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: IconButton.filledTonal(
                    onPressed: () => context.push(AppRoutes.notifications),
                    icon: const Icon(Iconsax.notification),
                  ),
                ),
              ],
            ),
            const Gap(20),
            TextField(
              onTap: () => context.push(AppRoutes.doctors),
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Search doctors, specialties, symptoms',
                prefixIcon: Icon(Iconsax.search_normal_1),
              ),
            ),
            const Gap(20),
            _HeroPanel(onBook: () => context.push(AppRoutes.doctors)),
            const Gap(22),
            _QuickActions(),
            const Gap(22),
            SectionHeader(
              title: 'Popular Specialties',
              actionLabel: 'View all',
              onAction: () => context.push(AppRoutes.specialties),
            ),
            const Gap(10),
            SizedBox(
              height: 118,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tileWidth = ((constraints.maxWidth - 20) / 3).clamp(
                    108.0,
                    142.0,
                  );
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    separatorBuilder: (_, _) => const Gap(10),
                    itemBuilder: (context, index) {
                      final specialty = SampleData.specialties[index];
                      return _SpecialtyPreviewTile(
                        width: tileWidth,
                        icon: specialty.icon,
                        name: specialty.name,
                        onTap: () => context.push(AppRoutes.doctors),
                      );
                    },
                  );
                },
              ),
            ),
            const Gap(22),
            SectionHeader(
              title: 'Top Rated Doctors',
              actionLabel: 'See all',
              onAction: () => context.push(AppRoutes.doctors),
            ),
            const Gap(10),
            ...SampleData.doctors
                .take(3)
                .map(
                  (doctor) => DoctorCard(
                    doctor: doctor,
                    onTap: () => context.push('/patient/doctors/${doctor.id}'),
                  ).animate().fadeIn().slideY(begin: .08, end: 0),
                ),
            const Gap(12),
            SectionHeader(
              title: 'Health Tips',
              actionLabel: 'Read',
              onAction: () => context.push(AppRoutes.healthTips),
            ),
            const Gap(10),
            ...state.healthTips
                .take(3)
                .map(
                  (tip) => Card(
                    child: ListTile(
                      onTap: () =>
                          context.push('/patient/health-tips/${tip.id}'),
                      leading: const Icon(Iconsax.heart_tick),
                      title: Text(tip.title),
                      subtitle: Text(tip.shortDescription),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyPreviewTile extends StatelessWidget {
  const _SpecialtyPreviewTile({
    required this.width,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: .08)
        : AppColors.line;
    final iconBg = isDark
        ? AppColors.primaryDark.withValues(alpha: .16)
        : AppColors.sky;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        color: surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.teal],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a doctor today?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                Text(
                  'Find available specialists for clinic or online visits.',
                  style: TextStyle(color: Colors.white.withValues(alpha: .82)),
                ),
                const Gap(16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: onBook,
                      icon: const Icon(Iconsax.calendar_add),
                      label: const Text('Book Now'),
                    ),
                    _HeroMetric(icon: Iconsax.video, label: 'Online ready'),
                  ],
                ),
              ],
            ),
          ),
          const Gap(12),
          Container(
            width: 86,
            height: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: .22)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.health, size: 36, color: Colors.white),
                Gap(10),
                Text(
                  '12+',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Specialties',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: .05, end: 0);
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const Gap(6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark
        ? AppColors.teal.withValues(alpha: .14)
        : AppColors.mint;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: .08)
        : Colors.transparent;
    final actions = [
      (Iconsax.calendar_add, 'Book', AppRoutes.doctors),
      (Iconsax.video, 'Online', AppRoutes.doctors),
      (Iconsax.calendar_tick, 'Visits', AppRoutes.appointments),
      (Iconsax.document_upload, 'Records', AppRoutes.medicalRecords),
      (Iconsax.call_calling, 'Emergency', AppRoutes.emergency),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / actions.length;
        return Row(
          children: actions.map((action) {
            return SizedBox(
              width: itemWidth,
              child: InkWell(
                onTap: () => context.push(action.$3),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(action.$1, color: AppColors.teal),
                      ),
                      const Gap(7),
                      SizedBox(
                        width: itemWidth - 4,
                        child: Text(
                          action.$2,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
