import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeFromSplash();
  }

  Future<void> _routeFromSplash() async {
    await ref.read(authControllerProvider.notifier).restoreSession();
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      context.go(ref.read(authControllerProvider.notifier).landingRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: const Icon(Iconsax.health, size: 46, color: Colors.white),
            ).animate().scale(duration: 550.ms, curve: Curves.easeOutBack),
            const Gap(18),
            Text(
              AppConstants.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: .2, end: 0),
            const Gap(6),
            Text(
              AppConstants.appTagline,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }
}
