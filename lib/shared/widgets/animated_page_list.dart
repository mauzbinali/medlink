import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedPageList extends StatelessWidget {
  const AnimatedPageList({
    required this.children,
    this.padding = const EdgeInsets.all(20),
    this.physics,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      physics: physics,
      children: [
        for (var index = 0; index < children.length; index++)
          children[index]
              .animate(delay: (45 * index).ms)
              .fadeIn(duration: 260.ms, curve: Curves.easeOut)
              .slideY(begin: .045, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }
}
