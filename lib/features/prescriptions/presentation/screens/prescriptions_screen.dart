import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/services/prescription_pdf_service.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptions = ref.watch(appControllerProvider).prescriptions;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Prescriptions',
        fallbackRoute: AppRoutes.patientProfile,
      ),
      body: prescriptions.isEmpty
          ? const MedLinkEmptyState(
              icon: Iconsax.document_text,
              title: 'No prescriptions yet',
              message: 'Doctor prescriptions will appear here after visits.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                final doctor = SampleData.doctors.firstWhere(
                  (item) => item.id == prescription.doctorId,
                  orElse: () => SampleData.doctors.first,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Iconsax.document_text,
                              color: AppColors.primary,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                prescription.diagnosis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const Gap(10),
                        Text('${doctor.name} | ${doctor.specialty}'),
                        Text(
                          DateFormat(
                            'MMM d, yyyy',
                          ).format(prescription.createdAt),
                        ),
                        const Divider(height: 26),
                        ...prescription.medicines.map(
                          (medicine) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Iconsax.health,
                                  size: 18,
                                  color: AppColors.teal,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    '${medicine.name} - ${medicine.dosage}, ${medicine.frequency}, ${medicine.duration}. ${medicine.instructions}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(8),
                        Text(prescription.instructions),
                        const Gap(14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final bytes =
                                      await PrescriptionPdfService.build(
                                        doctor: doctor,
                                        prescription: prescription,
                                      );
                                  await Printing.sharePdf(
                                    bytes: bytes,
                                    filename:
                                        'medlink-prescription-${prescription.id}.pdf',
                                  );
                                },
                                icon: const Icon(Iconsax.document_download),
                                label: const Text('PDF'),
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  final bytes =
                                      await PrescriptionPdfService.build(
                                        doctor: doctor,
                                        prescription: prescription,
                                      );
                                  await Printing.sharePdf(
                                    bytes: bytes,
                                    filename:
                                        'medlink-prescription-${prescription.id}.pdf',
                                  );
                                },
                                icon: const Icon(Iconsax.share),
                                label: const Text('Share'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: (40 * index).ms).fadeIn().slideY(begin: .05, end: 0);
              },
            ),
    );
  }
}
