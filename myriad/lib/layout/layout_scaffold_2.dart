import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/logo_component.dart';
import 'package:myriad/models/destination.dart';

class LayoutScaffold2 extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const LayoutScaffold2({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>("LayoutScaffold2"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        indicatorColor: Colors.grey[800],
        animationDuration: Duration(milliseconds: 800),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: destinations2
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
                selectedIcon: Icon(
                  destination.icon2,
                  color: Colors.white,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
