import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctor = SampleData.doctors.first;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Doctor Profile',
        fallbackRoute: AppRoutes.doctorDashboard,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Iconsax.medal_star,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    doctor.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(doctor.specialty),
                ],
              ),
            ),
          ),
          const Gap(14),
          _Field(label: 'Specialty', value: doctor.specialty),
          _Field(label: 'Qualification', value: doctor.qualification),
          _Field(label: 'Experience', value: '${doctor.experienceYears} years'),
          _Field(label: 'Consultation Fee', value: 'Rs.${doctor.fee}'),
          _Field(label: 'Clinic Name', value: doctor.clinicName),
          _Field(label: 'Clinic Address', value: doctor.clinicAddress),
          _Field(label: 'About', value: doctor.about, maxLines: 4),
          const Gap(18),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile changes saved.')),
              );
            },
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.maxLines = 1});

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
