import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(appControllerProvider).medicalRecords;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Medical Records',
        fallbackRoute: AppRoutes.patientHome,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordSheet(context, ref),
        icon: const Icon(Iconsax.document_upload),
        label: const Text('Upload'),
      ),
      body: records.isEmpty
          ? MedLinkEmptyState(
              icon: Iconsax.document_upload,
              title: 'No records uploaded',
              message: 'Upload reports and history here.',
              action: FilledButton.icon(
                onPressed: () => _showAddRecordSheet(context, ref),
                icon: const Icon(Iconsax.document_upload),
                label: const Text('Upload Record'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Iconsax.document,
                          color: AppColors.primary,
                        ),
                        title: Text(record.title),
                        subtitle: Text(
                          '${record.type} | ${record.fileName}\n${DateFormat('MMM d, yyyy').format(record.createdAt)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          onPressed: () =>
                              _confirmDeleteRecord(context, ref, record.id),
                          icon: const Icon(Iconsax.trash),
                        ),
                      ),
                    )
                    .animate(delay: (40 * index).ms)
                    .fadeIn()
                    .slideY(begin: .05, end: 0);
              },
            ),
    );
  }

  void _confirmDeleteRecord(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete record?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(8),
              const Text('This removes the record from MedLink demo storage.'),
              const Gap(18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Keep'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .deleteMedicalRecord(id);
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddRecordSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: 'New Lab Report');
    final notesController = TextEditingController(
      text: 'Uploaded for doctor review.',
    );
    var type = 'Lab Report';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Upload medical record',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const Gap(16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const Gap(12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(
                        value: 'Lab Report',
                        child: Text('Lab Report'),
                      ),
                      DropdownMenuItem(
                        value: 'Prescription',
                        child: Text('Prescription'),
                      ),
                      DropdownMenuItem(value: 'X-Ray', child: Text('X-Ray')),
                      DropdownMenuItem(value: 'MRI', child: Text('MRI')),
                      DropdownMenuItem(
                        value: 'Blood Test',
                        child: Text('Blood Test'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) => setState(() => type = value!),
                  ),
                  const Gap(12),
                  TextField(
                    controller: notesController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const Gap(16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .addMedicalRecord(
                              title: titleController.text.trim(),
                              type: type,
                              fileName: 'medical-file.pdf',
                              notes: notesController.text.trim(),
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Save Record'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
