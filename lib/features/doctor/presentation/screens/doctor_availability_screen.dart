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
        onPressed: _addMondaySlot,
        icon: const Icon(Iconsax.add_circle),
        label: const Text('Add Slot'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
                            slots[entry.key] = value
                                ? ['5:00 PM - 9:00 PM']
                                : [];
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

  void _addMondaySlot() {
    setState(() {
      slots['Monday'] = [...slots['Monday']!, '10:00 AM - 12:00 PM'];
    });
  }
}
