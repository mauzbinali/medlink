import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../shared/data/sample_data.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/models/payment.dart';
import '../../../../shared/state/app_state.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final revenue = state.payments
        .where((payment) => payment.status == PaymentStatus.paid)
        .fold<int>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Iconsax.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AdminMetrics(
            patients: 1840 + state.appointments.length,
            doctors: SampleData.doctors.length,
            appointments: state.appointments.length,
            revenue: revenue,
          ),
          const Gap(18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              _AdminAction(
                icon: Iconsax.people,
                label: 'Patients',
                onTap: () => context.push(AppRoutes.adminUsers),
              ),
              _AdminAction(
                icon: Iconsax.medal_star,
                label: 'Doctors',
                onTap: () => context.push(AppRoutes.adminDoctors),
              ),
              _AdminAction(
                icon: Iconsax.calendar,
                label: 'Appointments',
                onTap: () => context.push(AppRoutes.adminAppointments),
              ),
              _AdminAction(
                icon: Iconsax.wallet_3,
                label: 'Payments',
                onTap: () => context.push(AppRoutes.adminPayments),
              ),
              _AdminAction(
                icon: Iconsax.heart_tick,
                label: 'Tips',
                onTap: () => context.push(AppRoutes.adminHealthTips),
              ),
            ],
          ),
          const Gap(18),
          _ChartCard(appointments: state.appointments.length),
          const Gap(18),
          const Text(
            'Doctor Approvals',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const Gap(10),
          ...SampleData.doctors
              .take(4)
              .map(
                (doctor) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Iconsax.medal_star,
                      color: AppColors.teal,
                    ),
                    title: Text(doctor.name),
                    subtitle: Text(
                      '${doctor.specialty} | ${doctor.qualification}',
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () => context.push(AppRoutes.adminDoctors),
                      child: const Text('Approved'),
                    ),
                  ),
                ),
              ),
          const Gap(18),
          const Text(
            'Recent Appointments',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const Gap(10),
          ...state.appointments.map((appointment) {
            final doctor = SampleData.doctors.firstWhere(
              (item) => item.id == appointment.doctorId,
              orElse: () => SampleData.doctors.first,
            );
            return Card(
              child: ListTile(
                leading: const Icon(Iconsax.calendar_tick),
                title: Text('${appointment.patientName} with ${doctor.name}'),
                subtitle: Text(
                  '${appointment.consultationType} | ${appointment.status.label}',
                ),
                trailing: Text('Rs.${appointment.fee}'),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Logout from admin account?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const Gap(8),
              const Text('You can sign in again from the login screen.'),
              const Gap(18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Stay'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      icon: const Icon(Iconsax.logout),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const Gap(8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _AdminMetrics extends StatelessWidget {
  const _AdminMetrics({
    required this.patients,
    required this.doctors,
    required this.appointments,
    required this.revenue,
  });

  final int patients;
  final int doctors;
  final int appointments;
  final int revenue;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Iconsax.people, 'Patients', '$patients'),
      (Iconsax.medal_star, 'Doctors', '$doctors'),
      (Iconsax.calendar_tick, 'Appointments', '$appointments'),
      (Iconsax.wallet_money, 'Revenue', 'Rs.$revenue'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        childAspectRatio: 1.45,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$1, color: AppColors.teal),
                const Spacer(),
                Text(
                  item.$3,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(item.$2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.appointments});

  final int appointments;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointments Trend',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const Gap(16),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 2),
                        const FlSpot(1, 4),
                        const FlSpot(2, 3),
                        FlSpot(3, appointments.toDouble() + 2),
                        const FlSpot(4, 5),
                        const FlSpot(5, 8),
                      ],
                      color: AppColors.primary,
                      barWidth: 4,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
