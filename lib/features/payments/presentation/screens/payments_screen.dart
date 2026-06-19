import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/payment.dart';
import '../../../../shared/services/receipt_pdf_service.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';
import '../../../../shared/widgets/medlink_empty_state.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final payments = state.payments;

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Payments',
        fallbackRoute: AppRoutes.patientProfile,
      ),
      body: payments.isEmpty
          ? const MedLinkEmptyState(
              icon: Iconsax.wallet_3,
              title: 'No payments yet',
              message: 'Payment history will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                final doctor = SampleData.doctors.firstWhere(
                  (item) => item.id == payment.doctorId,
                  orElse: () => SampleData.doctors.first,
                );
                final appointmentMatches = state.appointments.where(
                  (item) => item.id == payment.appointmentId,
                );
                final appointment = appointmentMatches.isEmpty
                    ? null
                    : appointmentMatches.first;
                return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.mint,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Iconsax.wallet_3,
                                    color: AppColors.teal,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMM d, yyyy - h:mm a',
                                        ).format(payment.createdAt),
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusChip(status: payment.status),
                              ],
                            ),
                            const Divider(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Method'),
                                Text(
                                  payment.method,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Amount'),
                                Text(
                                  'Rs.${payment.amount}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                            const Gap(14),
                            OutlinedButton.icon(
                              onPressed: appointment == null
                                  ? null
                                  : () async {
                                      final bytes =
                                          await ReceiptPdfService.build(
                                            appointment: appointment,
                                            doctor: doctor,
                                          );
                                      await Printing.sharePdf(
                                        bytes: bytes,
                                        filename:
                                            'medlink-receipt-${payment.id}.pdf',
                                      );
                                    },
                              icon: const Icon(Iconsax.receipt),
                              label: const Text('Share Receipt'),
                            ),
                          ],
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
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      PaymentStatus.paid => AppColors.success,
      PaymentStatus.pending => AppColors.warning,
      PaymentStatus.refunded => AppColors.primary,
      PaymentStatus.failed => AppColors.danger,
    };

    return Chip(
      label: Text(status.label),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
      backgroundColor: color.withValues(alpha: .12),
      side: BorderSide.none,
    );
  }
}
