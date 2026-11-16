import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool muted = false;
  bool cameraOn = true;
  bool speakerOn = true;

  @override
  Widget build(BuildContext context) {
    final matches = ref
        .watch(appControllerProvider)
        .appointments
        .where((item) => item.id == widget.appointmentId);
    if (matches.isEmpty) {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Video Consultation',
          fallbackRoute: AppRoutes.appointments,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.video_slash,
          title: 'Call not available',
          message: 'This appointment could not be found.',
        ),
      );
    }
    final appointment = matches.first;
    if (appointment.status != AppointmentStatus.confirmed ||
        appointment.consultationType != 'Online Consultation') {
      return const Scaffold(
        appBar: MedLinkAppBar(
          title: 'Video Consultation',
          fallbackRoute: AppRoutes.appointments,
        ),
        body: MedLinkEmptyState(
          icon: Iconsax.video_slash,
          title: 'Call not available',
          message: 'A confirmed online consultation is required.',
        ),
      );
    }
    final doctor = SampleData.doctors.firstWhere(
      (item) => item.id == appointment.doctorId,
      orElse: () => SampleData.doctors.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 54,
                        ),
                      ),
                      const Gap(16),
                      Text(
                        doctor.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const Gap(6),
                      Text(
                        'Demo | ${appointment.consultationType}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: IconButton.filledTonal(
                onPressed: () => _leaveCall(context),
                icon: const Icon(Iconsax.arrow_left_2),
                tooltip: 'Back',
              ),
            ),
            Positioned(
              right: 28,
              top: 34,
              child: Container(
                width: 112,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: .85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(
                  cameraOn ? Iconsax.user : Iconsax.video_slash,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 26,
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 6,
                runSpacing: 8,
                children: [
                  _CallButton(
                    icon: muted ? Iconsax.microphone_slash : Iconsax.microphone,
                    onTap: () => setState(() => muted = !muted),
                  ),
                  _CallButton(
                    icon: cameraOn ? Iconsax.video : Iconsax.video_slash,
                    onTap: () => setState(() => cameraOn = !cameraOn),
                  ),
                  _CallButton(
                    icon: speakerOn
                        ? Iconsax.volume_high
                        : Iconsax.volume_slash,
                    onTap: () => setState(() => speakerOn = !speakerOn),
                  ),
                  _CallButton(
                    icon: Iconsax.message_text,
                    onTap: () =>
                        context.push('/appointments/${appointment.id}/chat'),
                  ),
                  _CallButton(
                    icon: Iconsax.call_slash,
                    color: AppColors.danger,
                    onTap: () {
                      _leaveCall(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _leaveCall(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.appointments);
    }
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF172338),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
