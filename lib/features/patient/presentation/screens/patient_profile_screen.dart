import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/animated_page_list.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../auth/application/auth_controller.dart';
import '../widgets/patient_bottom_nav.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Profile',
        fallbackRoute: AppRoutes.patientHome,
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 3),
      body: AnimatedPageList(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.primary,
                    child: Icon(Iconsax.user, color: Colors.white, size: 34),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const Text('+92 300 1234567'),
                        Text(auth.email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(14),
          _ProfileTile(
            icon: Iconsax.heart,
            title: 'Favorite Doctors',
            onTap: () => context.push(AppRoutes.favoriteDoctors),
          ),
          _ProfileTile(
            icon: Iconsax.document_upload,
            title: 'Medical Records',
            onTap: () => context.push(AppRoutes.medicalRecords),
          ),
          _ProfileTile(
            icon: Iconsax.document_text,
            title: 'Prescriptions',
            onTap: () => context.push(AppRoutes.prescriptions),
          ),
          _ProfileTile(
            icon: Iconsax.wallet_3,
            title: 'Payments',
            onTap: () => context.push(AppRoutes.patientPayments),
          ),
          _ProfileTile(
            icon: Iconsax.notification,
            title: 'Notifications',
            onTap: () => context.push(AppRoutes.notifications),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: SwitchListTile(
              value: isDark,
              onChanged: (value) {
                ref
                    .read(themeModeProvider.notifier)
                    .setMode(value ? ThemeMode.dark : ThemeMode.light);
              },
              secondary: const Icon(Iconsax.moon, color: AppColors.primary),
              title: const Text('Dark Mode'),
            ),
          ),
          _ProfileTile(
            icon: Iconsax.shield_tick,
            title: 'Privacy & Security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy controls are ready for Firebase.'),
                ),
              );
            },
          ),
          const Gap(18),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Iconsax.logout),
            label: const Text('Logout'),
          ).animate().fadeIn().slideY(begin: .05, end: 0),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
