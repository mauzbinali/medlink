import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/medicine.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class PrescriptionEditorScreen extends ConsumerStatefulWidget {
  const PrescriptionEditorScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  ConsumerState<PrescriptionEditorScreen> createState() =>
      _PrescriptionEditorScreenState();
}

class _PrescriptionEditorScreenState
    extends ConsumerState<PrescriptionEditorScreen> {
  final diagnosisController = TextEditingController(text: 'Viral fever');
  final medicineController = TextEditingController(text: 'Panadol 500mg');
  final dosageController = TextEditingController(text: '1 tablet');
  final frequencyController = TextEditingController(text: 'Twice a day');
  final durationController = TextEditingController(text: '5 days');
  final instructionsController = TextEditingController(
    text: 'Take after meal and drink plenty of fluids.',
  );
  final followUpController = TextEditingController(text: '7');
  String? formError;

  @override
  void dispose() {
    diagnosisController.dispose();
    medicineController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    instructionsController.dispose();
    followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentMatches = ref
        .watch(appControllerProvider)
        .appointments
        .where((item) => item.id == widget.appointmentId);
    if (appointmentMatches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Write Prescription',
          fallbackRoute: AppRoutes.doctorDashboard,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.document_text,
          title: 'Appointment not found',
          message: 'Open a confirmed patient record to write a prescription.',
        ),
      );
    }
    final appointment = appointmentMatches.first;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Write Prescription',
        fallbackRoute: AppRoutes.doctorDashboard,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Iconsax.user),
              title: Text(appointment.patientName),
              subtitle: Text(appointment.symptoms),
            ),
          ),
          const Gap(14),
          TextField(
            controller: diagnosisController,
            decoration: const InputDecoration(labelText: 'Diagnosis'),
          ),
          const Gap(12),
          TextField(
            controller: medicineController,
            decoration: const InputDecoration(labelText: 'Medicine'),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage'),
                ),
              ),
              const Gap(10),
              Expanded(
                child: TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                ),
              ),
            ],
          ),
          const Gap(12),
          TextField(
            controller: durationController,
            decoration: const InputDecoration(labelText: 'Duration'),
          ),
          const Gap(12),
          TextField(
            controller: instructionsController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Instructions'),
          ),
          const Gap(12),
          TextField(
            controller: followUpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Follow-up after days',
            ),
          ),
          if (formError != null) ...[
            const Gap(10),
            Text(
              formError!,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const Gap(20),
          FilledButton.icon(
            onPressed: () {
              final days = int.tryParse(followUpController.text) ?? 7;
              if (diagnosisController.text.trim().isEmpty ||
                  medicineController.text.trim().isEmpty ||
                  dosageController.text.trim().isEmpty ||
                  frequencyController.text.trim().isEmpty ||
                  durationController.text.trim().isEmpty ||
                  instructionsController.text.trim().isEmpty ||
                  days <= 0) {
                setState(
                  () => formError =
                      'Complete diagnosis, medicine, dosage, instructions, and follow-up.',
                );
                return;
              }
              setState(() => formError = null);
              ref
                  .read(appControllerProvider.notifier)
                  .createPrescriptionWithDetails(
                    appointmentId: appointment.id,
                    diagnosis: diagnosisController.text.trim(),
                    medicines: [
                      Medicine(
                        name: medicineController.text.trim(),
                        dosage: dosageController.text.trim(),
                        frequency: frequencyController.text.trim(),
                        duration: durationController.text.trim(),
                        instructions: 'After meal',
                      ),
                    ],
                    instructions: instructionsController.text.trim(),
                    followUpDate: DateTime.now().add(Duration(days: days)),
                  );
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.doctorDashboard);
              }
            },
            icon: const Icon(Iconsax.document_text),
            label: const Text('Save Prescription'),
          ),
        ],
      ),
    );
  }
}
