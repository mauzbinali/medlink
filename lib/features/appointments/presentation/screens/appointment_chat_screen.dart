import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/chat_message.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class AppointmentChatScreen extends ConsumerStatefulWidget {
  const AppointmentChatScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  ConsumerState<AppointmentChatScreen> createState() =>
      _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends ConsumerState<AppointmentChatScreen> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final appointmentMatches = state.appointments.where(
      (item) => item.id == widget.appointmentId,
    );
    if (appointmentMatches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Clinic Chat',
          fallbackRoute: AppRoutes.appointments,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.message_remove,
          title: 'Chat not found',
          message: 'This appointment chat could not be opened.',
        ),
      );
    }
    final appointment = appointmentMatches.first;
    final doctor = SampleData.doctors.firstWhere(
      (item) => item.id == appointment.doctorId,
      orElse: () => SampleData.doctors.first,
    );
    final messages =
        state.chatMessages
            .where((item) => item.appointmentId == widget.appointmentId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        leading: const MedLinkBackButton(fallbackRoute: AppRoutes.appointments),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clinic Chat'),
            Text(
              doctor.clinicName,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const MedLinkEmptyState(
                    icon: Iconsax.message_text,
                    title: 'Start the conversation',
                    message: 'Messages with the clinic will appear here.',
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message clinic...',
                        prefixIcon: Icon(Iconsax.message_text),
                      ),
                    ),
                  ),
                  const Gap(10),
                  IconButton.filled(
                    onPressed: () {
                      ref
                          .read(appControllerProvider.notifier)
                          .sendChatMessage(
                            appointmentId: widget.appointmentId,
                            sender: ChatSender.patient,
                            message: messageController.text,
                          );
                      messageController.clear();
                    },
                    icon: const Icon(Iconsax.send_1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isPatient = message.sender == ChatSender.patient;
    final color = isPatient ? AppColors.primary : Colors.white;
    final textColor = isPatient ? Colors.white : AppColors.ink;

    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .76,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isPatient ? null : Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(color: textColor, height: 1.4),
            ),
            const Gap(5),
            Text(
              DateFormat('h:mm a').format(message.createdAt),
              style: TextStyle(
                color: textColor.withValues(alpha: .68),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
