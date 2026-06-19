import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';

class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Heart Attack', 'Chest pain, sweating, shortness of breath'),
      ('Fever', 'High temperature, weakness, chills'),
      ('Accident', 'Bleeding, fracture, injury support'),
      ('Breathing Problem', 'Asthma, breathlessness, oxygen support'),
      ('Severe Pain', 'Sudden pain needing urgent attention'),
    ];

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Emergency Help',
        fallbackRoute: AppRoutes.patientHome,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.danger,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.call_calling, color: Colors.white, size: 34),
                const Gap(12),
                Text(
                  'Need urgent help?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(12),
                FilledButton.tonalIcon(
                  onPressed: () => launchUrl(Uri.parse('tel:1122')),
                  icon: const Icon(Iconsax.call),
                  label: const Text('Call Ambulance'),
                ),
              ],
            ),
          ),
          const Gap(18),
          ...categories.asMap().entries.map(
            (entry) =>
                Card(
                      child: ListTile(
                        leading: const Icon(
                          Iconsax.health,
                          color: AppColors.primary,
                        ),
                        title: Text(entry.value.$1),
                        subtitle: Text(entry.value.$2),
                        trailing: const Icon(Iconsax.arrow_right_3),
                      ),
                    )
                    .animate(delay: (35 * entry.key).ms)
                    .fadeIn()
                    .slideY(begin: .05, end: 0),
          ),
        ],
      ),
    );
  }
}
