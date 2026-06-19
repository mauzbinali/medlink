import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../application/auth_controller.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Verify Email',
        fallbackRoute: AppRoutes.login,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.sky,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Iconsax.sms_tracking,
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const Gap(22),
            Text(
              'Check your inbox',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Gap(10),
            Text(
              'We sent a verification link to ${auth.email}. Verify your email to continue.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .refreshEmailVerification();
                  final route = ref
                      .read(authControllerProvider.notifier)
                      .landingRoute();
                  if (context.mounted) {
                    context.go(
                      route == AppRoutes.emailVerification
                          ? AppRoutes.roleSelection
                          : route,
                    );
                  }
                },
                icon: const Icon(Iconsax.tick_circle),
                label: const Text('I Verified'),
              ),
            ),
            const Gap(10),
            TextButton(
              onPressed: () async {
                await ref
                    .read(authControllerProvider.notifier)
                    .resendVerificationEmail();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent')),
                  );
                }
              },
              child: const Text('Resend email'),
            ),
          ],
        ),
      ),
    );
  }
}
