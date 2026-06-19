import 'package:flutter/widgets.dart';

class Specialty {
  const Specialty({
    required this.name,
    required this.description,
    required this.icon,
  });

  final String name;
  final String description;
  final IconData icon;
}
