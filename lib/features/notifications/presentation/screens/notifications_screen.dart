import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(appControllerProvider).notifications;

    return Scaffold(
      appBar: MedLinkAppBar(
        title: 'Notifications',
        fallbackRoute: AppRoutes.patientHome,
        actions: [
          TextButton(
            onPressed: () => ref
                .read(appControllerProvider.notifier)
                .markAllNotificationsRead(),
            child: const Text('Mark read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const MedLinkEmptyState(
              icon: Iconsax.notification,
              title: 'You are all caught up',
              message: 'New appointment and prescription updates appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Gap(10),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                      child: ListTile(
                        leading: Icon(
                          notification.isRead
                              ? Iconsax.notification
                              : Iconsax.notification_bing,
                          color: notification.isRead
                              ? AppColors.muted
                              : AppColors.primary,
                        ),
                        title: Text(notification.title),
                        subtitle: Text(
                          '${notification.body}\n${DateFormat('MMM d, h:mm a').format(notification.createdAt)}',
                        ),
                        isThreeLine: true,
                      ),
                    )
                    .animate(delay: (35 * index).ms)
                    .fadeIn()
                    .slideY(begin: .04, end: 0);
              },
            ),
    );
  }
}
