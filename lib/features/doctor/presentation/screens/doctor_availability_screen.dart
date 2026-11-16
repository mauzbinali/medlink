import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final disabledSlots = <String, List<String>>{};
  final slots = <String, List<String>>{
    'Monday': ['5:00 PM - 9:00 PM'],
    'Tuesday': ['6:00 PM - 10:00 PM'],
    'Wednesday': ['5:00 PM - 9:00 PM'],
    'Thursday': ['5:00 PM - 9:00 PM'],
    'Friday': [],
    'Saturday': ['3:00 PM - 8:00 PM'],
    'Sunday': [],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Manage Availability',
        fallbackRoute: AppRoutes.doctorDashboard,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSlot,
        icon: const Icon(Iconsax.add_circle),
        label: const Text('Add Slot'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: slots.entries.toList().asMap().entries.map((indexedEntry) {
          final index = indexedEntry.key;
          final entry = indexedEntry.value;
          final isAvailable = entry.value.isNotEmpty;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Switch(
                        value: isAvailable,
                        onChanged: (value) {
                          setState(() {
                            if (value) {
                              slots[entry.key] =
                                  disabledSlots.remove(entry.key) ??
                                  ['5:00 PM - 9:00 PM'];
                            } else {
                              disabledSlots[entry.key] = List.of(entry.value);
                              slots[entry.key] = [];
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const Gap(8),
                  if (!isAvailable)
                    const Text(
                      'Not available',
                      style: TextStyle(color: AppColors.muted),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value
                          .map(
                            (slot) => InputChip(
                              label: Text(slot),
                              onDeleted: () => setState(
                                () => slots[entry.key]!.remove(slot),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ).animate(delay: (35 * index).ms).fadeIn().slideY(begin: .05, end: 0);
        }).toList(),
      ),
    );
  }

  Future<void> _addSlot() async {
    var day = slots.keys.first;
    var start = const TimeOfDay(hour: 10, minute: 0);
    var end = const TimeOfDay(hour: 12, minute: 0);
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateSheet) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: day,
                decoration: const InputDecoration(labelText: 'Day'),
                items: slots.keys
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => updateSheet(() => day = value!),
              ),
              ListTile(
                title: const Text('Start'),
                trailing: Text(start.format(sheetContext)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: sheetContext,
                    initialTime: start,
                  );
                  if (sheetContext.mounted && time != null) {
                    updateSheet(() => start = time);
                  }
                },
              ),
              ListTile(
                title: const Text('End'),
                trailing: Text(end.format(sheetContext)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: sheetContext,
                    initialTime: end,
                  );
                  if (sheetContext.mounted && time != null) {
                    updateSheet(() => end = time);
                  }
                },
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: AppColors.danger)),
              FilledButton(
                onPressed: () {
                  if (end.hour * 60 + end.minute <=
                      start.hour * 60 + start.minute) {
                    updateSheet(
                      () => error = 'End time must be after start time.',
                    );
                    return;
                  }
                  final label = '${_formatTime(start)} - ${_formatTime(end)}';
                  if (slots[day]!.contains(label)) {
                    updateSheet(() => error = 'This slot already exists.');
                    return;
                  }
                  setState(() => slots[day]!.add(label));
                  Navigator.pop(sheetContext);
                },
                child: const Text('Add Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
}
