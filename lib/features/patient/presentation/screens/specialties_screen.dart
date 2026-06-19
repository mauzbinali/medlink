import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';

class SpecialtiesScreen extends StatelessWidget {
  const SpecialtiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Specialties',
        fallbackRoute: AppRoutes.patientHome,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: SampleData.specialties.length,
        itemBuilder: (context, index) {
          final specialty = SampleData.specialties[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push(AppRoutes.doctors),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.sky,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        specialty.icon,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const Gap(14),
                    Text(
                      specialty.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        specialty.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate(delay: (45 * index).ms).fadeIn().slideY(begin: .06, end: 0);
        },
      ),
    );
  }
}
