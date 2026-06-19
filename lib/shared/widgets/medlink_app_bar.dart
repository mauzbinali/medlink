import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/routes/app_routes.dart';

class MedLinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedLinkAppBar({
    this.title,
    this.actions = const [],
    this.fallbackRoute = AppRoutes.patientHome,
    this.showBackButton = true,
    super.key,
  });

  final String? title;
  final List<Widget> actions;
  final String fallbackRoute;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? MedLinkBackButton(fallbackRoute: fallbackRoute)
          : null,
      title: title == null ? null : Text(title!),
      actions: actions,
    );
  }
}

class MedLinkBackButton extends StatelessWidget {
  const MedLinkBackButton({
    this.fallbackRoute = AppRoutes.patientHome,
    super.key,
  });

  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
      icon: const Icon(Iconsax.arrow_left_2),
    );
  }
}
