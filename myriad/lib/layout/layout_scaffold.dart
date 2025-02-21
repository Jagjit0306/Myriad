import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/logo_component.dart';
import 'package:myriad/models/destination.dart';

class LayoutScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const LayoutScaffold({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>("LayoutScaffold"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        indicatorColor: Colors.grey[800],
        animationDuration: Duration(milliseconds: 800),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: destinations
            .map(
              (destination) => NavigationDestination(
                icon: (destination.icon == Icons.add)
                    ? LogoComponent(size: 40)
                    : Icon(destination.icon),
                label: destination.label,
                selectedIcon: (destination.icon == Icons.add)
                    ? LogoComponent(size: 35, alwaysWhite: true,)
                    : Icon(
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
