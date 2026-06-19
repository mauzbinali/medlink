import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../application/auth_controller.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Choose workspace',
        fallbackRoute: AppRoutes.login,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _RoleTile(
            icon: Iconsax.user,
            title: 'Patient',
            subtitle: 'Book doctors, view prescriptions, manage records.',
            onTap: () {
              ref
                  .read(authControllerProvider.notifier)
                  .selectRole(UserRole.patient);
              context.go(AppRoutes.patientHome);
            },
          ).animate().fadeIn().slideY(begin: .05, end: 0),
          _RoleTile(
            icon: Iconsax.medal_star,
            title: 'Doctor',
            subtitle: 'Manage requests, availability, and prescriptions.',
            onTap: () {
              ref
                  .read(authControllerProvider.notifier)
                  .selectRole(UserRole.doctor);
              context.go(AppRoutes.doctorDashboard);
            },
          ).animate(delay: 60.ms).fadeIn().slideY(begin: .05, end: 0),
          _RoleTile(
            icon: Iconsax.shield_tick,
            title: 'Admin',
            subtitle: 'Approve doctors, monitor appointments and revenue.',
            onTap: () {
              ref
                  .read(authControllerProvider.notifier)
                  .selectRole(UserRole.admin);
              context.go(AppRoutes.adminDashboard);
            },
          ).animate(delay: 120.ms).fadeIn().slideY(begin: .05, end: 0),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 20,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
