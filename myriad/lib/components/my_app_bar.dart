import 'package:flutter/material.dart';
import 'package:myriad/components/logo_component.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const MyAppBar({
    super.key,
    required this.title,
    this.actions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 10,
            children: [
              const LogoComponent(
                size: 40,
              ),
              Text(title),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              const AppbarIcon(
                iconData: Icons.warning_amber_rounded,
              ),
              const AppbarIcon(
                iconData: Icons.notifications_active_outlined,
              ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class AppbarIcon extends StatelessWidget {
  final double size;
  final IconData iconData;
  const AppbarIcon({
    super.key,
    required this.iconData,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Icon(
        iconData,
        size: size,
      ),
    );
  }
}
