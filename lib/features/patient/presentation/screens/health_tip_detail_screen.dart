import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class HealthTipDetailScreen extends ConsumerWidget {
  const HealthTipDetailScreen({required this.tipId, super.key});

  final String tipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref
        .watch(appControllerProvider)
        .healthTips
        .where((item) => item.id == tipId);
    if (matches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Health Tip',
          fallbackRoute: AppRoutes.healthTips,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.heart_remove,
          title: 'Tip not found',
          message: 'This health tip may have been removed by admin.',
        ),
      );
    }
    final tip = matches.first;

    return Scaffold(
      appBar: MedLinkAppBar(
        title: tip.category,
        fallbackRoute: AppRoutes.healthTips,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.health, color: Colors.white, size: 76),
          ),
          const Gap(18),
          Text(
            tip.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(10),
          Text(
            tip.shortDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const Gap(22),
          Text(
            tip.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const Gap(22),
          Card(
            child: ListTile(
              leading: const Icon(Iconsax.warning_2, color: AppColors.warning),
              title: const Text('Medical note'),
              subtitle: const Text(
                'This tip is educational and does not replace professional medical advice.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
