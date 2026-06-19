import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({required this.doctor, required this.onTap, super.key});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: 'doctor-photo-${doctor.id}',
                  child: CachedNetworkImage(
                    imageUrl:
                        '${doctor.imageUrl}?auto=format&fit=crop&w=240&q=80',
                    width: 78,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.line,
                      highlightColor: Colors.white,
                      child: Container(
                        width: 78,
                        height: 92,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 78,
                      height: 92,
                      color: AppColors.sky,
                      child: const Icon(
                        Iconsax.profile_2user,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Gap(3),
                    Text(
                      '${doctor.specialty} / ${doctor.qualification}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _Badge(
                          icon: Iconsax.star1,
                          label: '${doctor.rating} (${doctor.reviewsCount})',
                          color: AppColors.warning,
                        ),
                        _Badge(
                          icon: Iconsax.wallet_3,
                          label: 'Rs.${doctor.fee}',
                          color: AppColors.primary,
                        ),
                        if (doctor.isOnlineAvailable)
                          const _Badge(
                            icon: Iconsax.video,
                            label: 'Online',
                            color: AppColors.teal,
                          ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      '${doctor.experienceYears} yrs exp / ${doctor.distanceKm} km / ${doctor.availability}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Gap(4),
              const Icon(Iconsax.arrow_right_3, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const Gap(4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
