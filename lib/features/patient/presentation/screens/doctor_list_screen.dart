import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/doctor.dart';
import '../../../../shared/widgets/animated_page_list.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final searchController = TextEditingController();
  String selectedFilter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors();

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Find Doctors',
        fallbackRoute: AppRoutes.patientHome,
      ),
      body: AnimatedPageList(
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search by doctor, specialty, clinic',
              prefixIcon: Icon(Iconsax.search_normal_1),
            ),
          ),
          const Gap(12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const Gap(8),
              itemBuilder: (context, index) {
                final label = _filters[index];
                return ChoiceChip(
                  label: Text(label),
                  selected: selectedFilter == label,
                  onSelected: (_) => setState(() => selectedFilter = label),
                );
              },
            ),
          ),
          const Gap(8),
          Text(
            '${doctors.length} doctors match your search',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.muted),
          ),
          const Gap(18),
          if (doctors.isEmpty)
            const _EmptyDoctorState()
          else
            ...doctors.asMap().entries.map(
              (entry) =>
                  DoctorCard(
                        doctor: entry.value,
                        onTap: () =>
                            context.push('/patient/doctors/${entry.value.id}'),
                      )
                      .animate(delay: (35 * entry.key).ms)
                      .fadeIn()
                      .slideX(begin: .04, end: 0, curve: Curves.easeOutCubic),
            ),
        ],
      ),
    );
  }

  static const _filters = [
    'All',
    'Available Today',
    'Online',
    'Top Rated',
    'Lowest Fee',
    'Nearest',
  ];

  List<Doctor> _filteredDoctors() {
    final query = searchController.text.trim().toLowerCase();
    var doctors = SampleData.doctors.where((doctor) {
      final haystack = [
        doctor.name,
        doctor.specialty,
        doctor.clinicName,
        doctor.qualification,
        ...doctor.services,
      ].join(' ').toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    doctors = switch (selectedFilter) {
      'Available Today' =>
        doctors
            .where((doctor) => !doctor.availability.contains('Not Available'))
            .toList(),
      'Online' => doctors.where((doctor) => doctor.isOnlineAvailable).toList(),
      'Top Rated' => doctors..sort((a, b) => b.rating.compareTo(a.rating)),
      'Lowest Fee' => doctors..sort((a, b) => a.fee.compareTo(b.fee)),
      'Nearest' =>
        doctors..sort((a, b) => a.distanceKm.compareTo(b.distanceKm)),
      _ => doctors,
    };

    return doctors;
  }
}

class _EmptyDoctorState extends StatelessWidget {
  const _EmptyDoctorState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 360,
      child: MedLinkEmptyState(
        icon: Iconsax.search_status,
        title: 'No doctors found',
        message: 'Try another specialty, clinic, or filter.',
      ),
    );
  }
}
