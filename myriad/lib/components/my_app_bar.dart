import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/logo_component.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool hideSos;
  const MyAppBar({
    super.key,
    required this.title,
    this.hideSos = false,
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
        ],
      ),
      actions: [
        if(!hideSos)
        AppbarIcon(
          onTouch: () => context.go('/sos_page'),
          iconData: Icons.warning_amber_rounded,
        ),
        ...actions,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class AppbarIcon extends StatelessWidget {
  final double size;
  final IconData iconData;
  final VoidCallback onTouch;
  const AppbarIcon({
    super.key,
    required this.onTouch,
    required this.iconData,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTouch,
      icon: Icon(
        iconData,
        size: size,
      ),
    );
  }
}
