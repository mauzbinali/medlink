import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class HealthTipsScreen extends ConsumerWidget {
  const HealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(appControllerProvider).healthTips;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Health Tips',
        fallbackRoute: AppRoutes.patientHome,
      ),
      body: tips.isEmpty
          ? const MedLinkEmptyState(
              icon: Iconsax.heart_tick,
              title: 'No tips yet',
              message: 'Admin health tips will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: tips.length,
              separatorBuilder: (_, _) => const Gap(12),
              itemBuilder: (context, index) {
                final tip = tips[index];
                return Card(
                      child: InkWell(
                        onTap: () =>
                            context.push('/patient/health-tips/${tip.id}'),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Iconsax.heart_tick,
                                  color: AppColors.teal,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tip.category,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const Gap(5),
                                    Text(
                                      tip.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const Gap(6),
                                    Text(tip.shortDescription),
                                  ],
                                ),
                              ),
                              const Icon(Iconsax.arrow_right_3),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: (40 * index).ms)
                    .fadeIn()
                    .slideY(begin: .05, end: 0);
              },
            ),
    );
  }
}
