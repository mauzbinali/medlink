import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();

  final pages = const [
    _OnboardingPage(
      icon: Iconsax.search_normal_1,
      title: 'Find trusted doctors near you',
      body: 'Search by specialty, symptom, fee, rating, and availability.',
    ),
    _OnboardingPage(
      icon: Iconsax.calendar_tick,
      title: 'Book appointments in seconds',
      body: 'Choose clinic visits or online consultations with clear slots.',
    ),
    _OnboardingPage(
      icon: Iconsax.video_play,
      title: 'Consult doctors online from home',
      body: 'Join a polished telemedicine room for remote care.',
    ),
    _OnboardingPage(
      icon: Iconsax.document_text,
      title: 'Manage prescriptions and records',
      body: 'Keep reports, medicines, prescriptions, and follow-ups together.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView(controller: controller, children: pages),
              ),
              SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: AppColors.primary,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Iconsax.arrow_right_3),
                  label: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.sky,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(icon, size: 82, color: AppColors.primary),
        ).animate().fadeIn().scale(curve: Curves.easeOutBack),
        const Gap(36),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const Gap(12),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.muted, height: 1.5),
        ),
      ],
    );
  }
}
