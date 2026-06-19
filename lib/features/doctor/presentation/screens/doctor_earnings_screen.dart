import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/payment.dart';
import '../../../../shared/state/app_state.dart';
import '../../../../shared/widgets/medlink_app_bar.dart';

class DoctorEarningsScreen extends ConsumerWidget {
  const DoctorEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = SampleData.doctors.first;
    final payments = ref
        .watch(appControllerProvider)
        .payments
        .where((payment) => payment.doctorId == doctor.id)
        .toList();
    final paid = payments.where(
      (payment) => payment.status == PaymentStatus.paid,
    );
    final total = paid.fold<int>(0, (sum, payment) => sum + payment.amount);
    final today = paid
        .where(
          (payment) => DateUtils.isSameDay(payment.createdAt, DateTime.now()),
        )
        .fold<int>(0, (sum, payment) => sum + payment.amount);

    return Scaffold(
      appBar: const MedLinkAppBar(
        title: 'Earnings',
        fallbackRoute: AppRoutes.doctorDashboard,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _MetricCard(
                icon: Iconsax.wallet_3,
                label: 'Today',
                value: 'Rs.$today',
              ),
              _MetricCard(
                icon: Iconsax.chart,
                label: 'This Week',
                value: 'Rs.$total',
              ),
              _MetricCard(
                icon: Iconsax.calendar_tick,
                label: 'Consults',
                value: '${payments.length}',
              ),
              _MetricCard(
                icon: Iconsax.money,
                label: 'Total',
                value: 'Rs.$total',
              ),
            ],
          ),
          const Gap(18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Earnings Trend',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const Gap(16),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        barGroups: [
                          for (var i = 0; i < 6; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: (i + 2) * 1200,
                                  color: i == 5
                                      ? AppColors.primary
                                      : AppColors.teal,
                                  borderRadius: BorderRadius.circular(4),
                                  width: 18,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(18),
          const Text(
            'Recent Payments',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const Gap(10),
          if (payments.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Iconsax.wallet_3),
                title: Text('No payments yet'),
              ),
            )
          else
            ...payments.map(
              (payment) => Card(
                child: ListTile(
                  leading: const Icon(
                    Iconsax.wallet_money,
                    color: AppColors.primary,
                  ),
                  title: Text(payment.patientName),
                  subtitle: Text(
                    '${payment.method} | ${DateFormat('MMM d, h:mm a').format(payment.createdAt)}',
                  ),
                  trailing: Text(
                    'Rs.${payment.amount}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
