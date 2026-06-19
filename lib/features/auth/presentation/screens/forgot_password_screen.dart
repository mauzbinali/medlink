import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../application/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController(text: 'demo@medlink.app');

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Reset password',
        fallbackRoute: AppRoutes.login,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Iconsax.sms),
              ),
            ),
            if (auth.error != null) ...[
              const Gap(10),
              Text(
                auth.error!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
            const Gap(18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .sendPasswordReset(emailController.text.trim());
                        final nextState = ref.read(authControllerProvider);
                        if (context.mounted && nextState.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reset link sent')),
                          );
                        }
                      },
                child: const Text('Send reset link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
