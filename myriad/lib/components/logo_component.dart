import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoComponent extends StatelessWidget {
  final double size;
  final bool alwaysWhite;
  const LogoComponent({super.key, this.size = 200, this.alwaysWhite = false});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final assetPath = alwaysWhite
            ? 'assets/logo_dark.svg'
            : (isDarkMode ? 'assets/logo_dark.svg' : 'assets/logo_light.svg');
        return SvgPicture.asset(
          assetPath,
          height: size,
          placeholderBuilder: (BuildContext context) => SizedBox(
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
