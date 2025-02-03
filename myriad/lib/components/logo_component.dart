import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoComponent extends StatelessWidget {
  final double size;
  const LogoComponent({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final assetPath =
            isDarkMode ? 'assets/logo_dark.svg' : 'assets/logo_light.svg';
        return SvgPicture.asset(
          assetPath,
          height: size,
          placeholderBuilder: (BuildContext context) => Container(
            height: size,
            width: size,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          semanticsLabel: 'Logo',
        );
      },
    );
  }
}
