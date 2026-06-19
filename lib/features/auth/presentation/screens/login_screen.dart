import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController(text: 'demo@medlink.app');
  final passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: MedLinkBackButton(fallbackRoute: AppRoutes.onboarding),
                ),
                const Gap(18),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.teal],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .22),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.health,
                    color: Colors.white,
                    size: 38,
                  ),
                ).animate().scale(duration: 430.ms, curve: Curves.easeOutBack),
                const Gap(24),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                Text(
                  'Login to manage appointments, prescriptions, and care.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const Gap(28),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Iconsax.sms),
                  ),
                ),
                const Gap(14),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Iconsax.lock),
                  ),
                ),
                if (auth.error != null) ...[
                  const Gap(10),
                  Text(
                    auth.error!,
                    style: const TextStyle(color: AppColors.warning),
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const Gap(10),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                            final nextState = ref.read(authControllerProvider);
                            if (context.mounted && nextState.isAuthenticated) {
                              context.go(
                                ref
                                    .read(authControllerProvider.notifier)
                                    .landingRoute(),
                              );
                            }
                          },
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                ),
                const Gap(18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New to MedLink?'),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
