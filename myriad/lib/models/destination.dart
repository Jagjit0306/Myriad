import 'package:flutter/material.dart';

class Destination {
  const Destination({
    required this.label,
    required this.icon,
    required this.icon2,
  });

  final String label;
  final IconData icon;
  final IconData icon2;
}

const destinations = [
  Destination(
    label: "Home",
    icon: Icons.home_outlined,
    icon2: Icons.home,
  ),
  Destination(
    label: "My AI",
    icon: Icons.auto_awesome_outlined,
    icon2: Icons.auto_awesome,
  ),
  Destination(
    label: "Myriad",
    icon: Icons.add,
    icon2: Icons.add,
  ),
  Destination(
    label: "Community",
    icon: Icons.people_alt_outlined,
    icon2: Icons.people_alt,
  ),
  Destination(
    label: "Profile",
    icon: Icons.account_circle_outlined,
    icon2: Icons.account_circle,
  ),
];

const destinations2 = [
  Destination(
    label: "My AI",
    icon: Icons.auto_awesome_outlined,
    icon2: Icons.auto_awesome,
  ),
  Destination(
    label: "Vibraillify",
    icon: Icons.repeat_outlined,
    icon2: Icons.repeat_on_outlined,
  ),
];
