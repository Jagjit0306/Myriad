import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: "Home", icon: Icons.home_outlined),
  Destination(label: "My AI", icon: Icons.auto_awesome),
  Destination(label: "Myriad", icon: Icons.add),
  Destination(label: "Community", icon: Icons.people),
  Destination(label: "SOS", icon: Icons.warning),
];
