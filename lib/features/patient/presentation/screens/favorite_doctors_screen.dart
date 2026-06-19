import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';
import '../widgets/patient_bottom_nav.dart';

class FavoriteDoctorsScreen extends ConsumerWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(appControllerProvider).favoriteDoctorIds;
    final doctors = SampleData.doctors
        .where((doctor) => favoriteIds.contains(doctor.id))
        .toList();

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Favorite Doctors',
        fallbackRoute: AppRoutes.patientHome,
      ),
      bottomNavigationBar: const PatientBottomNav(currentIndex: 1),
      body: doctors.isEmpty
          ? const MedLinkEmptyState(
              icon: Iconsax.heart,
              title: 'No saved doctors yet',
              message: 'Tap the heart on a doctor profile to save it here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return DoctorCard(
                      doctor: doctor,
                      onTap: () =>
                          context.push('/patient/doctors/${doctor.id}'),
                    )
                    .animate(delay: (40 * index).ms)
                    .fadeIn()
                    .slideY(begin: .05, end: 0);
              },
            ),
    );
  }
}
