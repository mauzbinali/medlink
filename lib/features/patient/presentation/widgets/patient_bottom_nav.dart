import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';

class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        final route = switch (index) {
          0 => AppRoutes.patientHome,
          1 => AppRoutes.favoriteDoctors,
          2 => AppRoutes.appointments,
          3 => AppRoutes.patientProfile,
          _ => AppRoutes.patientHome,
        };
        if (index != currentIndex) context.go(route);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
        NavigationDestination(icon: Icon(Iconsax.heart), label: 'Saved'),
        NavigationDestination(icon: Icon(Iconsax.calendar), label: 'Visits'),
        NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
      ],
    );
  }
}
