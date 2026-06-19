import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../application/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController(text: 'Mauz Patient');
  final emailController = TextEditingController(
    text: 'mauz.patient@medlink.app',
  );
  final phoneController = TextEditingController(text: '+92 300 1234567');
  final passwordController = TextEditingController(text: 'password123');
  final confirmController = TextEditingController(text: 'password123');
  String? formError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Create account',
        fallbackRoute: AppRoutes.login,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
              const Gap(14),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Iconsax.sms),
                ),
              ),
              const Gap(14),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Iconsax.call),
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
              const Gap(14),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Iconsax.lock_1),
                ),
              ),
              if (formError != null || auth.error != null) ...[
                const Gap(12),
                Text(
                  formError ?? auth.error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const Gap(24),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          if (passwordController.text !=
                              confirmController.text) {
                            setState(
                              () => formError = 'Passwords do not match.',
                            );
                            return;
                          }
                          setState(() => formError = null);
                          await ref
                              .read(authControllerProvider.notifier)
                              .register(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                phone: phoneController.text.trim(),
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
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
